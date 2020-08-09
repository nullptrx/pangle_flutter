package io.github.nullptrx.pangleflutter.util

import android.content.res.Resources
import android.view.View

/**
 * 像素密度计算工具
 */

val density: Float = Resources.getSystem().displayMetrics.density

/**
 * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
 * @param dpValue 虚拟像素
 * @return 像素
 */
val Int.dp
  get() = (0.5f + this * density).toInt()


/**
 * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
 * @param dpValue 虚拟像素
 * @return 像素
 */
val Float.dp
  get() = (0.5f + this * density).toInt()
val Double.dp
  get() = (0.5f + this * density).toInt()

/**
 * 根据手机的分辨率从 px(像素) 的单位 转成为 dp
 * @param pxValue 像素
 * @return 虚拟像素
 */
val Number.px
  get() = this.toFloat() / Resources.getSystem().displayMetrics.density


operator fun <T : View> View.get(id: Int): T? {
  return findViewById(id)
}

fun <T : View> View.find(id: Int): T? {
  return findViewById(id)
}