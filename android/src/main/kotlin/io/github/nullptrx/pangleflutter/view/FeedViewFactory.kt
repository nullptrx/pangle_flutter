package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.github.nullptrx.pangleflutter.util.asMap
import java.lang.ref.WeakReference

class FeedViewFactory(val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  private var activity: WeakReference<Activity>? = null

  override fun create(context: Context?, id: Int, args: Any?): PlatformView {
    val params = args?.asMap<String, Any?>() ?: mutableMapOf()
    val act = activity?.get()
    return FlutterFeedView(act!!, messenger, id, params)
  }

  fun attachActivity(activity: Activity) {
    this.activity = WeakReference(activity)
  }

  fun detachActivity() {
    this.activity?.clear()
    this.activity = null
  }
}