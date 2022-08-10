package io.github.nullptrx.pangleflutter.common

import io.flutter.plugin.common.EventChannel

class PangleEventStreamHandler : EventChannel.StreamHandler {

  companion object {

    private var eventSinks = hashMapOf<PangleEventType, EventChannel.EventSink?>()

    fun interstitial(event: String = "unknown") {
      eventSinks[PangleEventType.interstitial]?.success(event)
    }

    fun fullscreen(event: String = "unknown") {
      eventSinks[PangleEventType.fullscreen]?.success(event)
    }

    fun rewardedVideo(event: String = "unknown") {
      eventSinks[PangleEventType.rewarded_video]?.success(event)
    }

    fun clear() {
      eventSinks.clear()
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    for (type in PangleEventType.values()) {
      if (type.ordinal == arguments) {
        eventSinks[type] = events
        break
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    for (type in PangleEventType.values()) {
      if (type.ordinal == arguments) {
        eventSinks.remove(type)
        break
      }
    }
  }
}