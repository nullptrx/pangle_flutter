package io.github.nullptrx.pangleflutter.delegate

import android.app.Activity
import androidx.annotation.MainThread
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTFullScreenVideoAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.PangleLoadingType
import io.github.nullptrx.pangleflutter.common.kBlock


class FLTFullScreenVideoAd(var slotId: String, var target: Activity?, val loadingType: PangleLoadingType, var result: (Any) -> Unit = {}) : TTAdNative.FullScreenVideoAdListener {
  private var ttVideoAd: TTFullScreenVideoAd? = null

  /**
   * 广告加载完成的回调，接入方可以在这个回调中进行渲染
   *
   * @param ad 全屏视频广告接口
   */
  @MainThread
  override fun onFullScreenVideoAdLoad(ad: TTFullScreenVideoAd?) {
    if (loadingType == PangleLoadingType.preload || loadingType == PangleLoadingType.preload_only) {
      PangleAdManager.shared.setFullScreenVideoAd(slotId, ad)
      if (loadingType == PangleLoadingType.preload_only) {
        invoke(0)
      }
    } else {
      target?.also {
        ttVideoAd = ad
        ttVideoAd?.setFullScreenVideoAdInteractionListener(FullScreenVideoAdInteractionImpl(result))
        ttVideoAd?.showFullScreenVideoAd(it)
      }
    }
  }

  /**
   * 加载失败回调
   *
   * @param code
   * @param message
   */
  @MainThread
  override fun onError(code: Int, message: String?) {
  }


  /**
   * 广告视频本地加载完成的回调，接入方可以在这个回调后直接播放本地视频
   */
  override fun onFullScreenVideoCached() {

  }

  override fun onFullScreenVideoCached(ad: TTFullScreenVideoAd?) {

  }

  private fun invoke(code: Int = 0, message: String? = null) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      invoke(args)
      result = kBlock
    }
  }
}


class FullScreenVideoAdInteractionImpl(var result: (Any) -> Unit?) : TTFullScreenVideoAd.FullScreenVideoAdInteractionListener {

  // 视频广告播完验证奖励有效性回调，参数分别为是否有效，奖励数量，奖励名称
  override fun onSkippedVideo() {
    invoke(-1, "skip")
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

  private fun invoke(code: Int = 0, message: String? = null) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val args = mutableMapOf<String, Any?>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      invoke(args)
      result = kBlock
    }
  }
}

