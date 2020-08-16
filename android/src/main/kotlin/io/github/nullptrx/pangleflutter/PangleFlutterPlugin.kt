package io.github.nullptrx.pangleflutter

import android.app.Activity
import android.content.Context
import com.bytedance.sdk.openadsdk.TTLocation
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.github.nullptrx.pangleflutter.common.PangleTitleBarTheme
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialAd
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTSplashAd
import io.github.nullptrx.pangleflutter.util.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.view.BannerViewFactory
import io.github.nullptrx.pangleflutter.view.FeedViewFactory

/** PangleFlutterPlugin */
public class PangleFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  companion object {
    val kDefaultFeedAdCount = 3

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "pangle_flutter")
      channel.setMethodCallHandler(PangleFlutterPlugin())
    }
  }

  private var methodChannel: MethodChannel? = null
  private var activity: Activity? = null
  private var context: Context? = null
  private var bannerViewFactory: BannerViewFactory? = null
  private var feedViewFactory: FeedViewFactory? = null

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    feedViewFactory?.attachActivity(binding.activity)
    bannerViewFactory?.attachActivity(binding.activity)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    feedViewFactory?.attachActivity(binding.activity)
    bannerViewFactory?.attachActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    feedViewFactory?.detachActivity()
    bannerViewFactory?.detachActivity()
    activity = null
  }

  override fun onDetachedFromActivity() {
    feedViewFactory?.detachActivity()
    bannerViewFactory?.detachActivity()
    activity = null
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    val channelName = "nullptrx.github.io/pangle"
    context = binding.applicationContext

    methodChannel = MethodChannel(binding.binaryMessenger, channelName)
    methodChannel?.setMethodCallHandler(this)

    bannerViewFactory = BannerViewFactory(binding.binaryMessenger)
    binding.platformViewRegistry.registerViewFactory("nullptrx.github.io/pangle_bannerview",
        bannerViewFactory)
    feedViewFactory = FeedViewFactory(binding.binaryMessenger)
    binding.platformViewRegistry.registerViewFactory("nullptrx.github.io/pangle_feedview",
        feedViewFactory)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel?.setMethodCallHandler(null)
    methodChannel = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    activity ?: return
    val pangle = PangleAdManager.shared
    when (call.method) {
      "init" -> {
        try {
          val appId = call.argument<String>("appId")!!
          val debug = call.argument<Boolean?>("debug")
          val allowShowNotify = call.argument<Boolean?>("allowShowNotify")
          val allowShowPageWhenScreenLock = call.argument<Boolean?>("allowShowPageWhenScreenLock")
          val supportMultiProcess = call.argument<Boolean?>("supportMultiProcess")
          val useTextureView = call.argument<Boolean?>("useTextureView")
          val directDownloadNetworkType = call.argument<Int?>("directDownloadNetworkType")
          val isPaidApp = call.argument<Boolean?>("isPaidApp")
          val titleBarThemeIndex = call.argument<Int?>("titleBarTheme")
          val isCanUseLocation = call.argument<Boolean?>("isCanUseLocation")
          val isCanUsePhoneState = call.argument<Boolean?>("isCanUsePhoneState")
          val isCanUseWriteExternal = call.argument<Boolean?>("isCanUseWriteExternal")
          val isCanUseWifiState = call.argument<Boolean?>("isCanUseWifiState")
          val devImei = call.argument<String?>("devImei")
          val devOaid = call.argument<String?>("devOaid")
          val location = call.argument<Map<String, Double>?>("location")
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
          pangle.initialize(activity, appId, debug, useTextureView, titleBarTheme, allowShowNotify, allowShowPageWhenScreenLock, directDownloadNetworkType, supportMultiProcess, isPaidApp, isCanUseLocation, isCanUsePhoneState, isCanUseWriteExternal, isCanUseWifiState, devImei, devOaid, ttLocation)
        } catch (e: Exception) {
        }
        result.success(null)
      }

      "requestPermissionIfNecessary" -> {
        context?.also {
          pangle.requestPermissionIfNecessary(it)
        }
      }
      "loadSplashAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val tolerateTimeout = call.argument<Float>("tolerateTimeout")
        val hideSkipButton = call.argument<Boolean>("hideSkipButton")
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val adSlot = PangleAdSlotManager.getSplashAdSlot(slotId, isExpress, activity, isSupportDeepLink)
        pangle.loadSplashAd(adSlot, FLTSplashAd(hideSkipButton, activity), tolerateTimeout)
        result.success(null)
      }
      "loadRewardVideoAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val userId = call.argument<String>("userId")
        val rewardName = call.argument<String>("rewardName")
        val rewardAmount = call.argument<Int>("rewardAmount")
        val extra = call.argument<String>("extra")
        val isVertical = call.argument<Boolean>("isVertical") ?: true
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val adSlot = PangleAdSlotManager.getRewardVideoAdSlot(slotId, isExpress, userId, rewardName, rewardAmount, isVertical, isSupportDeepLink, extra)
        pangle.loadRewardVideoAd(adSlot, result, activity)
      }

      "loadFeedAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val count = call.argument<Int>("count") ?: kDefaultFeedAdCount
        val imgSizeIndex = call.argument<Int>("imgSize")!!
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val adSlot = PangleAdSlotManager.getFeedAdSlot(slotId, isExpress, count, imgSizeIndex, isSupportDeepLink)
        if (isExpress) {
          pangle.loadFeedExpressAd(adSlot, result)
        } else {
          pangle.loadFeedAd(adSlot, result)
        }

      }

      "loadInterstitialAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val imgSizeIndex = call.argument<Int>("imgSize")!!
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isNativeAd = call.argument<Boolean>("isNativeAd") ?: false
        val adSlot = PangleAdSlotManager.getInterstitialAdSlot(slotId, isExpress, imgSizeIndex, isSupportDeepLink, isNativeAd)
        if (isExpress) {
          pangle.loadInteractionExpressAd(adSlot, FLTInterstitialExpressAd(result, activity))
        } else {
          pangle.loadInteractionAd(adSlot, FLTInterstitialAd(result, activity))
        }
      }
      else -> result.notImplemented()
    }

  }
}
