package io.github.nullptrx.pangleflutter

import com.bytedance.sdk.openadsdk.AdSlot
import com.bytedance.sdk.openadsdk.TTAdConstant
import io.github.nullptrx.pangleflutter.common.PangleOrientation
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import io.github.nullptrx.pangleflutter.util.dp

object PangleAdSlotManager {

  /**
   * 开屏广告 AdSlot
   *
   * @param slotId          必选，广告位 CodeId
   * @param imgSize         必选，期望图片尺寸（dp），用于非模板开屏
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   */
  fun getSplashAdSlot(
    slotId: String,
    imgSize: TTSize,
    isSupportDeepLink: Boolean,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
      // 必选：期望图片宽高（单位 dp → px），影响开屏素材的选取
      setImageAcceptedSize(imgSize.width.dp, imgSize.height.dp)
    }.build()
  }

  /**
   * 激励视频广告 AdSlot
   *
   * @param slotId          必选，广告位 CodeId
   * @param expressSize     必选，模板视图期望宽高（dp），影响模板渲染尺寸
   * @param userId          可选，应用侧用户唯一标识，服务器回调模式时透传；不需要时传空字符串
   * @param isVertical      可选，期望视频方向，true 竖屏，false 横屏
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   * @param extra           可选，透传参数，JSON 需序列化为 String
   */
  fun getRewardVideoAdSlot(
    slotId: String,
    expressSize: TTSizeF,
    userId: String?,
    isVertical: Boolean,
    isSupportDeepLink: Boolean,
    extra: String?,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 必选：模板视图期望宽高（dp），决定激励视频模板渲染尺寸
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
      // 可选：应用侧用户唯一标识，服务器回调模式时透传
      setUserID(userId ?: "")
      // 可选：期望视频播放方向
      setOrientation(if (isVertical) TTAdConstant.VERTICAL else TTAdConstant.HORIZONTAL)
      // 可选：奖励透传参数，JSON 对象需先序列化为 String
      extra?.also { setMediaExtra(it) }
    }.build()
  }

  /**
   * Banner 广告 AdSlot（模板渲染）
   *
   * @param slotId          必选，广告位 CodeId
   * @param expressSize     必选，模板视图期望宽高（dp）
   * @param count           必选，请求广告数量（1~3）
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   * @param imgSize         可选，原生广告图片期望尺寸（dp）；
   *                        仅在需要同时支持模板与原生两种样式切换时传入，纯模板场景可不传
   */
  fun getBannerAdSlot(
    slotId: String,
    expressSize: TTSizeF,
    count: Int,
    isSupportDeepLink: Boolean,
    imgSize: TTSize? = null,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 可选：原生广告图片期望尺寸（dp → px）；支持模板+原生样式切换时需传
      imgSize?.also { setImageAcceptedSize(it.width.dp, it.height.dp) }
      // 必选（模板广告）：声明支持模板渲染控制，配合 setExpressViewAcceptedSize 使用
      supportRenderControl()
      // 必选（模板广告）：模板视图期望宽高（dp），决定广告渲染尺寸与比例
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      // 必选：请求广告数量
      setAdCount(count)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
    }.build()
  }

  /**
   * 信息流广告 AdSlot（模板渲染）
   *
   * @param slotId          必选，广告位 CodeId
   * @param expressSize     必选，模板视图期望宽高（dp）；需与后台广告位配置的模板尺寸比例一致，
   *                        否则广告内容无法填满容器
   * @param count           必选，请求广告数量（1~3）
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   * @param imgSize         可选，原生广告图片期望尺寸（dp）；
   *                        仅在需要同时支持模板与原生两种样式切换时传入，纯模板场景可不传
   */
  fun getFeedAdSlot(
    slotId: String,
    expressSize: TTSizeF,
    count: Int,
    isSupportDeepLink: Boolean,
    imgSize: TTSize? = null,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
      // 必选：请求广告数量
      setAdCount(count)
      // 可选：原生广告图片期望尺寸（dp → px）；支持模板+原生样式切换时需传
      imgSize?.also { setImageAcceptedSize(it.width.dp, it.height.dp) }
      // 必选（模板广告）：声明支持模板渲染控制，配合 setExpressViewAcceptedSize 使用
      supportRenderControl()
      // 必选（模板广告）：模板视图期望宽高（dp），决定广告渲染尺寸与比例
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
    }.build()
  }

  /**
   * 插屏广告 AdSlot（模板渲染）
   *
   * @param slotId          必选，广告位 CodeId
   * @param expressSize     必选，模板视图期望宽高（dp）
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   * @param imgSize         可选，原生广告图片期望尺寸（dp）；
   *                        仅在需要同时支持模板与原生两种样式切换时传入，纯模板场景可不传
   */
  fun getInterstitialAdSlot(
    slotId: String,
    expressSize: TTSizeF,
    isSupportDeepLink: Boolean,
    imgSize: TTSize? = null,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 可选：原生广告图片期望尺寸（dp → px）；支持模板+原生样式切换时需传
      imgSize?.also { setImageAcceptedSize(it.width.dp, it.height.dp) }
      // 必选（模板广告）：声明支持模板渲染控制，配合 setExpressViewAcceptedSize 使用
      supportRenderControl()
      // 必选（模板广告）：模板视图期望宽高（dp），决定广告渲染尺寸与比例
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
      // 插屏每次请求 1 条
      setAdCount(1)
    }.build()
  }

  /**
   * 全屏视频广告 AdSlot
   *
   * @param slotId          必选，广告位 CodeId
   * @param expressSize     必选，模板视图期望宽高（dp）
   * @param orientation     可选，期望视频播放方向，默认竖屏
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   */
  fun getFullScreenVideoAdSlot(
    slotId: String,
    expressSize: TTSizeF,
    orientation: PangleOrientation,
    isSupportDeepLink: Boolean,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 必选：模板视图期望宽高（dp），决定全屏视频模板渲染尺寸
      setExpressViewAcceptedSize(expressSize.width, expressSize.height)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
      // 可选：期望视频播放方向（TTAdConstant.VERTICAL / HORIZONTAL）
      setOrientation(orientation.ordinal)
    }.build()
  }

  /**
   * 原生 Banner 广告 AdSlot（非模板，纯原生渲染）
   *
   * @param slotId          必选，广告位 CodeId
   * @param size            必选，期望图片尺寸（px）
   * @param count           必选，请求广告数量
   * @param isSupportDeepLink 可选，是否支持 DeepLink，默认 true
   */
  fun getNativeBannerAdSlot(
    slotId: String,
    size: TTSize,
    count: Int,
    isSupportDeepLink: Boolean,
  ): AdSlot {
    return AdSlot.Builder().apply {
      // 必选：广告位 ID
      setCodeId(slotId)
      // 必选：期望图片宽高（px），原生广告不走模板渲染，直接指定素材尺寸
      setImageAcceptedSize(size.width, size.height)
      // 必选：请求广告数量
      setAdCount(count)
      // 可选：是否支持 DeepLink
      setSupportDeepLink(isSupportDeepLink)
    }.build()
  }
}
