package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.PangleEventStreamHandler
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.kBlock

internal class FLTRewardedVideoAd(
  val slotId: String,
  var target: Activity?,
  val loadingType: PangleLoadingType,
  var result: (Any) -> Unit = {}
) : TTAdNative.RewardVideoAdListener {
  
  var ttVideoAd: TTRewardVideoAd? = null
  
  override fun onRewardVideoAdLoad(ad: TTRewardVideoAd?) {
    PangleEventStreamHandler.rewardedVideo("load")
    if (loadingType == PangleLoadingType.preload || loadingType == PangleLoadingType.preload_only) {
      PangleAdManager.shared.setRewardedVideoAd(slotId, ad)
      if (loadingType == PangleLoadingType.preload_only) {
        invoke(0, verify = false)
      }
    } else {
      target?.also {
        ttVideoAd = ad
        ttVideoAd?.setRewardAdInteractionListener(RewardAdInteractionImpl(result))
        ttVideoAd?.showRewardVideoAd(it)
      }
    }
  }
  
  @Deprecated("已过时")
  override fun onRewardVideoCached() {
  }
  
  override fun onRewardVideoCached(ad: TTRewardVideoAd?) {
    PangleEventStreamHandler.rewardedVideo("cached")
  }
  
  override fun onError(code: Int, message: String?) {
    PangleEventStreamHandler.rewardedVideo("error")
    invoke(code, message)
    
  }
  
  private fun invoke(code: Int = 0, message: String? = null, verify: Boolean = false) {
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      if (code == 0) {
        args["verify"] = verify
      }
      invoke(args)
    }
    result = {}
    target = null
  }
  
  
}

internal class RewardAdInteractionImpl(var result: (Any) -> Unit?) :
  TTRewardVideoAd.RewardAdInteractionListener {
  private var verify = false
  
  // 视频广告播完验证奖励有效性回调，参数分别为是否有效，奖励数量，奖励名称
  override fun onRewardVerify(
    verify: Boolean,
    amount: Int,
    rewardName: String,
    errorCode: Int,
    errorMsg: String
  ) {
    PangleEventStreamHandler.rewardedVideo(if (verify) "reward_verify_success" else "reward_verify_fail")
    this.verify = verify
  }
  
  override fun onSkippedVideo() {
    PangleEventStreamHandler.rewardedVideo("skip")
  }
  
  override fun onAdShow() {
    PangleEventStreamHandler.rewardedVideo("show")
  }
  
  override fun onAdVideoBarClick() {
    PangleEventStreamHandler.rewardedVideo("click")
  }
  
  override fun onVideoComplete() {
    PangleEventStreamHandler.rewardedVideo("complete")
  }
  
  override fun onAdClose() {
    PangleEventStreamHandler.rewardedVideo("close")
    invoke(verify = verify)
  }
  
  override fun onVideoError() {
    PangleEventStreamHandler.rewardedVideo("render_fail")
    invoke(-1, "error")
  }
  
  
  private fun invoke(code: Int = 0, message: String? = null, verify: Boolean = false) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      if (code == 0) {
        args["verify"] = verify
      }
      invoke(args)
      result = kBlock
    }
  }
}

