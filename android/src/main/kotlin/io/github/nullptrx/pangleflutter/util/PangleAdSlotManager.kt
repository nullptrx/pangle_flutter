package io.github.nullptrx.pangleflutter.util

import android.app.Activity
import com.bytedance.sdk.openadsdk.AdSlot
import com.bytedance.sdk.openadsdk.TTAdConstant
import io.github.nullptrx.pangleflutter.common.PangleImgSize

object PangleAdSlotManager {

  fun getSplashAdSlot(slotId: String, isExpress: Boolean, activity: Activity?, isSupportDeepLink: Boolean): AdSlot {
    val adSlot = AdSlot.Builder().apply {
      setCodeId(slotId)
      setSupportDeepLink(isSupportDeepLink)
      if (isExpress) {
        activity?.also {
          //个性化模板广告需要传入期望广告view的宽、高，单位dp，请传入实际需要的大小，
          //比如：广告下方拼接logo、适配刘海屏等，需要考虑实际广告大小
          val expressViewWidth: Float = ScreenUtil.getScreenWidthDp()
          val expressViewHeight: Float = ScreenUtil.getHeight(it)
          setExpressViewAcceptedSize(expressViewWidth, expressViewHeight)
        }
      } else {
        setImageAcceptedSize(1080, 1920)
      }
    }.build()

    return adSlot
  }

  fun getRewardVideoAdSlot(slotId: String, userId: String?, rewardName: String?, rewardAmount: Int?, isVertical: Boolean, isSupportDeepLink: Boolean, extra: String?): AdSlot {

    val adSlot = AdSlot.Builder().apply {
// 必选参数 设置您的CodeId
      setCodeId(slotId)
      // 必选参数 设置广告图片的最大尺寸及期望的图片宽高比，单位Px
      // 注：如果您在头条广告平台选择了原生广告，返回的图片尺寸可能会与您期望的尺寸有较大差异
      setImageAcceptedSize(1080, 1920)
      // 可选参数 设置是否支持deeplink
      setSupportDeepLink(isSupportDeepLink)
      //激励视频奖励的名称，针对激励视频参数
      rewardName?.also {
        setRewardName(it)
      }
      //激励视频奖励个数
      rewardAmount?.also {
        setRewardAmount(it)
      }
      //用户ID,使用激励视频必传参数
      //表来标识应用侧唯一用户；若非服务器回调模式或不需sdk透传，可设置为空字符串
      setUserID(userId ?: "")
      //设置期望视频播放的方向，为TTAdConstant.HORIZONTAL或TTAdConstant.VERTICAL
      setOrientation(if (isVertical) TTAdConstant.VERTICAL else TTAdConstant.HORIZONTAL)
      //激励视频奖励透传参数，字符串，如果用json对象，必须使用序列化为String类型,可为空
      extra?.also {
        setMediaExtra(it)
      }
    }.build()
    return adSlot
  }


  fun getBannerAdSlot(slotId: String, isExpress: Boolean, imgSizeIndex: Int, isSupportDeepLink: Boolean): AdSlot {
    val imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()

    val adSlot = AdSlot.Builder().apply {
      setCodeId(slotId)
      if (isExpress) {
        setExpressViewAcceptedSize(imgSize.width.px, imgSize.height.px)
      } else {
        setImageAcceptedSize(imgSize.width, imgSize.height)
      }
      setImageAcceptedSize(imgSize.width, imgSize.height)
      setSupportDeepLink(isSupportDeepLink)
    }
        .build()
    return adSlot
  }

  fun getFeedAdSlot(slotId: String, isExpress: Boolean, count: Int, imgSizeIndex: Int, isSupportDeepLink: Boolean): AdSlot {
    val imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()
    val adSlot = AdSlot.Builder().apply {
      setCodeId(slotId)
      setSupportDeepLink(isSupportDeepLink)
      setIsAutoPlay(false)
      // 请求原生广告时候，请务必调用该方法，设置参数为TYPE_BANNER或TYPE_INTERACTION_AD
      // setNativeAdType()
      setAdCount(count)
      if (isExpress) {
        setExpressViewAcceptedSize(imgSize.width.px, imgSize.height.px)
      } else {
        setImageAcceptedSize(imgSize.width, imgSize.height)
      }
    }
        .build()
    return adSlot
  }

  fun getInterstitialAdSlot(slotId: String, isExpress: Boolean, imgSizeIndex: Int, isSupportDeepLink: Boolean, isNativeAd: Boolean): AdSlot {
    val imgSize = PangleImgSize.values()[imgSizeIndex].toDeviceSize()

    val width = imgSize.width * 0.9
    val height = imgSize.height * 0.9
    val adSlot = AdSlot.Builder().apply {
      setCodeId(slotId)
      if (isExpress) {
        setExpressViewAcceptedSize(width.px, height.px)
      } else {
        setImageAcceptedSize(width.toInt(), height.toInt())
      }
      setSupportDeepLink(isSupportDeepLink)
      //请求原生广告时候，请务必调用该方法，设置参数为TYPE_BANNER或TYPE_INTERACTION_AD
      setAdCount(1)
      // TODO support native ad type
      if (isNativeAd) {
        setNativeAdType(AdSlot.TYPE_INTERACTION_AD)
      }
    }
        .build()
    return adSlot
  }
}
