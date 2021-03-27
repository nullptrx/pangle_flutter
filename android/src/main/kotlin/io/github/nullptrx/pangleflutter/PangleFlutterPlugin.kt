package io.github.nullptrx.pangleflutter

import io.flutter.plugin.common.PluginRegistry.Registrar

/** PangleFlutterPlugin */
class PangleFlutterPlugin : PangleFlutterPluginImpl() {
  companion object {

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      PangleFlutterPluginImpl.registerWith(registrar)
    }
  }
}
