package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.kBlock

class FLTBannerExpressAd(var result: (Any) -> Unit) : TTAdNative.NativeExpressAdListener {

  override fun onError(code: Int, message: String?) {
    invoke(code, message)
  }

  override fun onNativeExpressAdLoad(ttNativeExpressAds: MutableList<TTNativeExpressAd>?) {
    if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
      invoke(-1)
      return
    }
    val data = PangleAdManager.shared.setExpressAd(ttNativeExpressAds)
    invoke(count = ttNativeExpressAds.size, data = data)
  }


  private fun invoke(code: Int = 0, message: String? = null, count: Int = 0, data: List<String>? = null) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val args = mutableMapOf<String, Any>()
      args["code"] = code
      message?.also {
        args["message"] = it
      }
      args["count"] = count
      data?.also {
        args["data"] = it
      }
      invoke(args)
      result = kBlock
    }


  }
}