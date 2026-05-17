package io.github.nullptrx.pangleflutter

import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import com.bytedance.sdk.openadsdk.AdSlot
import com.bytedance.sdk.openadsdk.LocationProvider
import com.bytedance.sdk.openadsdk.TTAdConfig
import com.bytedance.sdk.openadsdk.TTAdConstant
import com.bytedance.sdk.openadsdk.TTAdManager
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTAdSdk
import com.bytedance.sdk.openadsdk.TTCustomController
import com.bytedance.sdk.openadsdk.TTFullScreenVideoAd
import com.bytedance.sdk.openadsdk.TTLocation
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import io.github.nullptrx.pangleflutter.common.ERROR_CODE_NO_ACTIVITY
import io.github.nullptrx.pangleflutter.common.ERROR_MSG_NO_ACTIVITY
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.PangleTitleBarTheme
import io.github.nullptrx.pangleflutter.delegate.FLTBannerExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTFeedExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTFullScreenVideoAd
import io.github.nullptrx.pangleflutter.delegate.FLTRewardedVideoAd
import io.github.nullptrx.pangleflutter.delegate.FullScreenVideoAdInteractionImpl
import io.github.nullptrx.pangleflutter.delegate.RewardAdInteractionImpl
import io.github.nullptrx.pangleflutter.util.asList
import io.github.nullptrx.pangleflutter.util.asMap
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap

// ---------------------------------------------------------------------------
// Cached ad wrapper — tracks load time so stale express ads can be rejected.
// TTNativeExpressAd doesn't expose an expirationTimestamp (unlike the video ad
// types), so we apply the same conservative 30-minute TTL used on iOS.
// ---------------------------------------------------------------------------
private data class CachedExpressAd(
  val ad: TTNativeExpressAd,
  val loadedAt: Long = System.currentTimeMillis()
) {
  fun isExpired(): Boolean = System.currentTimeMillis() - loadedAt > TTL_MS

  companion object {
    const val TTL_MS = 30 * 60 * 1000L // 30 minutes
  }
}

class PangleAdManager {

  companion object {
    val shared = PangleAdManager()

    /** Hard cap on cached native express ads. Oldest entries are evicted (FIFO) when exceeded. */
    private const val EXPRESS_CACHE_MAX = 20
  }

  // LinkedHashMap preserves insertion order, enabling O(1) FIFO eviction.
  // All access must be synchronised on expressAdCollection itself.
  private val expressAdCollection: LinkedHashMap<String, CachedExpressAd> =
    LinkedHashMap(EXPRESS_CACHE_MAX + 1, 0.75f, false)

  private val rewardedVideoAdData =
    Collections.synchronizedMap(mutableMapOf<String, MutableList<TTRewardVideoAd>>())
  private val fullScreenVideoAdData =
    Collections.synchronizedMap(mutableMapOf<String, MutableList<TTFullScreenVideoAd>>())

  // Remembered AdSlot per slotId for auto-refill after a cached ad is consumed.
  private val preloadRewardedSlots = ConcurrentHashMap<String, AdSlot>()
  private val preloadFullScreenSlots = ConcurrentHashMap<String, AdSlot>()

  private var ttAdManager: TTAdManager? = null
  private var ttAdNative: TTAdNative? = null


  fun getSdkVersion(): String {
    return ttAdManager?.sdkVersion ?: ""
  }

  fun getThemeStatus(): Int {
    return ttAdManager?.themeStatus ?: -1
  }

  fun setThemeStatus(theme: Int) {
    ttAdManager?.themeStatus = theme
  }

  // ---------------------------------------------------------------------------
  // Express ad cache (feed / banner)
  // ---------------------------------------------------------------------------

  fun setExpressAd(ttBannerAds: List<TTNativeExpressAd>): List<String> {
    val keys = mutableListOf<String>()
    synchronized(expressAdCollection) {
      ttBannerAds.forEach {
        val key = it.hashCode().toString()
        expressAdCollection[key] = CachedExpressAd(it)
        keys.add(key)
      }
      // FIFO eviction: drop oldest entries beyond the cap.
      while (expressAdCollection.size > EXPRESS_CACHE_MAX) {
        val oldestKey = expressAdCollection.keys.first()
        expressAdCollection.remove(oldestKey)?.ad?.destroy()
      }
    }
    return keys
  }

