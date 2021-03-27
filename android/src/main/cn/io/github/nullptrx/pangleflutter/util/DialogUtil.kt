package io.github.nullptrx.pangleflutter.util

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.view.View
import android.view.Window
import android.view.WindowManager
import io.github.nullptrx.pangleflutter.R

object DialogUtil {


  fun createDialog(context: Context): Dialog {
    // 使用不带Theme的构造器, 获得的dialog边框距离屏幕仍有几毫米的缝隙。
    val dialog = Dialog(context, R.style.PangleFlutterAdDialog).apply {
      requestWindowFeature(Window.FEATURE_NO_TITLE) // 设置Content前设定

      setCancelable(false)
      setCanceledOnTouchOutside(false) // 外部点击取消
      window?.apply {
        setWindowAnimations(R.style.PangleFlutterAnimNoAnim)
        setBackgroundDrawable(ColorDrawable(Color.BLACK))
//        addFlags(FLAG_LAYOUT_NO_LIMITS or FLAG_FULLSCREEN or FLAG_LAYOUT_IN_SCREEN)

        decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN)
        // 设置页面全屏显示
        val lp = attributes
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
          lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
        // 设置页面延伸到刘海区显示
        attributes = lp
      }

    }
    return dialog
  }

}