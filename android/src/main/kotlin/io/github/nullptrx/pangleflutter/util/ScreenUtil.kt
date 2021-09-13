package io.github.nullptrx.pangleflutter.util

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.os.Build
import android.view.View
import android.view.WindowManager
import io.github.nullptrx.pangleflutter.common.TTSize
import io.github.nullptrx.pangleflutter.common.TTSizeF
import java.lang.reflect.InvocationTargetException

object ScreenUtil {
  /**
   * 获取当前的屏幕尺寸
   * @return 屏幕尺寸
   */
  fun getScreenSize(): TTSize {
    val dm = Resources.getSystem().displayMetrics
    return TTSize(dm.widthPixels, dm.heightPixels)
  }

  fun getScreenSizeDp(): TTSizeF {
    val dm = Resources.getSystem().displayMetrics
    return TTSizeF(dm.widthPixels.px, dm.heightPixels.px)
  }

  fun getScreenWidthDp(): Float {
    val displayMetrics = Resources.getSystem().displayMetrics
    val density = displayMetrics.density
    val width = displayMetrics.widthPixels.toFloat()
    val scale = (if (density <= 0) 1f else density)
    return width / scale + 0.5f
  }

  //全面屏、刘海屏适配
  fun getHeight(activity: Activity): Float {
    hideBottomUIMenu(activity)
    val height: Float
    val realHeight = getRealHeight()
    height = if (hasNotchScreen(activity)) {
      px2dip(realHeight - getStatusBarHeight()).toFloat()
    } else {
      px2dip(realHeight.toFloat()).toFloat()
    }
    return height
  }

  fun hideBottomUIMenu(activity: Activity?) {
    if (activity == null) {
      return
    }
    try {
      //隐藏虚拟按键，并且全屏
      if (Build.VERSION.SDK_INT > 11 && Build.VERSION.SDK_INT < 19) { // lower api
        val v = activity.window.decorView
        v.systemUiVisibility = View.GONE
      } else if (Build.VERSION.SDK_INT >= 19) {
        //for new api versions.
        val decorView = activity.window.decorView
        val uiOptions = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
            //                    | View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
            or View.SYSTEM_UI_FLAG_IMMERSIVE)
        decorView.systemUiVisibility = uiOptions
        activity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  //获取屏幕真实高度，不包含下方虚拟导航栏
  fun getRealHeight(): Int {
    val dm = Resources.getSystem().displayMetrics
    return dm.heightPixels
  }

  //获取状态栏高度
  fun getStatusBarHeight(): Float {
    var height = 0f
    val resourceId = Resources.getSystem().getIdentifier("status_bar_height", "dimen", "android")
    if (resourceId > 0) {
      height = Resources.getSystem().getDimensionPixelSize(resourceId).toFloat()
    }
    return height
  }

  fun px2dip(pxValue: Float): Int {
    val displayMetrics = Resources.getSystem().displayMetrics
    val density = displayMetrics.density
    val scale = (if (density <= 0) 1f else density)
    return (pxValue / scale + 0.5f).toInt()
  }

  /**
   * 判断是否是刘海屏
   * @return
   */
  fun hasNotchScreen(context: Context): Boolean {
    return (getInt("ro.miui.notch", context) == 1 || hasNotchAtHuawei(context) || hasNotchAtOPPO(context)
        || hasNotchAtVivo(context) || isAndroidPHasNotch())
  }

  /**
   * Android P 刘海屏判断
   * @param activity
   * @return
   */
  fun isAndroidPHasNotch(): Boolean {
    var ret = false
    if (Build.VERSION.SDK_INT >= 28) {
      try {
        val windowInsets = Class.forName("android.view.WindowInsets")
        val method = windowInsets.getMethod("getDisplayCutout")
        val displayCutout = method.invoke(windowInsets)
        if (displayCutout != null) {
          ret = true
        }
      } catch (e: Exception) {
      }
    }
    return ret
  }

  /**
   * 小米刘海屏判断.
   * @return 0 if it is not notch ; return 1 means notch
   * @throws IllegalArgumentException if the key exceeds 32 characters
   */
  fun getInt(key: String, context: Context): Int {
    var result = 0
    if (isMiui()) {
      try {
        val classLoader = context.classLoader
        val SystemProperties = classLoader.loadClass("android.os.SystemProperties")
        //参数类型
        val paramTypes = arrayOfNulls<Class<*>?>(2)
        paramTypes[0] = String::class.java
        paramTypes[1] = Int::class.javaPrimitiveType
        val getInt = SystemProperties.getMethod("getInt", *paramTypes)
        //参数
        val params = arrayOfNulls<Any>(2)
        params[0] = key
        params[1] = 0
        result = getInt.invoke(SystemProperties, *params) as Int
      } catch (e: ClassNotFoundException) {
        e.printStackTrace()
      } catch (e: NoSuchMethodException) {
        e.printStackTrace()
      } catch (e: IllegalAccessException) {
        e.printStackTrace()
      } catch (e: IllegalArgumentException) {
        e.printStackTrace()
      } catch (e: InvocationTargetException) {
        e.printStackTrace()
      }
    }
    return result
  }

  /**
   * 华为刘海屏判断
   * @return
   */
  fun hasNotchAtHuawei(context: Context): Boolean {
    var ret = false
    try {
      val classLoader = context.classLoader
      val HwNotchSizeUtil = classLoader.loadClass("com.huawei.android.util.HwNotchSizeUtil")
      val get = HwNotchSizeUtil.getMethod("hasNotchInScreen")
      ret = get.invoke(HwNotchSizeUtil) as Boolean
    } catch (e: ClassNotFoundException) {
    } catch (e: NoSuchMethodException) {
    } catch (e: Exception) {
    } finally {
      return ret
    }
  }

  const val VIVO_NOTCH = 0x00000020 //是否有刘海

  const val VIVO_FILLET = 0x00000008 //是否有圆角


  /**
   * VIVO刘海屏判断
   * @return
   */
  fun hasNotchAtVivo(context: Context): Boolean {
    var ret = false
    try {
      val classLoader = context.classLoader
      val FtFeature = classLoader.loadClass("android.util.FtFeature")
      val method = FtFeature.getMethod("isFeatureSupport", Int::class.javaPrimitiveType)
      ret = method.invoke(FtFeature, VIVO_NOTCH) as Boolean
    } catch (e: ClassNotFoundException) {
    } catch (e: NoSuchMethodException) {
    } catch (e: Exception) {
    } finally {
      return ret
    }
  }

  /**
   * OPPO刘海屏判断
   * @return
   */
  fun hasNotchAtOPPO(context: Context): Boolean {
    return context.packageManager.hasSystemFeature("com.oppo.feature.screen.heteromorphism")
  }

  fun isMiui(): Boolean {
    var sIsMiui = false
    try {
      Class.forName("miui.os.Build")
      sIsMiui = true
      return sIsMiui
    } catch (e: Exception) {
      // ignore
    }
    return sIsMiui
  }
}