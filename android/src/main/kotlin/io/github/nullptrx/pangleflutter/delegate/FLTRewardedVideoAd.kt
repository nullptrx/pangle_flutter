package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import android.os.Bundle
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

    /**
     * 激励视频播放完毕，验证是否有效发放奖励的回调 4400版本新增
     *
     * @param isRewardValid 奖励有效
     * @param rewardType 奖励类型，0:基础奖励 >0:进阶奖励
     * @param extraInfo 奖励的额外参数
     */
    override fun onRewardArrived(isRewardValid: Boolean, rewardType: Int, extraInfo: Bundle?) {
        PangleEventStreamHandler.rewardedVideo(if (isRewardValid) "reward_verify_success" else "reward_verify_fail")
        this.verify = isRewardValid
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

