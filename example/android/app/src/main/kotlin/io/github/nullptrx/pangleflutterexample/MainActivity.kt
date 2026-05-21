package io.github.nullptrx.pangleflutterexample

import com.bytedance.tools.util.ToolsUtil
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pangle_test_tools")
            .setMethodCallHandler { call, result ->
                if (call.method == "showTestSuite") {
                    ToolsUtil.start(this)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
