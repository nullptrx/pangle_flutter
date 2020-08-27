package io.github.nullptrx.pangleflutter.common

import android.content.res.Resources

enum class PangleImgSize(val width: Int = 0, val height: Int = 0) {
  banner640_90(640, 90),
  banner640_100(640, 100),
  banner600_150(600, 150),
  banner600_260(600, 260),
  banner600_286(600, 286),
  banner600_300(600, 300),
  banner690_388(690, 388),
  banner600_400(600, 400),
  banner600_500(600, 500),
  feed228_150(228, 150),
  feed690_388(690, 388),
  interstitial600_400(600, 400),
  interstitial600_600(600, 600),
  interstitial600_900(600, 900),
  drawFullScreen;

  fun toDeviceSize(): TTSize {
    val displayMetrics = Resources.getSystem().displayMetrics
    val w = displayMetrics.widthPixels
    val h = displayMetrics.widthPixels * height / width.toFloat()
    return TTSize(w, h.toInt())
  }
  
  fun toDeviceSizeF(): TTSizeF {
    val displayMetrics = Resources.getSystem().displayMetrics
    val w = displayMetrics.widthPixels
    val h = displayMetrics.widthPixels * height / width.toFloat()
    return TTSizeF(w.toFloat(), h)
  }

}