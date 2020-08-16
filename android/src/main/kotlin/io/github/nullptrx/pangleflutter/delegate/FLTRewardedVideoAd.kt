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

  private fun invoke(code: Int = 0, message: String? = null, verify: Boolean = false) {
    result?.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      if (code == 0) {
        args["verify"] = verify
      }
      success(args)
    }
    result = null
    target = null
  }


  inner class RewardAdInteractionImpl() : TTRewardVideoAd.RewardAdInteractionListener {
    // 视频广告播完验证奖励有效性回调，参数分别为是否有效，奖励数量，奖励名称
    override fun onRewardVerify(verify: Boolean, amount: Int, rewardName: String?) {
      invoke(verify = verify)
    }

    override fun onSkippedVideo() {
      invoke(-1, "skipped")
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
      invoke(-1, "error")
    }

  }
}

