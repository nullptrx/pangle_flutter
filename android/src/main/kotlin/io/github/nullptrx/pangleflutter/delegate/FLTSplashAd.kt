package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import androidx.fragment.app.FragmentActivity
import com.bytedance.sdk.openadsdk.CSJAdError
import com.bytedance.sdk.openadsdk.CSJSplashAd
import com.bytedance.sdk.openadsdk.CSJSplashCloseType
import com.bytedance.sdk.openadsdk.TTAdNative
import io.github.nullptrx.pangleflutter.common.kBlock
import io.github.nullptrx.pangleflutter.dialog.NativeSplashDialog
import io.github.nullptrx.pangleflutter.dialog.SupportSplashDialog

internal class FLTSplashAd(
  val hideSkipButton: Boolean?,
  var activity: Activity?,
  var result: (Any) -> Unit = {}
) : TTAdNative.CSJSplashAdListener {
  private var supportDialog: SupportSplashDialog? = null
  private var nativeDialog: NativeSplashDialog? = null


  override fun onSplashLoadSuccess() {

  }

  override fun onSplashLoadFail(error: CSJAdError) {
    handleSplashEnd()
    val msg = error.msg
    val code = error.code
    invoke(code, message = msg)
  }

  override fun onSplashRenderSuccess(ad: CSJSplashAd) {
    loadAd(ad)
  }

  override fun onSplashRenderFail(ad: CSJSplashAd, error: CSJAdError) {
    handleSplashEnd()
    invoke(error.code, message = error.msg)
  }

  fun loadAd(ad: CSJSplashAd) {
    val splashView = ad.splashView
    hideSkipButton?.also {
      if (it) {
        ad.hideSkipButton()
      }
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
    activity?.also {
      if (it is FragmentActivity) {
        val supportSplashDialog = SupportSplashDialog()
        supportDialog = supportSplashDialog
        supportSplashDialog.show(it.supportFragmentManager, splashView)
      } else {
        val nativeSplashDialog = NativeSplashDialog()
        nativeDialog = nativeSplashDialog
        nativeSplashDialog.show(it.fragmentManager, splashView)
      }
    }
  }

  private fun handleSplashEnd() {
    supportDialog?.dismissAllowingStateLoss()
    nativeDialog?.dismissAllowingStateLoss()
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