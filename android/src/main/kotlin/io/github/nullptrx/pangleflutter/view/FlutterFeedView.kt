package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.drawable.Drawable
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.webkit.WebView
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.TTAdConstant
import com.bytedance.sdk.openadsdk.TTAdDislike.DislikeInteractionCallback
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.PangleExpressAd
import io.github.nullptrx.pangleflutter.common.PangleFeedAd
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.dp
import io.github.nullptrx.pangleflutter.view.feed.ItemBinding
import java.net.HttpURLConnection
import java.net.URL


class FlutterFeedView(
    val activity: Activity,
    messenger: BinaryMessenger,
    val id: Int,
    params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler {

  val context: Context

  private val methodChannel: MethodChannel
  private val container: FrameLayout
  private var feedId: String? = null
  private var isExpress: Boolean = false


  init {

    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_feedview_$id")
    methodChannel.setMethodCallHandler(this)

    context = activity

    container = FrameLayout(context)
    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)

    val feedId = params["feedId"] as? String
    val isExpress = params["isExpress"] as? Boolean ?: false
    this.feedId = feedId
    this.isExpress = isExpress
    loadAd()
  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    removeView()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "update" -> {
        loadAd()
        result.success(null)
      }
      "remove" -> {
        removeView()
      }
      else -> result.notImplemented()
    }
  }

  private fun scanForActivity(cont: Context?): Activity? {
    var context = cont
    while (context is ContextWrapper) {
      if (context is Activity) {
        return context
      }
      context = context.baseContext
    }
    return null
  }

  private fun loadAd() {
    this.feedId?.apply {
      if (isExpress) {
        val ad = PangleAdManager.shared.getExpressAd(this)
        ad?.also {
          loadExpressAd(it)
        }
      } else {
        val ad = PangleAdManager.shared.getFeedAd(this)
        ad?.also {
          loadAd(it)
        }
      }
    }
  }

  private fun removeView() {
    this.feedId?.also {
      if (this.isExpress) {
        val ad = PangleAdManager.shared.removeExpressAd(it)
        ad?.ad?.destroy()
      } else {
        PangleAdManager.shared.removeFeedAd(it)
      }
    }
    methodChannel.invokeMethod(Method.remove.name, null)
    methodChannel.setMethodCallHandler(null)
    container.removeAllViews()
  }

  private fun loadImage(url: String): Drawable? {
    try {
      val imgUrl = URL(url)
      val conn: HttpURLConnection = imgUrl.openConnection() as HttpURLConnection
      conn.doInput = true
      conn.connect()
      val drawable = Drawable.createFromStream(conn.inputStream, url.hashCode().toString())
      return drawable
    } catch (e: Exception) {
    }
    return null
  }

  internal enum class Method {
    remove,
    update;
  }

  private fun invoke(width: Float, height: Float) {
    val params = mutableMapOf<String, Any>()
    params["width"] = width
    params["height"] = height
    methodChannel.invokeMethod(Method.update.name, params)
  }

  fun loadAd(pangleAd: PangleFeedAd) {
    val ad = pangleAd.ad
    container.removeAllViews()
//    val adView = ad.adView
    val view = ItemBinding(activity) {
      removeView()
    }.bindView(container, ad) ?: return

//    val screenSize = ScreenUtil.getScreenSize()
//    val sw = screenSize.width.toFloat()
//    val sh = screenSize.height.toFloat()

    val screenWidth = ScreenUtil.getScreenWidthDp()
    val feedHeight: Float = when (ad.imageMode) {
      // 16 + 150 * 9 /16 + 30 + 0.5
      TTAdConstant.IMAGE_MODE_SMALL_IMG -> 130.875f
      // 6 + 28 + 4 + 40 + 30 + （sw - 2 * 16）* 9 / 16
      TTAdConstant.IMAGE_MODE_LARGE_IMG -> (108 + (screenWidth - 32) * 9.0f / 16)
      // 16 + 28 + 6 + 40 + 30 + (sw - 2 * 16 - 2 * 5) / 1.52 / 3
      TTAdConstant.IMAGE_MODE_GROUP_IMG -> (120 + (screenWidth - 42) / 4.56f) // 180.dp
      // 6 + 28 + 4 + 40 + 30 + （sw - 2 * 16）* 9 / 16
      TTAdConstant.IMAGE_MODE_VIDEO -> (108 + (screenWidth - 32) * 9.0f / 16) // 310.dp
      // unimplemented
      TTAdConstant.IMAGE_MODE_VERTICAL_IMG -> 1f // 1
      else -> 1f // 1
    }

    val params = FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT)
    params.gravity = Gravity.CENTER
    container.addView(view, params)

    val result = invalidateView(screenWidth, feedHeight)
    invoke(result.width, result.height)
  }

  private fun invalidateView(viewWidth: Float, viewHeight: Float): TTSizeF {
    container.layoutParams = FrameLayout.LayoutParams(viewWidth.dp, viewHeight.dp).apply {
      gravity = Gravity.CENTER
    }
//    container.clipChildren = false
    container.clipToPadding = false
    return TTSizeF(viewWidth, viewHeight)
  }

  private fun invalidateExpressView(width: Float, height: Float) {

    val viewWidth: Float
    val viewHeight: Float
    val screenWidth = ScreenUtil.getScreenWidthDp()
    val feedHeight = screenWidth * height / width
    viewWidth = screenWidth
    viewHeight = feedHeight
    container.layoutParams = FrameLayout.LayoutParams(viewWidth.dp, viewHeight.dp).apply {
      gravity = Gravity.CENTER
    }
    invoke(viewWidth, viewHeight)
  }

  fun loadExpressAd(pangleAd: PangleExpressAd) {
    val ad = pangleAd.ad
    val size = pangleAd.size
    val expressAdView = ad.expressAdView
    container.removeAllViews()
    val expectExpressWidth = size.width
    val expectExpressHeight = size.height
//      val screenWidth = ScreenUtil.getScreenWidthDp()
//      val feedHeight = screenWidth * expectExpressHeight / expectExpressWidth
//      val params = FrameLayout.LayoutParams(screenWidth.dp, feedHeight.dp)
    val params = FrameLayout.LayoutParams(expectExpressWidth.dp, expectExpressHeight.dp)
//      disableWebViewAutoPlay(expressAdView.webView)
    params.gravity = Gravity.CENTER

    container.addView(expressAdView, params)

    ad.setCanInterruptVideoPlay(true)
    ad.setExpressInteractionListener(object : TTNativeExpressAd.ExpressAdInteractionListener {
      override fun onAdClicked(view: View, type: Int) {
      }

      override fun onAdShow(view: View?, type: Int) {
      }

      override fun onRenderSuccess(view: View, width: Float, height: Float) {
        invalidateExpressView(width, height)
//        view.invalidate()
      }

      override fun onRenderFail(view: View?, msg: String?, code: Int) {
        removeView()
      }
    })

    ad.setDislikeCallback(activity, object : DislikeInteractionCallback {
      override fun onSelected(index: Int, selection: String) {
        removeView()
      }

      override fun onCancel() {
      }

      override fun onRefuse() {
      }
    })
    ad.render()

  }

  private fun disableWebViewAutoPlay(webView: WebView?) {
    webView ?: return
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
      val settings = webView.settings
      settings.mediaPlaybackRequiresUserGesture = true
    }
    webView.isSoundEffectsEnabled = false
  }


}