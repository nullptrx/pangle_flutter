// package io.github.nullptrx.pangleflutter.delegate
//
// import android.app.Activity
// import android.app.Dialog
// import android.content.DialogInterface
// import android.view.View
// import android.view.ViewGroup
// import com.bytedance.sdk.openadsdk.TTAdDislike
// import com.bytedance.sdk.openadsdk.TTAdNative
// import com.bytedance.sdk.openadsdk.TTNativeAd
// import com.bytedance.sdk.openadsdk.TTNativeExpressAd
// import io.github.nullptrx.pangleflutter.common.PangleEventStreamHandler
// import io.github.nullptrx.pangleflutter.common.kBlock
// import io.github.nullptrx.pangleflutter.dialog.AdDialog
//
// class FLTInterstitialAd(var target: Activity?, var result: (Any) -> Unit) :
//   TTAdNative.NativeAdListener, TTAdDislike.DislikeInteractionCallback,
//   TTNativeAd.AdInteractionListener, TTNativeAd.ExpressRenderListener {
//
//   private var ttNativeAd: TTNativeAd? = null
//
//   override fun onNativeAdLoad(ads: MutableList<TTNativeAd>?) {
//     if (ads.isNullOrEmpty()) {
//       return
//     }
//     target ?: return
//     PangleEventStreamHandler.interstitial("load")
//     val ad = ads[0]
//     ad.setDislikeCallback(target, this)
//     ad.setExpressRenderListener(this)
//     ad.registerViewForInteraction(ad.adView as ViewGroup, ad.adView, this)
//     ad.render()
//     this.ttNativeAd = ad
//   }
//
//   override fun onError(code: Int, message: String?) {
//     PangleEventStreamHandler.interstitial("error")
//     invoke(code, message)
//   }
//
//   // ###  DISLIKE START  ###
//   override fun onShow() {
//     PangleEventStreamHandler.interstitial("dislike_show")
//   }
//
//   override fun onSelected(index: Int, selection: String?, fromUser: Boolean) {
//     PangleEventStreamHandler.interstitial("dislike_selected")
//   }
//
//   override fun onCancel() {
//     PangleEventStreamHandler.interstitial("dislike_cancel")
//   }
//   // ###  DISLIKE END  ###
//
//   override fun onAdClicked(view: View?, ad: TTNativeAd?) {
//     PangleEventStreamHandler.interstitial("click")
//   }
//
//   override fun onAdCreativeClick(view: View?, ad: TTNativeAd?) {
//
//   }
//
//   override fun onAdShow(ad: TTNativeAd?) {
//     PangleEventStreamHandler.interstitial("show")
//   }
//
//   override fun onRenderSuccess(view: View, width: Float, height: Float, isExpress: Boolean) {
//     PangleEventStreamHandler.interstitial("render_success")
//     target?.also {
//       ttNativeAd?.showInteractionExpressAd(it)
//     }
//
//   }
//
//
//   private fun invoke(code: Int = 0, message: String? = null) {
//     if (result == kBlock) {
//       return
//     }
//     result.apply {
//       val args = mutableMapOf<String, Any?>()
//       args["code"] = code
//       message?.also {
//         args["message"] = it
//       }
//       invoke(args)
//       result = kBlock
//     }
//     target = null
//   }
//
//
// }