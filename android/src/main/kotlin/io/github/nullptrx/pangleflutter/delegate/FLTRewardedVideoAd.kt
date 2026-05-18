package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import android.os.Bundle
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.ERROR_CODE_NO_ACTIVITY
import io.github.nullptrx.pangleflutter.common.ERROR_MSG_NO_ACTIVITY
import io.github.nullptrx.pangleflutter.common.PangleEventStreamHandler
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.kBlock
import java.lang.ref.WeakReference

internal class FLTRewardedVideoAd(
  val slotId: String,
  target: Activity,           // WeakReference — prevents leaking the Activity while the
  val loadingType: PangleLoadingType, // ad loads asynchronously over the network.
  var result: (Any) -> Unit = {}
) : TTAdNative.RewardVideoAdListener {

  // Held as WeakReference so a destroyed Activity (rotation, back-press) can be
  // GC'd even if the ad load callback has not yet fired.
  private val targetRef = WeakReference(target)

  var ttVideoAd: TTRewardVideoAd? = null

  override fun onRewardVideoAdLoad(ad: TTRewardVideoAd?) {
    PangleEventStreamHandler.rewardedVideo("load")
    if (loadingType == PangleLoadingType.preload || loadingType == PangleLoadingType.preload_only) {
      PangleAdManager.shared.setRewardedVideoAd(slotId, ad)
      if (loadingType == PangleLoadingType.preload_only) {
        invoke(0)
      }
    } else {
      val activity = targetRef.get() ?: run {
        // Activity is gone — report failure so Dart can handle it.
        invoke(ERROR_CODE_NO_ACTIVITY, ERROR_MSG_NO_ACTIVITY)
        return
      }
      ttVideoAd = ad
      ttVideoAd?.setRewardAdInteractionListener(RewardAdInteractionImpl(result))
      ttVideoAd?.showRewardVideoAd(activity)
    }
  }

  override fun onRewardVideoCached() {
  }

  override fun onRewardVideoCached(ad: TTRewardVideoAd?) {
    PangleEventStreamHandler.rewardedVideo("cached")
  }

  override fun onError(code: Int, message: String?) {
    PangleEventStreamHandler.rewardedVideo("error")
    invoke(code, message)
  }

  private fun invoke(code: Int = 0, message: String? = null, verify: Boolean? = null) {
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also { args["message"] = it }
      verify?.also { args["verify"] = it }
      invoke(args)
    }
    result = kBlock
    targetRef.clear()
  }
}

internal class RewardAdInteractionImpl(var result: (Any) -> Unit?) :
  TTRewardVideoAd.RewardAdInteractionListener {
  private var hasCallback = false
  private var verify = false

  // 视频广告播完验证奖励有效性回调，参数分别为是否有效，奖励数量，奖励名称
  override fun onRewardVerify(
    verify: Boolean,
    amount: Int,
    rewardName: String,
    errorCode: Int,
    errorMsg: String
  ) {
    this.hasCallback = true
    PangleEventStreamHandler.rewardedVideo(if (verify) "reward_verify_success" else "reward_verify_fail")
    this.verify = verify
  }

  override fun onRewardArrived(verify: Boolean, amount: Int, params: Bundle?) {
    if (hasCallback) {
      return
    }
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


  private fun invoke(code: Int = 0, message: String? = null, verify: Boolean? = null) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also { args["message"] = it }
      verify.also { args["verify"] = it }
      invoke(args)
      result = kBlock
    }
  }
}

