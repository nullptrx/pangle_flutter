package io.github.nullptrx.pangleflutter.view

import android.content.Context
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTBannerAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.util.asMap

class FlutterNativeBannerView(val context: Context, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.BannerAdListener,
    TTBannerAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

  private val methodChannel: MethodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_nativebannerview_$id")
  private val container: FrameLayout
  private var interval: Int? = null
  private var ttAdNative: TTBannerAd? = null


  init {
    methodChannel.setMethodCallHandler(this)
    container = FrameLayout(context)

    val slotId = params["slotId"] as? String
    if (slotId != null) {

      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      interval = params["interval"] as Int?


      val expressArgs: Map<String, Double> = params["size"]?.asMap() ?: mapOf()
      val w: Int = expressArgs.getValue("width").toInt()
      val h: Int = expressArgs.getValue("height").toInt()
      val size = TTSize(w, h)
      val adSlot = PangleAdSlotManager.getNativeBannerAdSlot(slotId, size, 1, isSupportDeepLink)
      PangleAdManager.shared.loadBannerAd(adSlot, this)
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

  override fun onBannerAdLoad(ad: TTBannerAd) {
    ttAdNative = ad
    //设置广告互动监听回调
    ad.setBannerInteractionListener(this)

    //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
    ad.setShowDislikeIcon(this)
    // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
    interval?.also {
      ad.setSlideIntervalTime(it)
    }
    container.removeAllViews()
    val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
    val bannerView = ad.bannerView
    container.addView(bannerView, params)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
  }

  override fun onAdClicked(view: View, type: Int) {
    postMessage("onClick")
  }

  override fun onAdShow(view: View, type: Int) {
    postMessage("onShow")
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

