package io.github.nullptrx.pangleflutter.dialog

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import io.github.nullptrx.pangleflutter.util.DialogUtil

class SupportSplashDialog(private val layoutView: View) : DialogFragment() {

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

}
