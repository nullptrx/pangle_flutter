package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

internal class FLTRewardedVideoAd(result: MethodChannel.Result, target: Activity) : TTAdNative.RewardVideoAdListener {
  val result: WeakReference<MethodChannel.Result>
  val target: WeakReference<Activity>

  init {
    this.result = WeakReference(result)
    this.target = WeakReference(target)
  }

  var ttVideoAd: TTRewardVideoAd? = null

  override fun onRewardVideoAdLoad(ad: TTRewardVideoAd?) {
    val activity = target.get()
    activity ?: return
    ttVideoAd = ad
    ttVideoAd?.setRewardAdInteractionListener(RewardAdInteractionImpl())
    ttVideoAd?.showRewardVideoAd(activity)
  }

  override fun onRewardVideoCached() {
  }

  override fun onError(code: Int, message: String?) {
    invoke(code, message)

  }

  private fun invoke(code: Int = 0, message: String?) {
    val ret = result.get()
    ret ?: return
    val args = mutableMapOf<String, Any?>()
    args["code"] = code
    args["message"] = message
    ret.success(args)
    result.clear()
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
      invoke(0, null)
    }

    override fun onVideoError() {
      invoke(-1, "video error")
    }

  }
}

