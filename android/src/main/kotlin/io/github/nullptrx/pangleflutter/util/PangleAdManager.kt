package io.github.nullptrx.pangleflutter.util

import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import com.bytedance.sdk.openadsdk.*
import io.flutter.plugin.common.MethodChannel
import io.github.nullptrx.pangleflutter.delegate.FLTFeedAd
import io.github.nullptrx.pangleflutter.delegate.FLTRewardedVideoAd
import java.util.*


class PangleAdManager {

  companion object {
    val shared = PangleAdManager()

  }

  private val feedAdCollection = Collections.synchronizedMap<String, TTFeedAd>(mutableMapOf<String, TTFeedAd>())

  private var ttAdManager: TTAdManager? = null
  private var ttAdNative: TTAdNative? = null
    get() = field


  fun setFeedAd(ttFeedAds: List<TTFeedAd>): List<String> {
    val data = mutableListOf<String>()
    ttFeedAds.forEach {
      val key = it.hashCode().toString()
      feedAdCollection[key] = it
      data.add(key)
    }
    return data
  }

  fun getFeedAd(tag: String): TTFeedAd? {
    val feedAd = feedAdCollection[tag]
    return feedAd
  }

  fun removeFeedAd(key: String) {
    feedAdCollection.remove(key)
  }

  fun initialize(activity: Activity?, appId: String, debug: Boolean?, useTextureView: Boolean?, titleBarTheme: Int?, allowShowNotify: Boolean?, allowShowPageWhenScreenLock: Boolean?, directDownloadNetworkType: Int?, supportMultiProcess: Boolean?, paid: Boolean?) {
    activity ?: return
    val context: Context = activity

    //强烈建议在应用对应的Application#onCreate()方法中调用，避免出现content为null的异常
    val packageManager = context.packageManager
    val applicationContext = context.applicationContext
    val pkgInfo: PackageInfo = packageManager.getPackageInfo(applicationContext.packageName, 0)
    //获取应用名
    val appName = pkgInfo.applicationInfo.loadLabel(packageManager).toString()

    val config = TTAdConfig.Builder().apply {
      appName(appName)
      appId(appId)
      debug?.also {
        debug(it)
      }
      useTextureView?.also {
        useTextureView(it)
      }

      titleBarTheme?.also {
        titleBarTheme(it)
      }
      titleBarTheme(TTAdConstant.TITLE_BAR_THEME_LIGHT)

      allowShowNotify?.also {
        allowShowNotify(it)
      }
      allowShowPageWhenScreenLock?.also {
        allowShowPageWhenScreenLock(it)
      }
      directDownloadNetworkType?.also {
        directDownloadNetworkType(it)
      }
      supportMultiProcess?.also {
        supportMultiProcess(it)
      }
      paid?.also {
        paid(it)
      }

    }.build()

    TTAdSdk.init(applicationContext, config)

    ttAdManager = TTAdSdk.getAdManager()
    ttAdNative = ttAdManager?.createAdNative(activity)

  }

  fun loadSplashAd(adSlot: AdSlot, listener: TTAdNative.SplashAdListener, timeout: Float? = null) {
    if (timeout == null) {
      ttAdNative?.loadSplashAd(adSlot, listener)
    } else {
      ttAdNative?.loadSplashAd(adSlot, listener, (timeout * 1000).toInt())
    }

  }

  fun loadRewardVideoAd(adSlot: AdSlot, result: MethodChannel.Result, activity: Activity?) {

    activity ?: return

    ttAdNative?.loadRewardVideoAd(adSlot, FLTRewardedVideoAd(result, activity))

  }

  fun loadFeedAd(adSlot: AdSlot, result: MethodChannel.Result) {
    ttAdNative?.loadFeedAd(adSlot, FLTFeedAd(result))
  }


  fun loadBannerAd(adSlot: AdSlot, listener: TTAdNative.BannerAdListener) {
    ttAdNative?.loadBannerAd(adSlot, listener)
  }

  fun requestPermissionIfNecessary(context: Context) {
    ttAdManager?.requestPermissionIfNecessary(context)
  }

}