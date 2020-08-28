package io.github.nullptrx.pangleflutter

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.github.nullptrx.pangleflutter.common.*
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialAd
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTSplashAd
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.asMap
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

          pangle.initialize(activity, call.arguments.asMap() ?: mapOf())
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
        val loadAwait = call.argument<Boolean>("loadAwait") ?: true
        val adSlot = PangleAdSlotManager.getSplashAdSlot(slotId, isExpress, activity, isSupportDeepLink)
        pangle.loadSplashAd(adSlot, FLTSplashAd(hideSkipButton, activity) {
          if (loadAwait) {
            result.success(null)
          }
        }, tolerateTimeout)
        if (!loadAwait) {
          result.success(null)
        }
      }
      "loadRewardVideoAd" -> {

        val loadingTypeIndex = call.argument<Int>("loadingType") ?: 0
        var loadingType = PangleLoadingType.values()[loadingTypeIndex]


        if (PangleLoadingType.preload == loadingType || PangleLoadingType.normal == loadingType) {

          val loadResult = pangle.showRewardedVideoAd(result, activity)
          if (loadResult) {
            if (loadingType == PangleLoadingType.normal) {
              return
            }
          } else {
            loadingType = PangleLoadingType.normal
          }

        } else {
          result.success(null)
        }
        val preload = PangleLoadingType.preload == loadingType || PangleLoadingType.preload_only == loadingType

        val slotId = call.argument<String>("slotId")!!
        val userId = call.argument<String>("userId")
        val rewardName = call.argument<String>("rewardName")
        val rewardAmount = call.argument<Int>("rewardAmount")
        val extra = call.argument<String>("extra")
        val isVertical = call.argument<Boolean>("isVertical") ?: true
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val adSlot = PangleAdSlotManager.getRewardVideoAdSlot(slotId, isExpress, userId, rewardName, rewardAmount, isVertical, isSupportDeepLink, extra)

        pangle.loadRewardVideoAd(adSlot, result, activity, preload)
        if (PangleLoadingType.preload_only == loadingType) {
          result.success(null)
        }
      }

      "loadFeedAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val count = call.argument<Int>("count") ?: kDefaultFeedAdCount
        val imgSizeIndex = call.argument<Int>("imgSize")!!
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false

        var size: TTSizeF? = null
        if (isExpress) {
          val expectSize = call.argument<Map<String, Double>>("expectSize") ?: mapOf()

          val pangleImgSize = PangleImgSize.values()[imgSizeIndex]
          var w: Float? = expectSize["width"]?.toFloat()
          var h: Float? = expectSize["height"]?.toFloat()
          val aspectRatio = pangleImgSize.width * 1.0f / pangleImgSize.height
          if (w == null && h == null) {
            w = ScreenUtil.getScreenWidthDp() - kDoublePadding
            h = w / aspectRatio
          } else if (w == null) {
            checkNotNull(h)
            w = h * aspectRatio
          } else if (h == null) {
            checkNotNull(w)
            w -= kDoublePadding
            h = w / aspectRatio
          }
          size = TTSizeF(w.toFloat(), h.toFloat())
        }
        val adSlot = PangleAdSlotManager.getFeedAdSlot(slotId, isExpress, count, imgSizeIndex, isSupportDeepLink, size)
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
          pangle.loadInteractionExpressAd(adSlot, FLTInterstitialExpressAd(activity) {
            result.success(it)
          })
        } else {
          pangle.loadInteractionAd(adSlot, FLTInterstitialAd(activity) {
            result.success(it)
          })
        }
      }

      "loadFullscreenVideoAd" -> {

        val loadingTypeIndex = call.argument<Int>("loadingType") ?: 0
        var loadingType = PangleLoadingType.values()[loadingTypeIndex]


        if (PangleLoadingType.preload == loadingType || PangleLoadingType.normal == loadingType) {

          val loadResult = pangle.showFullScreenVideoAd(result, activity)
          if (loadResult) {
            if (loadingType == PangleLoadingType.normal) {
              return
            }
          } else {
            loadingType = PangleLoadingType.normal
          }

        } else {
          result.success(null)
        }

        val preload = PangleLoadingType.preload == loadingType || PangleLoadingType.preload_only == loadingType

        val slotId = call.argument<String>("slotId")!!
//        val isVertical = call.argument<Boolean>("isVertical") ?: true
        val orientationIndex = call.argument<Int>("orientation")
            ?: PangleOrientation.veritical.ordinal
        val orientation = PangleOrientation.values()[orientationIndex]
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val adSlot = PangleAdSlotManager.getFullScreenVideoAdSlot(slotId, isExpress, orientation, isSupportDeepLink)

        pangle.loadFullscreenVideoAd(adSlot, result, activity, preload)
      }
      else -> result.notImplemented()
    }

  }
}
