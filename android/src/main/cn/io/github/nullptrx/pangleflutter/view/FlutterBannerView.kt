package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.asMap

class FlutterBannerView(val activity: Activity, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.NativeExpressAdListener,
    TTNativeExpressAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

  private val methodChannel: MethodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_bannerview_$id")
  private val container: FrameLayout
  private val context: Context
  private var interval: Int? = null
  private var ttAdNative: TTNativeExpressAd? = null


  init {
    methodChannel.setMethodCallHandler(this)
    context = activity
    container = FrameLayout(context)

    val slotId = params["slotId"] as? String
    if (slotId != null) {

      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      interval = params["interval"] as Int?


      val expressArgs: Map<String, Double> = params["expressSize"]?.asMap() ?: mapOf()
      val w: Float = expressArgs.getValue("width").toFloat()
      val h: Float = expressArgs.getValue("height").toFloat()
      val expressSize = TTSizeF(w, h)
      val adSlot = PangleAdSlotManager.getBannerAdSlot(slotId, expressSize, 1, isSupportDeepLink)
      PangleAdManager.shared.loadBannerExpressAd(adSlot, this)
    }
  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    ttAdNative?.destroy()
    container.removeAllViews()
  }

  override fun onError(code: Int, message: String?) {
    postMessage("onError", mapOf("message" to message, "code" to code))
  }

  override fun onNativeExpressAdLoad(ttNativeExpressAds: MutableList<TTNativeExpressAd>?) {
    if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
      return
    }

    val ad = ttNativeExpressAds[0]
    ttAdNative = ad
    //设置广告互动监听回调
    ad.setExpressInteractionListener(this)

    //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
    ad.setDislikeCallback(activity, this)
    // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
    interval?.also {
      ad.setSlideIntervalTime(it)
    }

    container.removeAllViews()
    val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
    val expressAdView = ad.expressAdView
    container.addView(expressAdView, params)
//      container.addView(expressAdView)
    ad.render()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
  }


  override fun onAdDismiss() {
  }

  override fun onAdClicked(view: View, type: Int) {
    postMessage("onClick")
  }

  override fun onAdShow(view: View, type: Int) {
    postMessage("onShow")
  }

  override fun onRenderSuccess(view: View, width: Float, height: Float) {
    postMessage("onRenderSuccess")
  }

  override fun onRenderFail(view: View, message: String?, code: Int) {
    postMessage("onRenderFail", mapOf("message" to message, "code" to code))
  }

  override fun onShow() {

  }

  override fun onSelected(index: Int, option: String?, enforce: Boolean) {
    //用户选择不喜欢原因后，移除广告展示
    postMessage("onDislike", mapOf("option" to option, "enforce" to enforce))
  }

  override fun onCancel() {
  }

  private fun postMessage(method: String, arguments: Map<String, Any?> = mapOf()) {
    methodChannel.invokeMethod(method, arguments)
  }
}

