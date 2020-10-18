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
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.PangleOrientation
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialAd
import io.github.nullptrx.pangleflutter.delegate.FLTInterstitialExpressAd
import io.github.nullptrx.pangleflutter.delegate.FLTSplashAd
import io.github.nullptrx.pangleflutter.util.asMap
import io.github.nullptrx.pangleflutter.view.BannerViewFactory
import io.github.nullptrx.pangleflutter.view.FeedViewFactory

/** PangleFlutterPlugin */
public class PangleFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  companion object {
    val kDefaultFeedAdCount = 3
    val kChannelName = "nullptrx.github.io/pangle"

    @JvmStatic
    fun registerWith(registrar: Registrar) {

      PangleFlutterPlugin().apply {

        val messenger = registrar.messenger()
        val activity = registrar.activity()
        this.activity = activity
        this.context = registrar.context().applicationContext

        methodChannel = MethodChannel(messenger, kChannelName)
        methodChannel?.setMethodCallHandler(this)

        bannerViewFactory = BannerViewFactory(messenger)
        registrar.platformViewRegistry().registerViewFactory("nullptrx.github.io/pangle_bannerview",
            bannerViewFactory)
        feedViewFactory = FeedViewFactory(messenger)
        registrar.platformViewRegistry().registerViewFactory("nullptrx.github.io/pangle_feedview",
            feedViewFactory)

        feedViewFactory?.attachActivity(activity)
        bannerViewFactory?.attachActivity(activity)

      }
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

    context = binding.applicationContext

    methodChannel = MethodChannel(binding.binaryMessenger, kChannelName)
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
      "getSdkVersion" -> {
        val version = pangle.getSdkVersion()
        result.success(version)
      }
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
        var expressSize: TTSizeF? = null
        if (isExpress) {
          val expressArgs = call.argument<Map<String, Double>>("expressSize") ?: mapOf()
          val w: Float = expressArgs.getValue("width").toFloat()
          val h: Float = expressArgs.getValue("height").toFloat()
          expressSize = TTSizeF(w, h)
        }
        val adSlot = PangleAdSlotManager.getSplashAdSlot(slotId, isExpress, expressSize, activity, isSupportDeepLink)
        pangle.loadSplashAd(adSlot, FLTSplashAd(hideSkipButton, activity) {
            result.success(it)
        }, tolerateTimeout)
      }
      "loadRewardedVideoAd" -> {

        val loadingTypeIndex = call.argument<Int>("loadingType") ?: 0
        var loadingType = PangleLoadingType.values()[loadingTypeIndex]


        if (PangleLoadingType.preload == loadingType || PangleLoadingType.normal == loadingType) {

          val loadResult = pangle.showRewardedVideoAd(activity) {
            result.success(it)
          }
          if (loadResult) {
            if (loadingType == PangleLoadingType.normal) {
              return
            }
          } else {
            loadingType = PangleLoadingType.normal
          }

        }

        val slotId = call.argument<String>("slotId")!!
        val userId = call.argument<String>("userId")
        val rewardName = call.argument<String>("rewardName")
        val rewardAmount = call.argument<Int>("rewardAmount")
        val extra = call.argument<String>("extra")
        val isVertical = call.argument<Boolean>("isVertical") ?: true
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        var expressSize: TTSizeF? = null
        if (isExpress) {
          val expressArgs = call.argument<Map<String, Double>>("expressSize") ?: mapOf()
          val w: Float = expressArgs.getValue("width").toFloat()
          val h: Float = expressArgs.getValue("height").toFloat()
          expressSize = TTSizeF(w, h)
        }
        val adSlot = PangleAdSlotManager.getRewardVideoAdSlot(slotId, isExpress, expressSize, userId, rewardName, rewardAmount, isVertical, isSupportDeepLink, extra)

        pangle.loadRewardVideoAd(adSlot, activity, loadingType) {
          if (PangleLoadingType.preload_only == loadingType || PangleLoadingType.normal == loadingType) {
            result.success(it)
          }
        }
      }

      "loadFeedAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val count = call.argument<Int>("count") ?: kDefaultFeedAdCount
        val imgSizeIndex = call.argument<Int>("imgSize")!!
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false

        var expressSize: TTSizeF? = null
        if (isExpress) {
          val expressArgs = call.argument<Map<String, Double>>("expressSize") ?: mapOf()
          val w: Float = expressArgs.getValue("width").toFloat()
          val h: Float = expressArgs.getValue("height").toFloat()
          expressSize = TTSizeF(w, h)
        }
        val adSlot = PangleAdSlotManager.getFeedAdSlot(slotId, isExpress, expressSize, count, imgSizeIndex, isSupportDeepLink)
        if (isExpress) {
          pangle.loadFeedExpressAd(adSlot) {
            result.success(it)
          }
        } else {
          pangle.loadFeedAd(adSlot) {
            result.success(it)
          }
        }

      }

      "loadInterstitialAd" -> {
        val slotId = call.argument<String>("slotId")!!
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        val imgSizeIndex = call.argument<Int>("imgSize")!!
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true

        var expressSize: TTSizeF? = null
        if (isExpress) {
          val expressArgs = call.argument<Map<String, Double>>("expressSize") ?: mapOf()
          val w: Float = expressArgs.getValue("width").toFloat()
          val h: Float = expressArgs.getValue("height").toFloat()
          expressSize = TTSizeF(w, h)
        }

        val adSlot = PangleAdSlotManager.getInterstitialAdSlot(slotId, isExpress, expressSize, imgSizeIndex, isSupportDeepLink)
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

          val loadResult = pangle.showFullScreenVideoAd(activity) {
            result.success(it)
          }
          if (loadResult) {
            if (loadingType == PangleLoadingType.normal) {
              return
            }
          } else {
            loadingType = PangleLoadingType.normal
          }

        }

        val slotId = call.argument<String>("slotId")!!
//        val isVertical = call.argument<Boolean>("isVertical") ?: true
        val orientationIndex = call.argument<Int>("orientation")
            ?: PangleOrientation.veritical.ordinal
        val orientation = PangleOrientation.values()[orientationIndex]
        val isSupportDeepLink = call.argument<Boolean>("isSupportDeepLink") ?: true
        val isExpress = call.argument<Boolean>("isExpress") ?: false
        var expressSize: TTSizeF? = null
        if (isExpress) {
          val expressArgs = call.argument<Map<String, Double>>("expressSize") ?: mapOf()
          val w: Float = expressArgs.getValue("width").toFloat()
          val h: Float = expressArgs.getValue("height").toFloat()
          expressSize = TTSizeF(w, h)
        }
        val adSlot = PangleAdSlotManager.getFullScreenVideoAdSlot(slotId, isExpress, expressSize, orientation, isSupportDeepLink)

        pangle.loadFullscreenVideoAd(adSlot, activity, loadingType) {
          if (PangleLoadingType.preload_only == loadingType || PangleLoadingType.normal == loadingType) {
            result.success(it)
          }
        }
      }
      else -> result.notImplemented()
    }

  }
}
