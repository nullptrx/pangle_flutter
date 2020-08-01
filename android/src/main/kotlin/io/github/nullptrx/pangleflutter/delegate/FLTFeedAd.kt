package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTFeedAd
import io.flutter.plugin.common.MethodChannel
import io.github.nullptrx.pangleflutter.util.PangleAdManager
import kotlin.collections.set

class FLTFeedAd(var result: MethodChannel.Result?, val tag: String) : TTAdNative.FeedAdListener {

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
      val params = mutableMapOf<String, Any>()
      params["code"] = code
      message?.also {
        params["message"] = it
      }
      params["count"] = count
      data?.also {
        params["data"] = it
      }
      success(params)
    }
    result = null


  }

}