  fun getExpressAd(key: String): TTNativeExpressAd? {
    synchronized(expressAdCollection) {
      val cached = expressAdCollection[key] ?: return null
      if (cached.isExpired()) {
        expressAdCollection.remove(key)
        cached.ad.destroy()
        return null
      }
      return cached.ad
    }
  }

  fun removeExpressAd(key: String): Boolean {
    synchronized(expressAdCollection) {
      if (expressAdCollection.containsKey(key)) {
        expressAdCollection.remove(key)?.ad?.destroy()
        return true
      }
      return false
    }
  }

  // ---------------------------------------------------------------------------
  // Rewarded video
  // ---------------------------------------------------------------------------

  fun setRewardedVideoAd(slotId: String, ad: TTRewardVideoAd?) {
    ad ?: return
    val data = rewardedVideoAdData[slotId] ?: mutableListOf()
    data.add(ad)
    rewardedVideoAdData[slotId] = data
  }

  fun showRewardedVideoAd(
    slotId: String,
    activity: Activity?,
    result: (Any) -> Unit = {}
  ): Boolean {
    activity ?: return false
    val now = System.currentTimeMillis()
    val data = rewardedVideoAdData[slotId] ?: mutableListOf()

    // Drain expired entries upfront (SDK added expirationTimestamp in 3.8.0.6).
    data.removeAll { it.expirationTimestamp < now }
    rewardedVideoAdData[slotId] = data

    if (data.isEmpty()) return false

    val ad = data.removeAt(0)
    rewardedVideoAdData[slotId] = data
    ad.setRewardAdInteractionListener(RewardAdInteractionImpl { obj -> result.invoke(obj) })
    ad.showRewardVideoAd(activity)

    // Auto-refill: if the queue is now empty, kick off a background preload so the
    // next show() call can be served from cache without a network wait.
    if (data.isEmpty()) {
      preloadRewardedSlots[slotId]?.let { storedSlot ->
        loadRewardVideoAd(storedSlot, activity, PangleLoadingType.preload_only)
      }
    }
    return true
  }

  /** 查询是否存在未过期的激励视频缓存广告 */
  fun hasRewardedVideoAd(slotId: String): Boolean {
    val now = System.currentTimeMillis()
    val data = rewardedVideoAdData[slotId] ?: return false
    data.removeAll { it.expirationTimestamp < now }
    rewardedVideoAdData[slotId] = data
    return data.isNotEmpty()
  }

  // ---------------------------------------------------------------------------
  // Fullscreen video
  // ---------------------------------------------------------------------------

  fun setFullScreenVideoAd(slotId: String, ad: TTFullScreenVideoAd?) {
    ad ?: return
    val data = fullScreenVideoAdData[slotId] ?: mutableListOf()
    data.add(ad)
    fullScreenVideoAdData[slotId] = data
  }

  fun showFullScreenVideoAd(
    slotId: String,
    activity: Activity?,
    result: (Any) -> Unit = {}
  ): Boolean {
    activity ?: return false
    val now = System.currentTimeMillis()
    val data = fullScreenVideoAdData[slotId] ?: mutableListOf()

    data.removeAll { it.expirationTimestamp < now }
    fullScreenVideoAdData[slotId] = data

    if (data.isEmpty()) return false

    val ad = data.removeAt(0)
    fullScreenVideoAdData[slotId] = data
    ad.setFullScreenVideoAdInteractionListener(FullScreenVideoAdInteractionImpl { obj ->
      result.invoke(
        obj
      )
    })
    ad.showFullScreenVideoAd(activity)

    // Auto-refill when queue drains.
    if (data.isEmpty()) {
      preloadFullScreenSlots[slotId]?.let { storedSlot ->
        loadFullscreenVideoAd(storedSlot, activity, PangleLoadingType.preload_only) {}
      }
    }
    return true
  }


