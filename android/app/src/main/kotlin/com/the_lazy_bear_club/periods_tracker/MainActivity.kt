package com.the_lazy_bear_club.periods_tracker

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth needs a FragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        // Secure until Dart says otherwise, so the first frames are covered too.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lunacycle/privacy")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setHidePreview" -> {
                        if (call.argument<Boolean>("hide") == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    // Android backups are disabled in the manifest instead.
                    "excludeFromBackup" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }
}
