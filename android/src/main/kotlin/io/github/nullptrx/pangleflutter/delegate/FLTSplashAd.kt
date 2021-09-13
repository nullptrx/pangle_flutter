package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import android.view.View
import androidx.fragment.app.FragmentActivity
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTSplashAd
import io.github.nullptrx.pangleflutter.common.kBlock
import io.github.nullptrx.pangleflutter.dialog.NativeSplashDialog
import io.github.nullptrx.pangleflutter.dialog.SupportSplashDialog

internal class FLTSplashAd(
  val hideSkipButton: Boolean?,
  var activity: Activity?,
  var result: (Any) -> Unit = {}
) : TTAdNative.SplashAdListener {
  private var supportDialog: SupportSplashDialog? = null
  private var nativeDialog: NativeSplashDialog? = null


  override fun onError(code: Int, message: String) {
    handleSplashEnd()
    invoke(code, message)

  }

  override fun onTimeout() {
    handleSplashEnd()
    invoke(-1, "timeout")
  }

  override fun onSplashAdLoad(ad: TTSplashAd) {
    loadAd(ad)
  }

  fun loadAd(ad: TTSplashAd) {
    val splashView = ad.splashView
    hideSkipButton?.also {
      if (it) {
        ad.setNotAllowSdkCountdown()
      }
    }
    ad.setSplashInteractionListener(object : TTSplashAd.AdInteractionListener {
      override fun onAdClicked(view: View, type: Int) {
        handleSplashEnd()
        invoke(0, "click")
      }

      override fun onAdSkip() {
        handleSplashEnd()
        invoke(0, "skip")
      }

      override fun onAdShow(view: View?, type: Int) {
      }

      override fun onAdTimeOver() {
        handleSplashEnd()
        invoke(0, "timeover")
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


  fun invoke(code: Int = 0, message: String = "") {
    if (result == kBlock) {
      return
    }
    result.apply {
      val params = mutableMapOf<String, Any>()
      params["code"] = code
      params["message"] = message
      invoke(params)
      result = kBlock
    }
  }


}