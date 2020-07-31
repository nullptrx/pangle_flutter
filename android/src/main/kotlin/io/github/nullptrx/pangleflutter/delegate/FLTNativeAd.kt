//package io.github.nullptrx.pangleflutter.delegate
//
//import com.bytedance.sdk.openadsdk.TTAdNative
//import com.bytedance.sdk.openadsdk.TTNativeAd
//import io.flutter.plugin.common.MethodChannel
//import java.lang.ref.WeakReference
//
//internal class FLTNativeAd(result: MethodChannel.Result) : TTAdNative.NativeAdListener {
//
//  val result: WeakReference<MethodChannel.Result>
//
//  init {
//    this.result = WeakReference(result)
//  }
//
//  override fun onNativeAdLoad(ads: List<TTNativeAd>?) {
//    val datas = mutableListOf<Map<String, Any?>>()
//    if (ads != null) {
//
//      val data = mutableMapOf<String, Any?>()
//      for (ad in ads) {
//
//        val adLogo = ad.adLogo
//        val appCommentNum = ad.appCommentNum
//        val appScore = ad.appScore
//        val appSize = ad.appSize
//        val buttonText = ad.buttonText
//        val description = ad.description
//        val downloadStatusController = ad.downloadStatusController
//        val icon = ad.icon
//        val imageList = ad.imageList
//        for (ttImage in imageList) {
//          val height = ttImage.height
//          val width = ttImage.width
//          val imageUrl = ttImage.imageUrl
//          println()
//        }
//        println()
//
//      }
//
//    }
//    val methodResult = result.get()
//    methodResult?.success(datas)
//    result.clear()
//  }
//
//  override fun onError(code: Int, message: String?) {
//    val datas = mutableListOf<Map<String, Any?>>()
//    val methodResult = result.get()
//    methodResult?.success(datas)
//    result.clear()
//  }
//
//}