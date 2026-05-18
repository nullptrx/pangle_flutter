package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTFeedAd
import com.bytedance.sdk.openadsdk.TTNativeAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.PangleAdSlotManager

class FlutterEcMallView(
  val activity: Activity, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler, TTAdNative.FeedAdListener {

  private val methodChannel: MethodChannel =
    MethodChannel(messenger, "nullptrx.github.io/pangle_ecmallview_$id")
  private val mainHandler = Handler(Looper.getMainLooper())
  private val context: Context = activity
  private val container: FrameLayout = FrameLayout(context)
  private var ttFeedAd: TTFeedAd? = null
  private var isDisposed = false

  init {
    methodChannel.setMethodCallHandler(this)

    val slotId = params["slotId"] as? String
    if (slotId != null) {
      val width = (params["width"] as? Double)?.toFloat() ?: 0f
      val height = (params["height"] as? Double)?.toFloat() ?: 0f
      val userData = params["userData"] as? String
      val adSlot = PangleAdSlotManager.getEcMallAdSlot(slotId, width, height, userData)
      PangleAdManager.shared.loadEcMallAd(adSlot, this)
    }
  }

  override fun getView(): View = container

  override fun dispose() {
    isDisposed = true
    methodChannel.setMethodCallHandler(null)
    ttFeedAd?.destroy()
    ttFeedAd = null
    container.removeAllViews()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {}

  override fun onError(code: Int, message: String?) {
    if (isDisposed) return
    postMessage("onError", mapOf("code" to code, "message" to (message ?: "")))
  }

  override fun onFeedAdLoad(ads: MutableList<TTFeedAd>?) {
    if (isDisposed) return
    if (ads.isNullOrEmpty()) return
    val ad = ads[0]
    ttFeedAd = ad

    val adView = ad.adView ?: return
    container.removeAllViews()
    container.addView(adView, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))

    ad.registerViewForInteraction(
      container, container,
      object : TTNativeAd.AdInteractionListener {
        override fun onAdClicked(view: View?, nativeAd: TTNativeAd?) {
          postMessage("onClick")
        }

        override fun onAdCreativeClick(view: View?, nativeAd: TTNativeAd?) {}

        override fun onAdShow(nativeAd: TTNativeAd?) {
          postMessage("onShow")
        }
      }
    )
  }

  private fun postMessage(method: String, arguments: Map<String, Any?> = mapOf()) {
    mainHandler.post {
      methodChannel.invokeMethod(method, arguments)
    }
  }
}
