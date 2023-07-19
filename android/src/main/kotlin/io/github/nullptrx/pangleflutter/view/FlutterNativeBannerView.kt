/*
 * Copyright (c) 2022 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdConstant
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTBannerAd
import com.bytedance.sdk.openadsdk.TTNativeAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.util.asMap

class FlutterNativeBannerView(
  val activity: Activity, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.NativeAdListener,
  TTNativeAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback,
  TTNativeAd.ExpressRenderListener {

  private val methodChannel: MethodChannel =
    MethodChannel(messenger, "nullptrx.github.io/pangle_nativebannerview_$id")
  private val context: Context
  private val container: FrameLayout
  private var ttAdNative: TTNativeAd? = null


  init {
    methodChannel.setMethodCallHandler(this)
    context = activity
    container = FrameLayout(context)

    val slotId = params["slotId"] as? String
    if (slotId != null) {

      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true

      val expressArgs: Map<String, Double> = params["size"]?.asMap() ?: mapOf()
      val w: Int = expressArgs.getValue("width").toInt()
      val h: Int = expressArgs.getValue("height").toInt()
      val size = TTSize(w, h)
      val adSlot =
        PangleAdSlotManager.getNativeBannerAdSlot(slotId, size, 1, isSupportDeepLink)
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

  override fun onNativeAdLoad(ads: MutableList<TTNativeAd>?) {
    if (ads.isNullOrEmpty()) {
      return
    }
    val ad = ads[0]
    ttAdNative = ad //设置广告互动监听回调
    ad.setExpressRenderListener(this)
    ad.setDislikeCallback(activity, this)

    ad.registerViewForInteraction(container, ad.adView, this)
    container.removeAllViews()
    val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
    val bannerView = ad.adView
    container.addView(bannerView, params)
    ad.render()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
  }

  override fun onAdClicked(view: View?, ad: TTNativeAd?) {
    postMessage("onClick")
  }

  override fun onAdCreativeClick(view: View?, ad: TTNativeAd?) {
  }

  override fun onAdShow(ad: TTNativeAd?) {
    postMessage("onShow")
  }

  override fun onShow() {
  }

  override fun onSelected(index: Int, option: String?, enforce: Boolean) { //用户选择不喜欢原因后，移除广告展示
    postMessage("onDislike", mapOf("option" to option, "enforce" to enforce))
  }

  override fun onCancel() {
  }

  private fun postMessage(method: String, arguments: Map<String, Any?> = mapOf()) {
    Handler(Looper.getMainLooper()).post {
      methodChannel.invokeMethod(method, arguments)
    }
  }

  override fun onRenderSuccess(view: View?, width: Float, height: Float, isExpress: Boolean) {

  }
}

