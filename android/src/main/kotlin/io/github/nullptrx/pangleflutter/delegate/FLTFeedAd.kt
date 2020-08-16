package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTFeedAd
import io.flutter.plugin.common.MethodChannel
import io.github.nullptrx.pangleflutter.PangleAdManager
import kotlin.collections.set

class FLTFeedAd(var result: MethodChannel.Result?) : TTAdNative.FeedAdListener {

  override fun onError(code: Int, message: String) {
    invoke(code, message)
  }

  override fun onFeedAdLoad(ads: List<TTFeedAd>?) {
    if (ads == null || ads.isEmpty()) {
      invoke(-1)
      return
    }
    val data = PangleAdManager.shared.setFeedAd(ads)
    invoke(0, count = ads.size, data = data)
  }

  private fun invoke(code: Int = 0, message: String? = null, count: Int = 0, data: List<String>? = null) {
    result?.apply {
      val args = mutableMapOf<String, Any>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      args["count"] = count
      data?.also {
        args["data"] = it
      }
      success(args)
    }
    result = null


  }

}