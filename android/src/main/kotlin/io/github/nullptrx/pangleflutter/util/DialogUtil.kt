package io.github.nullptrx.pangleflutter.util

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.view.View
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager

import io.github.nullptrx.pangleflutter.R

object DialogUtil {

  fun createDialog(context: Context): Dialog {
    val dialog = Dialog(context, R.style.PangleFlutterAdDialog).apply {
      requestWindowFeature(Window.FEATURE_NO_TITLE)
      setCancelable(false)
      setCanceledOnTouchOutside(false)
      window?.apply {
        setWindowAnimations(R.style.PangleFlutterAnimNoAnim)
        setBackgroundDrawable(ColorDrawable(Color.BLACK))

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          // API 30+：使用 WindowInsetsController
          insetsController?.hide(WindowInsets.Type.statusBars())
          insetsController?.systemBarsBehavior =
            WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        } else {
          // API 24-29：保留旧方式
          @Suppress("DEPRECATION")
          decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
          @Suppress("DEPRECATION")
          setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
          )
        }

        // 刘海屏适配
        val lp = attributes
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
          lp.layoutInDisplayCutoutMode =
            WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
        attributes = lp
      }
    }
    return dialog
  }
}
