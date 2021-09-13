package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdDislike.DislikeInteractionCallback
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager


class FlutterFeedView(
    val activity: Activity,
    messenger: BinaryMessenger,
    val id: Int,
    params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler, TTNativeExpressAd.ExpressAdInteractionListener, DislikeInteractionCallback {

  private val methodChannel: MethodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_feedview_$id")
  private val container: FrameLayout
  private var ttadId: String = ""

  init {
    methodChannel.setMethodCallHandler(this)
    val context: Context = activity
    container = FrameLayout(context)
    ttadId = params["id"] as String
    loadAd(ttadId)
  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    container.removeAllViews()
  }

  private fun loadAd(id: String) {
    val expressAd = PangleAdManager.shared.getExpressAd(id) ?: return
    val expressAdView = expressAd.expressAdView
    if (expressAdView.parent != null) {
      (expressAdView.parent as ViewGroup).removeView(expressAdView)
    }
    container.removeAllViews()

    val params = FrameLayout.LayoutParams(WRAP_CONTENT, WRAP_CONTENT).apply {
      gravity = Gravity.CENTER
    }
    container.addView(expressAdView, params)
    expressAd.setCanInterruptVideoPlay(true)
    expressAd.setExpressInteractionListener(this)
    expressAd.setDislikeCallback(activity, this)
    expressAd.render()

  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
  }

  override fun onAdClicked(view: View, type: Int) {
    postMessage("onClick", mapOf("type" to type))
  }

  override fun onAdShow(view: View?, type: Int) {
    postMessage("onShow")
  }

  override fun onRenderSuccess(view: View, width: Float, height: Float) {
    postMessage("onRenderSuccess")
  }

  override fun onRenderFail(view: View?, message: String?, code: Int) {
    postMessage("onRenderFail", mapOf("message" to message, "code" to code))
  }

  override fun onShow() {
  }

  override fun onSelected(index: Int, option: String?, enforce: Boolean) {
    postMessage("onDislike", mapOf("option" to option, "enforce" to enforce))
  }

  override fun onCancel() {
  }

  private fun postMessage(method: String, arguments: Map<String, Any?> = mapOf()) {
    methodChannel.invokeMethod(method, arguments)
  }
}