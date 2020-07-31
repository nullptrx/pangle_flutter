package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import android.view.View
import androidx.fragment.app.FragmentActivity
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTSplashAd
import io.github.nullptrx.pangleflutter.dialog.NativeSplashDialog
import io.github.nullptrx.pangleflutter.dialog.SupportSplashDialog
import java.lang.ref.WeakReference

internal class FLTSplashAd(val hideSkipButton: Boolean?, activity: Activity?) : TTAdNative.SplashAdListener {
  private val target: WeakReference<Activity?>
  private var supportDialog: SupportSplashDialog? = null
  private var nativeDialog: NativeSplashDialog? = null

  init {
    this.target = WeakReference(activity)
  }


  override fun onError(code: Int, message: String) {
    handleSplashEnd()

  }

  override fun onTimeout() {
    handleSplashEnd()
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
        view.postDelayed({
          handleSplashEnd()
        }, 500)
      }

      override fun onAdSkip() {
        handleSplashEnd()
      }

      override fun onAdShow(view: View?, type: Int) {
      }

      override fun onAdTimeOver() {
        handleSplashEnd()
      }

    })
    val activity = target.get()
    activity?.also {
      if (it is FragmentActivity) {
        val tag = SupportSplashDialog::class.java.name
        val supportSplashDialog = SupportSplashDialog(splashView)
        supportDialog = supportSplashDialog
        supportSplashDialog.show(it.supportFragmentManager, tag)
      } else {
        val tag = NativeSplashDialog::class.java.name
        val nativeSplashDialog = NativeSplashDialog(splashView)
        nativeDialog = nativeSplashDialog
        nativeSplashDialog.show(it.fragmentManager, tag)
      }
    }
  }

  private fun handleSplashEnd() {
    supportDialog?.dismiss()
    nativeDialog?.dismiss()
  }


//  @Deprecated("TODO")
//  fun invoke(code: Int = 0, message: String = "") {
//
//    result.get()?.apply {
//      val params = mutableMapOf<String, Any>()
//      params["code"] = code
//      params["message"] = message
//      success(params)
//    }
//    result.clear()
//  }


}