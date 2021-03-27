package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.common.kBlock
import kotlin.collections.set

class FLTFeedExpressAd(val size: TTSizeF, var result: (Any) -> Unit = {}) : TTAdNative.NativeExpressAdListener {

  override fun onError(code: Int, message: String) {
    invoke(code, message)
  }

  override fun onNativeExpressAdLoad(ttNativeExpressAds: MutableList<TTNativeExpressAd>?) {
    if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
      invoke(-1)
      return
    }
    val data = PangleAdManager.shared.setExpressAd(ttNativeExpressAds)
    invoke(0, count = ttNativeExpressAds.size, data = data)
  }

  private fun invoke(code: Int = 0, message: String? = null, count: Int = 0, data: List<String>? = null) {
    if (result == kBlock) {
      return
    }
    result.apply {
      val params = mutableMapOf<String, Any>()
      params["code"] = code
      message?.also {
        params["message"] = it
      }
      params["count"] = count
      data?.also {
        params["data"] = it
      }
      invoke(params)
      result = kBlock
    }


  }

}