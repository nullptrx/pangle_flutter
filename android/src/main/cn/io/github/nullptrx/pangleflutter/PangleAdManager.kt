package io.github.nullptrx.pangleflutter

import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import com.bytedance.sdk.openadsdk.AdSlot
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
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.PangleTitleBarTheme
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.delegate.FLTBannerExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTFeedExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTFullScreenVideoAd
import io.github.nullptrx.pangleflutter.delegate.FLTRewardedVideoAd
import io.github.nullptrx.pangleflutter.delegate.FullScreenVideoAdInteractionImpl
import io.github.nullptrx.pangleflutter.delegate.RewardAdInteractionImpl
import io.github.nullptrx.pangleflutter.util.asList
import io.github.nullptrx.pangleflutter.util.asMap
import java.util.*


class PangleAdManager {

  companion object {
    val shared = PangleAdManager()
  }


  private val expressAdCollection =
    Collections.synchronizedMap(mutableMapOf<String, TTNativeExpressAd>())
  private val rewardedVideoAdData =
    Collections.synchronizedMap(mutableMapOf<String, MutableList<TTRewardVideoAd>>())
  private val fullScreenVideoAdData =
    Collections.synchronizedMap(mutableMapOf<String, MutableList<TTFullScreenVideoAd>>())

  private lateinit var ttAdManager: TTAdManager
  private var ttAdNative: TTAdNative? = null
    get() = field


  fun getSdkVersion(): String {
    return ttAdManager.sdkVersion
  }

  fun getThemeStatus(): Int {
    return ttAdManager.themeStatus
  }

  fun setThemeStatus(theme: Int) {
    ttAdManager.themeStatus = theme
  }

  /**
   * Express
   */
  fun setExpressAd(ttBannerAds: List<TTNativeExpressAd>): List<String> {
    val data = mutableListOf<String>()
    ttBannerAds.forEach {
      val key = it.hashCode().toString()
      expressAdCollection[key] = it
      data.add(key)
    }
    return data
  }

  fun getExpressAd(key: String): TTNativeExpressAd? {
    return expressAdCollection[key]
  }

  fun removeExpressAd(key: String): Boolean {
    if (expressAdCollection.containsKey(key)) {
      val it = expressAdCollection.remove(key)
      it?.destroy()
      return true
    }
    return false
  }

  fun showRewardedVideoAd(
    slotId: String,
    activity: Activity?,
    result: (Any) -> Unit = {}
  ): Boolean {
    activity ?: return false
    val data = rewardedVideoAdData[slotId] ?: mutableListOf()
    if (data.size > 0) {
      val ad = data.removeFirst()
      ad.setRewardAdInteractionListener(RewardAdInteractionImpl { obj ->
        result.invoke(obj)
      })
      ad.showRewardVideoAd(activity)
      return true
    }
    return false
  }

  fun setRewardedVideoAd(slotId: String, ad: TTRewardVideoAd?) {
    ad?.also {
      val data = rewardedVideoAdData[slotId] ?: mutableListOf()
      data.add(ad)
      rewardedVideoAdData[slotId] = data
    }
  }

  fun showFullScreenVideoAd(
    slotId: String,
    activity: Activity?,
    result: (Any) -> Unit = {}
  ): Boolean {
    activity ?: return false
    val data = fullScreenVideoAdData[slotId] ?: mutableListOf()
    if (data.size > 0) {
      val ad = data.removeFirst()
      ad.setFullScreenVideoAdInteractionListener(FullScreenVideoAdInteractionImpl { obj ->
        result.invoke(obj)
      })
      ad.showFullScreenVideoAd(activity)
      return true
    }
    return false
  }

  fun setFullScreenVideoAd(slotId: String, ad: TTFullScreenVideoAd?) {
    ad?.also {
      val data = fullScreenVideoAdData[slotId] ?: mutableListOf()
      data.add(ad)
      fullScreenVideoAdData[slotId] = data
    }
  }


  fun initialize(activity: Activity?, args: Map<String, Any?>) {
    activity ?: return
    val context: Context = activity

    val appId: String = args["appId"] as String
    val debug: Boolean? = args["debug"] as Boolean?
    val async: Boolean? = args["async"] as Boolean?
    val allowShowNotify: Boolean? = args["allowShowNotify"] as Boolean?
    val allowShowPageWhenScreenLock: Boolean? = args["allowShowPageWhenScreenLock"] as Boolean?
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
      titleBarTheme = PangleTitleBarTheme.values()[titleBarThemeIndex].value
    }

