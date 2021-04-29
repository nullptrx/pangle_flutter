package io.github.nullptrx.pangleflutter

import com.bytedance.sdk.openadsdk.AdSlot
import com.bytedance.sdk.openadsdk.TTAdConstant
import io.github.nullptrx.pangleflutter.common.PangleOrientation
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.dp

object PangleAdSlotManager {

  fun getSplashAdSlot(slotId: String, imgSize: TTSize, isSupportDeepLink: Boolean): AdSlot {

    return AdSlot.Builder().apply {
      setCodeId(slotId)
      setSupportDeepLink(isSupportDeepLink)
      imgSize.apply {
        setImageAcceptedSize(width.dp, height.dp)
      }
    }.build()
  }

  fun getRewardVideoAdSlot(slotId: String, expressSize: TTSizeF, userId: String?, rewardName: String?, rewardAmount: Int?, isVertical: Boolean, isSupportDeepLink: Boolean, extra: String?): AdSlot {

    return AdSlot.Builder().apply {
      // 必选参数 设置您的CodeId
      setCodeId(slotId)
      // 必选参数 设置广告图片的最大尺寸及期望的图片宽高比，单位Px
      // 注：如果您在头条广告平台选择了原生广告，返回的图片尺寸可能会与您期望的尺寸有较大差异
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
//        setExpressViewAcceptedSize(500f, 500f)
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
  }


  fun getBannerAdSlot(slotId: String, expressSize: TTSizeF, count: Int, isSupportDeepLink: Boolean): AdSlot {

    return AdSlot.Builder().apply {
      setCodeId(slotId)
      requireNotNull(expressSize)
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      setAdCount(count)
      setSupportDeepLink(isSupportDeepLink)
    }
        .build()
  }

  fun getFeedAdSlot(slotId: String, expressSize: TTSizeF, count: Int, isSupportDeepLink: Boolean): AdSlot {
    return AdSlot.Builder().apply {
      setCodeId(slotId)
      setSupportDeepLink(isSupportDeepLink)
      // 请求原生广告时候，请务必调用该方法，设置参数为TYPE_BANNER或TYPE_INTERACTION_AD
      // setNativeAdType()
      setAdCount(count)
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
    }
        .build()
  }

  fun getInterstitialAdSlot(slotId: String, expressSize: TTSizeF, isSupportDeepLink: Boolean): AdSlot {

    return AdSlot.Builder().apply {
      setCodeId(slotId)
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      setSupportDeepLink(isSupportDeepLink)
      //请求原生广告时候，请务必调用该方法，设置参数为TYPE_BANNER或TYPE_INTERACTION_AD
      setAdCount(1)
    }
        .build()
  }


  fun getFullScreenVideoAdSlot(slotId: String, expressSize: TTSizeF, orientation: PangleOrientation, isSupportDeepLink: Boolean): AdSlot {

    return AdSlot.Builder().apply {
      // 必选参数 设置您的CodeId
      setCodeId(slotId)
      // 必选参数 设置广告图片的最大尺寸及期望的图片宽高比，单位Px
      // 注：如果您在头条广告平台选择了原生广告，返回的图片尺寸可能会与您期望的尺寸有较大差异
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      // 可选参数 设置是否支持deeplink
      setSupportDeepLink(isSupportDeepLink)
      //设置期望视频播放的方向，为TTAdConstant.HORIZONTAL或TTAdConstant.VERTICAL
//      setOrientation(if (isVertical) TTAdConstant.VERTICAL else TTAdConstant.HORIZONTAL)
      setOrientation(orientation.ordinal)
      //激励视频奖励透传参数，字符串，如果用json对象，必须使用序列化为String类型,可为空
    }.build()
  }

  fun getNativeBannerAdSlot(slotId: String, size: TTSize, count: Int, isSupportDeepLink: Boolean): AdSlot {

    return AdSlot.Builder().apply {
      setCodeId(slotId)
      setImageAcceptedSize(size.width, size.height)
      setAdCount(count)
      setSupportDeepLink(isSupportDeepLink)
    }
        .build()
  }
}
