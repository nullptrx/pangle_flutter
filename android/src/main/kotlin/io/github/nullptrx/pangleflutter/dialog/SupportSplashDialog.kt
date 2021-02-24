package io.github.nullptrx.pangleflutter.dialog

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import io.github.nullptrx.pangleflutter.util.DialogUtil
import java.lang.reflect.Field

class SupportSplashDialog : DialogFragment() {

  private lateinit var layoutView: View
  private lateinit var ctx: Context

  override fun onAttach(context: Context) {
    super.onAttach(context)
    ctx = context
  }

  override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
    return DialogUtil.createDialog(ctx)
  }

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
    return layoutView
  }

  override fun onSaveInstanceState(outState: Bundle) {
  }

  fun show(manager: FragmentManager, view: View) {
    layoutView = view
    try {
      val mDismissed: Field = DialogFragment::class.java.getDeclaredField("mDismissed")
      mDismissed.isAccessible = true
      mDismissed.set(this, false)
      val mShownByMe: Field = DialogFragment::class.java.getDeclaredField("mShownByMe")
      mShownByMe.isAccessible = true
      mShownByMe.set(this, true)
    } catch (_: Exception) {
    }
    val ft: FragmentTransaction = manager.beginTransaction()
    ft.add(this, javaClass.simpleName)
    ft.commitAllowingStateLoss()
  }
}
