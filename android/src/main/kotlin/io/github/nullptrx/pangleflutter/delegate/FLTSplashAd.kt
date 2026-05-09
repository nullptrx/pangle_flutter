package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.bytedance.sdk.openadsdk.CSJAdError
import com.bytedance.sdk.openadsdk.CSJSplashAd
import com.bytedance.sdk.openadsdk.TTAdNative
import io.github.nullptrx.pangleflutter.common.kBlock

internal class FLTSplashAd(
  val hideSkipButton: Boolean?,
  var activity: Activity?,
  var result: (Any) -> Unit = {}
) : TTAdNative.CSJSplashAdListener {
  private var overlayView: View? = null

  override fun onSplashLoadSuccess(ad: CSJSplashAd) {

  }

  override fun onSplashLoadFail(error: CSJAdError) {
    handleSplashEnd()
    val msg = error.msg
    val code = error.code
    invoke(code, message = msg)
  }

  override fun onSplashRenderSuccess(ad: CSJSplashAd) {
    showAd(ad)
  }

  override fun onSplashRenderFail(ad: CSJSplashAd, error: CSJAdError) {
    handleSplashEnd()
    invoke(error.code, message = error.msg)
  }

  fun showAd(ad: CSJSplashAd) {
    val splashView = ad.splashView
    hideSkipButton?.also {
      if (it) ad.hideSkipButton()
    }
    ad.setSplashAdListener(object : CSJSplashAd.SplashAdListener {

      override fun onSplashAdShow(ad: CSJSplashAd?) {

      }

      override fun onSplashAdClick(ad: CSJSplashAd?) {
      }

      override fun onSplashAdClose(ad: CSJSplashAd?, type: Int) {
        handleSplashEnd()
        invoke(0, type)
      }

    })
    activity?.also { act ->
      act.runOnUiThread {
        val decorView = act.window.decorView as ViewGroup
        splashView.parent?.let { (it as? ViewGroup)?.removeView(splashView) }
        val params = FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.MATCH_PARENT,
          FrameLayout.LayoutParams.MATCH_PARENT
        )
        decorView.addView(splashView, params)
        overlayView = splashView
      }
    }
  }

  private fun handleSplashEnd() {
    overlayView?.also { view ->
      (view.parent as? ViewGroup)?.removeView(view)
      overlayView = null
    }
  }

  fun invoke(code: Int = 0, type: Int = 0, message: String = "") {
    if (result == kBlock) {
      return
    }
    result.apply {
      val params = mutableMapOf<String, Any>()
      params["code"] = code
      params["type"] = type
      params["message"] = message
      invoke(params)
      result = kBlock
    }
  }

}
