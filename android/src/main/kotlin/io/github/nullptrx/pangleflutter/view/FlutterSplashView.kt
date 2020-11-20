package io.github.nullptrx.pangleflutter.view

import android.content.Context
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTSplashAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.asMap
import io.github.nullptrx.pangleflutter.util.dp

class FlutterSplashView(val context: Context, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.SplashAdListener {

  private val methodChannel: MethodChannel
  private val container: FrameLayout
  private var expressSize = TTSizeF()
  private var imgSize = TTSize()
  private var isExpress: Boolean = false
  private var hideSkipButton = false

  init {
    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_splashview_$id")
    methodChannel.setMethodCallHandler(this)
    container = FrameLayout(context)
//    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)

//    println("BannerView: init ${Date().toGMTString()}")


    val slotId = params["slotId"] as? String
    if (slotId != null) {

      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      isExpress = params["isExpress"] as? Boolean ?: false
      val tolerateTimeout = params["tolerateTimeout"] as Float?
      hideSkipButton = params["hideSkipButton"] as? Boolean ?: false

      if (isExpress) {
        val expressArgs: Map<String, Double> = params["expressSize"]?.asMap() ?: mapOf()
        val w: Float = expressArgs.getValue("width").toFloat()
        val h: Float = expressArgs.getValue("height").toFloat()
        expressSize = TTSizeF(w, h)
      } else {
        val imgArgs: Map<String, Double> = params["imageSize"]?.asMap() ?: mapOf()
        val w: Int = imgArgs.getValue("width").toInt()
        val h: Int = imgArgs.getValue("height").toInt()
        imgSize = TTSize(w, h)
      }
      val adSlot = PangleAdSlotManager.getSplashAdSlot(slotId, isExpress, imgSize, expressSize, isSupportDeepLink)
      if (isExpress) {
        PangleAdManager.shared.loadSplashAd(adSlot, this, timeout = tolerateTimeout)
      } else {
        PangleAdManager.shared.loadSplashAd(adSlot, this, timeout = tolerateTimeout)
      }
    }
    if (isExpress) {
      invalidateView(expressSize.width, expressSize.height)
    } else {
      invalidateView(imgSize.width, imgSize.height)
    }
  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    container.removeAllViews()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    when (call.method) {
      else -> result.notImplemented()
    }
  }

  private fun invalidateView(width: Int, height: Int) {
    val screenWidth = ScreenUtil.getScreenWidthDp()
    val splashHeight = screenWidth * height / width

    container.layoutParams = FrameLayout.LayoutParams(screenWidth.dp, splashHeight.dp).apply {
      gravity = Gravity.CENTER
    }
  }

  private fun invalidateView(width: Float, height: Float) {
//    val screenWidth = ScreenUtil.getScreenWidthDp()
//    val bannerHeight = screenWidth * height / width

    container.layoutParams = FrameLayout.LayoutParams(width.dp, height.dp).apply {
      gravity = Gravity.CENTER
    }
  }

  override fun onError(code: Int, message: String?) {
    invokeAction(code, message ?: "")
  }

  override fun onTimeout() {
    invokeAction(-1, "timeout")
  }

  override fun onSplashAdLoad(splashAd: TTSplashAd) {
    splashAd.apply {

      if (hideSkipButton) {
        setNotAllowSdkCountdown()
      }

      container.addView(splashView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)

      setSplashInteractionListener(object : TTSplashAd.AdInteractionListener {
        override fun onAdClicked(view: View, type: Int) {
          invokeAction(0, "click")
        }

        override fun onAdSkip() {
          invokeAction(0, "skip")
        }

        override fun onAdShow(view: View?, type: Int) {
          invokeAction(0, "show")
        }

        override fun onAdTimeOver() {
          invokeAction(0, "timeover")
        }

      })

    }

  }


  fun invokeAction(code: Int = 0, message: String = "") {
    val params = mutableMapOf<String, Any>()
    params["code"] = code
    params["message"] = message
    methodChannel.invokeMethod("action", params)
  }

}

