package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
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
import io.github.nullptrx.pangleflutter.PangleAdSlotManager
import io.github.nullptrx.pangleflutter.common.PangleImgSize
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.asMap
import io.github.nullptrx.pangleflutter.util.dp


/**
 * 暂时没有用到的
 */
class FlutterBannerView(val activity: Activity, messenger: BinaryMessenger, val id: Int, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler {

  private val methodChannel: MethodChannel
  private val container: FrameLayout
  private val context: Context
  private lateinit var expressSize: TTSizeF
  private lateinit var imgSize: TTSize
  private var isExpress: Boolean = false
  private var interval: Int? = null

  init {
    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_bannerview_$id")
    methodChannel.setMethodCallHandler(this)
    context = activity
    container = FrameLayout(context)
//    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)

//    println("BannerView: init ${Date().toGMTString()}")

    val slotId = params["slotId"] as? String
    if (slotId != null) {

      val imgSizeIndex = params["imgSize"] as Int
      val isSupportDeepLink = params["isSupportDeepLink"] as? Boolean ?: true
      isExpress = params["isExpress"] as? Boolean ?: false
      imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()
      interval = params["interval"] as Int?


      if (isExpress) {
        val expressArgs: Map<String, Double> = params["expressSize"]?.asMap() ?: mapOf()
        val w: Float = expressArgs.getValue("width").toFloat()
        val h: Float = expressArgs.getValue("height").toFloat()
        expressSize = TTSizeF(w, h)
      } else {
        expressSize = TTSizeF()
      }
      val adSlot = PangleAdSlotManager.getBannerAdSlot(slotId, isExpress, expressSize, 1, imgSizeIndex, isSupportDeepLink)
      if (isExpress) {
        PangleAdManager.shared.loadBannerExpressAd(adSlot, FLTBannerExpressAd())
      } else {
        PangleAdManager.shared.loadBannerAd(adSlot, FLTBannerAd())
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
      "update" -> {
//        val imgSizeIndex: Int = call.argument<Int>("imgSize")!!
//        val imgSize = PangleImgSize.values()[imgSizeIndex]
//        invalidateView(imgSize.width, imgSize.height)

        if (isExpress) {
          invalidateView(expressSize.width, expressSize.height)
        } else {
          invalidateView(imgSize.width, imgSize.height)
        }
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun invalidateView(width: Int, height: Int) {
    val screenWidth = ScreenUtil.getScreenWidthDp()
    val bannerHeight = screenWidth * height / width

    container.layoutParams = FrameLayout.LayoutParams(screenWidth.dp, bannerHeight.dp).apply {
      gravity = Gravity.CENTER
    }
    invoke(screenWidth.toFloat(), bannerHeight.toFloat())
  }

  private fun invalidateView(width: Float, height: Float) {
//    val screenWidth = ScreenUtil.getScreenWidthDp()
//    val bannerHeight = screenWidth * height / width

    container.layoutParams = FrameLayout.LayoutParams(width.dp, height.dp).apply {
      gravity = Gravity.CENTER
    }
    invoke(width, height)
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


  internal inner class FLTBannerAd : TTAdNative.BannerAdListener,
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
      //设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
      interval?.also {
        ad.setSlideIntervalTime(it)
      }

      container.removeAllViews()
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      container.addView(view, params)
//      view.invalidate()
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

  internal inner class FLTBannerExpressAd : TTAdNative.NativeExpressAdListener,
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
//      println("BannerView: load ${Date().toGMTString()}")
      val ad = ttNativeExpressAds[0]

      //设置广告互动监听回调
      ad.setExpressInteractionListener(this)

      //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
      ad.setDislikeCallback(activity, this)
      // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
      interval?.also {
        ad.setSlideIntervalTime(it)
      }
      ad.render()

      container.removeAllViews()
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      val expressAdView = ad.expressAdView
      container.addView(expressAdView, params)

//      val expectExpressWidth = expressSize.width
//      val expectExpressHeight = expressSize.height
//      invalidateView(expectExpressWidth, expectExpressHeight)

    }

    override fun onAdDismiss() {
    }

    override fun onAdClicked(view: View, type: Int) {
      methodChannel.invokeMethod(Method.reload.name, null)
    }

    override fun onAdShow(view: View, type: Int) {
    }

    override fun onRenderSuccess(view: View, width: Float, height: Float) {
//      view.invalidate()
//      println("BannerView: succ ${Date().toGMTString()}")
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

