package io.github.nullptrx.pangleflutter.view

import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
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
import io.github.nullptrx.pangleflutter.util.asMap

class FlutterSplashView(val context: Context, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.SplashAdListener, TTSplashAd.AdInteractionListener {

  private val methodChannel: MethodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_splashview_$id")
  private val container: FrameLayout
  private var hideSkipButton = false

  init {
    methodChannel.setMethodCallHandler(this)
    container = FrameLayout(context)
    val slotId = params["slotId"] as? String
    if (slotId != null) {
      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      val tolerateTimeout = params["tolerateTimeout"] as Double?
      hideSkipButton = params["hideSkipButton"] as? Boolean ?: false

      val imgArgs: Map<String, Int?> = params["imageSize"]?.asMap() ?: mapOf()
      val w: Int = imgArgs["width"] ?: 1080
      val h: Int = imgArgs["height"] ?: 1920
      val imgSize = TTSize(w, h)
      val adSlot = PangleAdSlotManager.getSplashAdSlot(slotId, imgSize, isSupportDeepLink)
      PangleAdManager.shared.loadSplashAd(adSlot, this, timeout = tolerateTimeout)
    }
  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    container.removeAllViews()
  }

  override fun onError(code: Int, message: String?) {
    postMessage("onError", mapOf("message" to message, "code" to code))
  }

  override fun onTimeout() {
    postMessage("onError", mapOf("message" to "timeout", "code" to -1))
  }

  override fun onSplashAdLoad(splashAd: TTSplashAd) {
    splashAd.apply {

      if (hideSkipButton) {
        setNotAllowSdkCountdown()
      }

      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT).apply {
        gravity = Gravity.CENTER
      }
      container.addView(splashView, params)

      setSplashInteractionListener(this@FlutterSplashView)

    }

  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    when (call.method) {
      else -> result.notImplemented()
    }
  }


  override fun onAdClicked(view: View, type: Int) {
    postMessage("onClick")
  }

  override fun onAdSkip() {
    postMessage("onSkip")
  }

  override fun onAdShow(view: View?, type: Int) {
    postMessage("onShow")
  }

  override fun onAdTimeOver() {
    postMessage("onTimeOver")
  }

  private fun postMessage(method: String, arguments: Map<String, Any?> = mapOf()) {
    methodChannel.invokeMethod(method, arguments)
  }
}

