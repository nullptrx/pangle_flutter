package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import com.bytedance.sdk.openadsdk.TTAdDislike
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTInteractionAd

class FLTInterstitialAd(var target: Activity?, var result: (Any) -> Unit) : TTAdNative.InteractionAdListener, TTInteractionAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

  override fun onInteractionAdLoad(ttInteractionAd: TTInteractionAd) {
    target?.also {

      ttInteractionAd.setAdInteractionListener(this)
      ttInteractionAd.setShowDislikeIcon(this)
      ttInteractionAd.showInteractionAd(it)
    }
    invoke()
  }

  override fun onError(code: Int, message: String?) {
    invoke(code, message)
  }


  private fun invoke(code: Int = 0, message: String? = null) {
    result?.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      invoke(args)
    }
    result = {}
    target = null
  }

  override fun onAdDismiss() {
  }

  override fun onAdClicked() {
  }

  override fun onAdShow() {
  }

  override fun onSelected(position: Int, value: String) {
  }

  override fun onCancel() {
  }

  override fun onRefuse() {
  }

}