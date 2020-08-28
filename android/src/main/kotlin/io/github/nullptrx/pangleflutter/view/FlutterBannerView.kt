package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTBannerAd
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.PangleImgSize
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.common.kDoublePadding
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.dp


/**
 * 暂时没有用到的
 */
class FlutterBannerView(val activity: Activity, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler {

  private val methodChannel: MethodChannel
  private val container: FrameLayout
  private val context: Context
  private val width: Float?
  private val height: Float?

  init {
    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_bannerview_$id")
    methodChannel.setMethodCallHandler(this)
    context = activity
    container = FrameLayout(context)
    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)


    val slotId = params["slotId"] as? String
    this.width = (params["width"] as? Double)?.toFloat()
    this.height = (params["height"] as? Double)?.toFloat()
    if (slotId != null) {

      val imgSizeIndex = params["imgSize"] as Int
      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      val isExpress = params["isExpress"] as? Boolean ?: false

      val imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()
//    val count = params["count"] as Int ?: 1
      var size: TTSizeF? = null
      if (isExpress) {
        val pangleImgSize = PangleImgSize.values()[imgSizeIndex]
        var w: Float? = (params["width"] as? Double)?.toFloat()
        var h: Float? = (params["height"] as? Double)?.toFloat()
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
      val adSlot = PangleAdSlotManager.getBannerAdSlot(slotId, isExpress, imgSizeIndex, isSupportDeepLink, size)
      if (isExpress) {
        PangleAdManager.shared.loadBannerExpressAd(adSlot, FLTBannerExpressAd(imgSize))
      } else {
        PangleAdManager.shared.loadBannerAd(adSlot, FLTBannerAd(imgSize))
      }
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
      "update" -> {
        val imgSizeIndex: Int = call.argument<Int>("imgSize")!!
        val imgSize = PangleImgSize.values()[imgSizeIndex]

        invalidateView(imgSize.width, imgSize.height)
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun invalidateView(width: Int, height: Int) {
    val viewWidth: Float
    val viewHeight: Float
    if (this.width != null && this.height != null) {
      viewWidth = this.width
      viewHeight = this.height
    } else if (this.width != null) {
      viewWidth = this.width
      viewHeight = viewWidth * height / width
    } else if (this.height != null) {
      viewHeight = this.height
      viewWidth = viewHeight * width / height
    } else {
      val screenWidth = ScreenUtil.getScreenWidthDp()
      val bannerHeight = screenWidth * height / width
      viewWidth = screenWidth
      viewHeight = bannerHeight
    }

    container.layoutParams = FrameLayout.LayoutParams(viewWidth.dp, viewHeight.dp).apply {
      gravity = Gravity.CENTER
    }
    invoke(viewWidth, viewHeight)
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


  internal inner class FLTBannerAd(val imgSize: TTSize) : TTAdNative.BannerAdListener,
      TTBannerAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

    override fun onError(code: Int, message: String?) {
      container.removeAllViews()
      methodChannel.invokeMethod(Method.remove.name, null)
    }

    override fun onBannerAdLoad(ad: TTBannerAd) {
      val view = ad.bannerView
      //设置广告互动监听回调
      ad.setBannerInteractionListener(this)

      //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
      ad.setShowDislikeIcon(this)

      container.removeAllViews()
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      container.addView(view, params)
      view.invalidate()
      //设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
//      ad.setSlideIntervalTime(30_000)
      invalidateView(imgSize.width, imgSize.height)

    }

    override fun onAdClicked(view: View, type: Int) {
      methodChannel.invokeMethod(Method.reload.name, null)
    }

    override fun onAdShow(view: View, type: Int) {
    }

    override fun onSelected(position: Int, value: String) {
      //用户选择不喜欢原因后，移除广告展示
      methodChannel.invokeMethod(Method.remove.name, null)
      container.removeAllViews()
    }

    override fun onCancel() {
    }

    override fun onRefuse() {

    }
  }

  internal inner class FLTBannerExpressAd(val imgSize: TTSize) : TTAdNative.NativeExpressAdListener,
      TTNativeExpressAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

    override fun onError(code: Int, message: String?) {
//      invoke(message)
      container.removeAllViews()
      methodChannel.invokeMethod(Method.remove.name, null)
    }

    override fun onNativeExpressAdLoad(ttNativeExpressAds: MutableList<TTNativeExpressAd>?) {
      if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
        return
      }
      val ad = ttNativeExpressAds[0]
      //设置广告互动监听回调
      ad.setExpressInteractionListener(this)

      //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
      ad.setDislikeCallback(activity, this)


      // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
//      ad.setSlideIntervalTime(30_000)
      container.removeAllViews()
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      val expressAdView = ad.expressAdView
      container.addView(expressAdView, params)
      invalidateView(imgSize.width, imgSize.height)
      ad.render()

    }

    override fun onAdDismiss() {
    }

    override fun onAdClicked(view: View, type: Int) {
      methodChannel.invokeMethod(Method.reload.name, null)
    }

    override fun onAdShow(view: View, type: Int) {
    }

    override fun onRenderSuccess(view: View, width: Float, height: Float) {
      view.invalidate()
    }

    override fun onRenderFail(view: View, msg: String?, code: Int) {
      container.removeAllViews()
      methodChannel.invokeMethod(Method.remove.name, null)
    }

    override fun onSelected(position: Int, value: String) {
      //用户选择不喜欢原因后，移除广告展示
      container.removeAllViews()
      methodChannel.invokeMethod(Method.remove.name, null)
    }

    override fun onCancel() {
    }

    override fun onRefuse() {
    }
  }
}