  /** 查询是否存在未过期的全屏视频缓存广告 */
  fun hasFullscreenVideoAd(slotId: String): Boolean {
    val now = System.currentTimeMillis()
    val data = fullScreenVideoAdData[slotId] ?: return false
    data.removeAll { it.expirationTimestamp < now }
    fullScreenVideoAdData[slotId] = data
    return data.isNotEmpty()
  }

  fun initialize(
    context: Context?,
    args: Map<String, Any?>,
    callback: (Map<String, Any?>) -> Unit
  ) {
    if (context == null) {
      callback(mapOf("code" to ERROR_CODE_NO_ACTIVITY, "message" to ERROR_MSG_NO_ACTIVITY))
      return
    }

    val appId: String = args["appId"] as String
    val debug: Boolean? = args["debug"] as Boolean?
    val allowShowNotify: Boolean? = args["allowShowNotify"] as Boolean?
    val supportMultiProcess: Boolean? = args["supportMultiProcess"] as Boolean?
    val useTextureView: Boolean? = args["useTextureView"] as Boolean?
    val directDownloadNetworkType =
      (args["directDownloadNetworkType"] as List<*>?)?.asList<Int>()?.toIntArray()
    val paid: Boolean? = args["paid"] as Boolean?
    val titleBarThemeIndex: Int? = args["titleBarTheme"] as Int?
    val isCanUseLocation: Boolean? = args["isCanUseLocation"] as Boolean?
    val isCanUsePhoneState: Boolean? = args["isCanUsePhoneState"] as Boolean?
    val isCanUseWriteExternal: Boolean? = args["isCanUseWriteExternal"] as Boolean?
    val isCanUseWifiState: Boolean? = args["isCanUseWifiState"] as Boolean?
    val devImei: String? = args["devImei"] as String?
    val devOaid: String? = args["devOaid"] as String?
    val location = args["location"]?.asMap<String, Double>()
    var ttLocation: TTLocation? = null
    location?.also {
      try {
        val latitude = it["latitude"]!!
        val longitude = it["longitude"]!!
        ttLocation = TTLocation(latitude, longitude)
      } catch (e: Exception) {
      }
    }

    var titleBarTheme: Int? = null
    if (titleBarThemeIndex != null) {
      titleBarTheme = PangleTitleBarTheme.entries.getOrNull(titleBarThemeIndex)?.value
    }

    //强烈建议在应用对应的Application#onCreate()方法中调用，避免出现content为null的异常
    val packageManager = context.packageManager
    val applicationContext = context.applicationContext
    val pkgInfo: PackageInfo = packageManager.getPackageInfo(applicationContext.packageName, 0)
    //获取应用名
    val appName = pkgInfo.applicationInfo?.loadLabel(packageManager)?.toString() ?: ""

    val config = TTAdConfig.Builder().apply {
      appName(appName)
      appId(appId)
      debug?.also {
        debug(it)
      }
      if (titleBarTheme == null) {
        titleBarTheme(TTAdConstant.TITLE_BAR_THEME_LIGHT)
      } else {
        titleBarTheme(titleBarTheme)
      }

      allowShowNotify?.also {
        allowShowNotify(it)
      }
      directDownloadNetworkType?.also {
        directDownloadNetworkType(*it)
      }
      supportMultiProcess?.also {
        supportMultiProcess(it)
      }

      paid?.also {
        paid(it)
      }

      //      httpStack(OKHttpStack())

      customController(object : TTCustomController() {
        override fun isCanUseLocation(): Boolean {
          return isCanUseLocation ?: super.isCanUseLocation
        }

        override fun isCanUsePhoneState(): Boolean {
          return isCanUsePhoneState ?: super.isCanUsePhoneState
        }

        override fun isCanUseWriteExternal(): Boolean {
          return isCanUseWriteExternal ?: super.isCanUseWriteExternal
        }

        override fun isCanUseWifiState(): Boolean {
          return isCanUseWifiState ?: super.isCanUseWifiState
        }

        override fun getDevImei(): String? {
          return devImei ?: super.devImei
        }

        override fun getTTLocation(): LocationProvider? {
          return ttLocation ?: super.ttLocation
        }

        // 修改后，返回String?
        override fun getDevOaid(): String? {
          return devOaid ?: super.devOaid
        }
      })

    }.build()

    // Pangle 7.x 拆分为两步：init(配置) + start(启动)
    val configured = TTAdSdk.init(applicationContext, config)
    if (!configured) {
      callback(mapOf("code" to -1, "message" to "init failed"))
      return
    }
    TTAdSdk.start(object : TTAdSdk.Callback {
      override fun success() {
        ttAdManager = TTAdSdk.getAdManager()
        ttAdNative = ttAdManager?.createAdNative(context.applicationContext)
        callback(mapOf("code" to 0, "message" to ""))
      }

      override fun fail(code: Int, message: String?) {
        callback(mapOf("code" to code, "message" to (message ?: "")))
      }
    })
  }

