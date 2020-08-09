package io.github.nullptrx.pangleflutter.view

import android.content.Context
import android.content.res.Resources
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTBannerAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.common.PangleImgSize
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.PangleAdManager
import io.github.nullptrx.pangleflutter.util.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.util.px


/**
 * 暂时没有用到的
 */
class FlutterBannerView(val context: Context, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler {

  private val methodChannel: MethodChannel
  private val container: FrameLayout

  init {
    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_bannerview_$id")
    methodChannel.setMethodCallHandler(this)

    container = FrameLayout(context)
    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)


    val slotId = params["slotId"] as String
    val imgSizeIndex = params["imgSize"] as Int
    val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
    val imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()
    val adSlot = PangleAdSlotManager.getBannerAdSlot(slotId, imgSizeIndex, isSupportDeepLink)
    PangleAdManager.shared.loadBannerAd(adSlot, FLTBannerAd(imgSize))
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
      "update" -> {
        val imgSizeIndex = call.argument<Int>("imgSize") as Int
        val imgSize = PangleImgSize.values()[imgSizeIndex]

        val size = invalidateView(imgSize.width, imgSize.height)
        invoke(size.width.px, size.height.px)
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun invalidateView(width: Int, height: Int): TTSizeF {
    val screenWidth = Resources.getSystem().displayMetrics.widthPixels.toFloat()
    val bannerHeight = screenWidth * height / width
    container.layoutParams = FrameLayout.LayoutParams(screenWidth.toInt(), bannerHeight.toInt())
    return TTSizeF(screenWidth, bannerHeight)
  }

  internal enum class Method {
    remove,
    reload,
    update,
  }

//  private fun invoke(message: String? = null) {
//    val params = mutableMapOf<String, Any?>()
//    params["success"] = false
//    params["message"] = message
//    methodChannel.invokeMethod(Method.update.name, params)
//  }

  private fun invoke(width: Float, height: Float) {
    val params = mutableMapOf<String, Any>()
    params["width"] = width
    params["height"] = height
    methodChannel.invokeMethod(Method.update.name, params)
  }


  internal inner class FLTBannerAd(val imgSize: TTSize) : TTAdNative.BannerAdListener {

    override fun onError(code: Int, message: String?) {
//      invoke(message)
    }

    override fun onBannerAdLoad(ad: TTBannerAd) {
      val view = ad.bannerView
//      view.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED)
      container.removeAllViews()
      val size = invalidateView(imgSize.width, imgSize.height)
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      container.addView(view, params)
      //设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
//      ad.setSlideIntervalTime(30_000)


      //设置广告互动监听回调
      ad.setBannerInteractionListener(object : TTBannerAd.AdInteractionListener {
        override fun onAdClicked(view: View, type: Int) {
          methodChannel.invokeMethod(Method.reload.name, null)
        }

        override fun onAdShow(view: View, type: Int) {
        }

      })

      //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
      ad.setShowDislikeIcon(object : TTAdDislike.DislikeInteractionCallback {
        override fun onSelected(position: Int, value: String) {
          //用户选择不喜欢原因后，移除广告展示
          methodChannel.invokeMethod(Method.remove.name, null)
          container.removeAllViews()
        }

        override fun onCancel() {
        }

        override fun onRefuse() {

        }
      })

      invoke(size.width.px, size.height.px)

    }


  }
}

