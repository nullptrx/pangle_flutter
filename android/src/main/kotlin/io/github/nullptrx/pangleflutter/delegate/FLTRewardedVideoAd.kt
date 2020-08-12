package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import io.flutter.plugin.common.MethodChannel

internal class FLTRewardedVideoAd(var result: MethodChannel.Result?, var target: Activity?) : TTAdNative.RewardVideoAdListener {

  var ttVideoAd: TTRewardVideoAd? = null

  override fun onRewardVideoAdLoad(ad: TTRewardVideoAd?) {

    target?.also {
      ttVideoAd = ad
      ttVideoAd?.setRewardAdInteractionListener(RewardAdInteractionImpl())
      ttVideoAd?.showRewardVideoAd(it)
    }
  }

  override fun onRewardVideoCached() {
  }

  override fun onError(code: Int, message: String?) {
    invoke(code, message)

  }

  private fun invoke(code: Int = 0, message: String? = null) {
    result?.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      args["message"] = message
      success(args)
    }
    result = null
    target = null
  }


  inner class RewardAdInteractionImpl() : TTRewardVideoAd.RewardAdInteractionListener {
    override fun onRewardVerify(p0: Boolean, p1: Int, p2: String?) {
    }

    override fun onSkippedVideo() {
    }

    override fun onAdShow() {
    }

    override fun onAdVideoBarClick() {
    }

    override fun onVideoComplete() {
    }

    override fun onAdClose() {
      invoke()
    }

    override fun onVideoError() {
      invoke(-1, "video error")
    }

  }
}