  fun requestPermissionIfNecessary(context: Context) {
    ttAdManager?.requestPermissionIfNecessary(context)
  }

  fun loadSplashAd(
    adSlot: AdSlot,
    listener: TTAdNative.CSJSplashAdListener,
    timeout: Double? = 5.0,
    onNotInitialized: (() -> Unit)? = null
  ) {
    if (ttAdNative == null) {
      onNotInitialized?.invoke()
      return
    }
    val second = timeout ?: 5.0
    ttAdNative?.loadSplashAd(adSlot, listener, (second * 1000).toInt())
  }

  fun loadRewardVideoAd(
    adSlot: AdSlot,
    activity: Activity?,
    loadingType: PangleLoadingType,
    result: (Any) -> Unit = {}
  ) {
    if (activity == null) {
      result(mapOf("code" to ERROR_CODE_NO_ACTIVITY, "message" to ERROR_MSG_NO_ACTIVITY))
      return
    }

    // Remember the slot so showRewardedVideoAd can trigger an auto-refill after
    // the cached queue drains.
    if (loadingType == PangleLoadingType.preload || loadingType == PangleLoadingType.preload_only) {
      preloadRewardedSlots[adSlot.codeId] = adSlot
    }

    ttAdNative?.loadRewardVideoAd(
      adSlot,
      FLTRewardedVideoAd(adSlot.codeId, activity, loadingType, result)
    )
  }


  /** 信息流模板广告（Feed Express Ad），对应 Dart 侧 loadFeedAd */
  fun loadFeedExpressAd(adSlot: AdSlot, result: (Any) -> Unit) {
    ttAdNative?.loadNativeExpressAd(adSlot, FLTFeedExpressAd(result))
  }

  /** 插屏模板广告（Native Express Interstitial Ad），对应 Dart 侧 loadInterstitialAd */
  fun loadNativeExpressAd(adSlot: AdSlot, result: (Any) -> Unit) {
    ttAdNative?.loadNativeExpressAd(adSlot, FLTFeedExpressAd(result))
  }

  fun loadBannerExpressAd(adSlot: AdSlot, listener: TTAdNative.NativeExpressAdListener) {
    ttAdNative?.loadBannerExpressAd(adSlot, listener)
  }

  internal fun loadBanner2ExpressAd(adSlot: AdSlot, result: (Any) -> Unit) {
    ttAdNative?.loadBannerExpressAd(adSlot, FLTBannerExpressAd(result))
  }

  fun loadInteractionAd(adSlot: AdSlot, listener: TTAdNative.NativeAdListener) {
    ttAdNative?.loadNativeAd(adSlot, listener)
  }

  fun loadFullscreenVideoAd(
    adSlot: AdSlot,
    activity: Activity?,
    loadingType: PangleLoadingType,
    result: (Any) -> Unit
  ) {
    if (activity == null) {
      result(mapOf("code" to ERROR_CODE_NO_ACTIVITY, "message" to ERROR_MSG_NO_ACTIVITY))
      return
    }

    if (loadingType == PangleLoadingType.preload || loadingType == PangleLoadingType.preload_only) {
      preloadFullScreenSlots[adSlot.codeId] = adSlot
    }

    ttAdNative?.loadFullScreenVideoAd(
      adSlot,
      FLTFullScreenVideoAd(adSlot.codeId, activity, loadingType, result)
    )
  }

  fun loadBannerAd(adSlot: AdSlot, listener: TTAdNative.NativeAdListener) {
    ttAdNative?.loadNativeAd(adSlot, listener)
  }

}

