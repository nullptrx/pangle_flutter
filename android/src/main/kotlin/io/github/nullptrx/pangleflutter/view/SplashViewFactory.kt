package io.github.nullptrx.pangleflutter.view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SplashViewFactory(val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, id: Int, args: Any?): PlatformView? {
    val params: Map<String, Any?> = args as? Map<String, Any?> ?: mutableMapOf()
    return FlutterSplashView(context, messenger, id, params)
  }

}