package io.github.nullptrx.pangleflutter.delegate

import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTFeedAd
import io.github.nullptrx.pangleflutter.util.PangleAdManager
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import kotlin.collections.set

class FLTFeedAd(result: MethodChannel.Result, val tag: String) : TTAdNative.FeedAdListener {

  

  val result: WeakReference<MethodChannel.Result>

  init {
    this.result = WeakReference(result)
  }

  override fun onError(code: Int, message: String) {
    invoke(code, message)
  }

  override fun onFeedAdLoad(ads: List<TTFeedAd>?) {
    if (ads == null || ads.isEmpty()) {
      invoke(-1)
      return
    }
    PangleAdManager.shared.setFeedAd(tag, ads)
    invoke(0, count = ads.size)
  }

  private fun invoke(code: Int = 0, message: String = "", count: Int = 0) {
    val method = result.get()
    val params = mutableMapOf<String, Any>()
    params["code"] = code
    params["message"] = message
    params["count"] = count
    method?.success(params)
    result.clear()
  }

}