package io.github.nullptrx.pangleflutter.view

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.lang.ref.WeakReference

class FeedViewFactory(val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  private var activity: WeakReference<Activity>? = null

  override fun create(context: Context, id: Int, args: Any?): PlatformView? {
    val params = args as? Map<String, Any?>
    val act = activity?.get()
    if (act == null) {
      return null
    }
    return FlutterFeedView(act, messenger, id, params
        ?: mutableMapOf())
  }

  fun attachActivity(activity: Activity) {
    this.activity = WeakReference(activity)
  }

  fun detachActivity() {
    this.activity?.clear()
    this.activity = null
  }
}