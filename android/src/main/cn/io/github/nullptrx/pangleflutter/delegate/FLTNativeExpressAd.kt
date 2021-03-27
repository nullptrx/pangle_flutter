package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTNativeExpressAd
import io.github.nullptrx.pangleflutter.common.kBlock

internal class FLTNativeExpressAd(var result: (Any) -> Unit) : TTAdNative.NativeExpressAdListener {

  override fun onNativeExpressAdLoad(ads: MutableList<TTNativeExpressAd>?) {
    invoke()
  }

  override fun onError(code: Int, message: String?) {
    invoke(code, message)
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