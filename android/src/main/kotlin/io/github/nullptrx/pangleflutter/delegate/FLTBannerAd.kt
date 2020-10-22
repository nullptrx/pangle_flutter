package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTBannerAd
import io.github.nullptrx.pangleflutter.PangleAdManager
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.kBlock

class FLTBannerAd(val size:TTSize, var result: (Any) -> Unit) : TTAdNative.BannerAdListener {

  override fun onError(code: Int, message: String?) {
    invoke(code, message)
  }

  override fun onBannerAdLoad(ad: TTBannerAd) {

    val data = PangleAdManager.shared.setBannerAd(size, arrayListOf(ad))
    invoke(count = 1, data = data)
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