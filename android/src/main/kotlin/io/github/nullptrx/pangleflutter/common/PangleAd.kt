package io.github.nullptrx.pangleflutter.common

import com.bytedance.sdk.openadsdk.TTBannerAd
import com.bytedance.sdk.openadsdk.TTFeedAd
import com.bytedance.sdk.openadsdk.TTNativeExpressAd

data class PangleExpressAd(
    val size: TTSizeF,
    val ad: TTNativeExpressAd,
)

data class PangleBannerAd(
    val size: TTSize,
    val ad: TTBannerAd,
)

data class PangleFeedAd(
    val size: TTSize,
    val ad: TTFeedAd,
)