    //强烈建议在应用对应的Application#onCreate()方法中调用，避免出现content为null的异常
    val packageManager = context.packageManager
    val applicationContext = context.applicationContext
    val pkgInfo: PackageInfo = packageManager.getPackageInfo(applicationContext.packageName, 0)
    //获取应用名
    val appName = pkgInfo.applicationInfo.loadLabel(packageManager).toString()

    val config = TTAdConfig.Builder().apply {
      async?.also {
        asyncInit(it)
      }
      appName(appName)
      appId(appId)
      debug?.also {
        debug(it)
      }
      useTextureView?.also {
        useTextureView(it)
      }

      if (titleBarTheme == null) {
        titleBarTheme(TTAdConstant.TITLE_BAR_THEME_LIGHT)
      } else {
        titleBarTheme(titleBarTheme)
      }

      allowShowNotify?.also {
        allowShowNotify(it)
      }
      allowShowPageWhenScreenLock?.also {
        allowShowPageWhenScreenLock(it)
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

          return isCanUseLocation ?: true
        }

        override fun isCanUsePhoneState(): Boolean {
          return isCanUsePhoneState ?: true
        }

        override fun isCanUseWriteExternal(): Boolean {
          return isCanUseWriteExternal ?: true
        }

        override fun isCanUseWifiState(): Boolean {
          return isCanUseWifiState ?: true
        }

        override fun getDevImei(): String? {
          return devImei
        }

        override fun getTTLocation(): TTLocation? {
          return ttLocation
        }

        // 之前的问题代码，这里kotlin不会报错
//        override fun getDevOaid(): String {
//          return devOaid?:super.getDevOaid()
//        }

        // 修改后，返回String?
        override fun getDevOaid(): String? {
          return devOaid
        }
      })

    }.build()

    TTAdSdk.init(applicationContext, config)

    ttAdManager = TTAdSdk.getAdManager()
    ttAdNative = ttAdManager.createAdNative(activity)

  }

  fun requestPermissionIfNecessary(context: Context) {
    ttAdManager.requestPermissionIfNecessary(context)
  }

  fun loadSplashAd(adSlot: AdSlot, listener: TTAdNative.SplashAdListener, timeout: Double? = null) {
    if (timeout == null) {
      ttAdNative?.loadSplashAd(adSlot, listener)
    } else {
      ttAdNative?.loadSplashAd(adSlot, listener, (timeout * 1000).toInt())
    }
  }

  fun loadRewardVideoAd(
    adSlot: AdSlot,
    activity: Activity?,
    loadingType: PangleLoadingType,
    result: (Any) -> Unit = {}
  ) {

    activity ?: return


    ttAdNative?.loadRewardVideoAd(
      adSlot,
      FLTRewardedVideoAd(adSlot.codeId, activity, loadingType, result)
    )

  }


  fun loadFeedExpressAd(adSlot: AdSlot, result: (Any) -> Unit) {
    val size = TTSizeF(adSlot.expressViewAcceptedWidth, adSlot.expressViewAcceptedHeight)
    ttAdNative?.loadNativeExpressAd(adSlot, FLTFeedExpressAd(size, result))
  }

  fun loadBannerExpressAd(adSlot: AdSlot, listener: TTAdNative.NativeExpressAdListener) {
    ttAdNative?.loadBannerExpressAd(adSlot, listener)
  }

  internal fun loadBanner2ExpressAd(adSlot: AdSlot, result: (Any) -> Unit) {
    ttAdNative?.loadBannerExpressAd(adSlot, FLTBannerExpressAd(result))
  }

  fun loadInteractionExpressAd(adSlot: AdSlot, listener: TTAdNative.NativeExpressAdListener) {
    ttAdNative?.loadInteractionExpressAd(adSlot, listener)
  }

  fun loadNativeExpressAd(adSlot: AdSlot, listener: TTAdNative.NativeExpressAdListener) {
    ttAdNative?.loadNativeExpressAd(adSlot, listener)
  }

  fun loadFullscreenVideoAd(
    adSlot: AdSlot,
    activity: Activity?,
    loadingType: PangleLoadingType,
    result: (Any) -> Unit
  ) {

    activity ?: return

    ttAdNative?.loadFullScreenVideoAd(
      adSlot,
      FLTFullScreenVideoAd(adSlot.codeId, activity, loadingType, result)
    )

  }

  fun loadBannerAd(adSlot: AdSlot, listener: TTAdNative.BannerAdListener) {
    ttAdNative?.loadBannerAd(adSlot, listener)
  }

}

