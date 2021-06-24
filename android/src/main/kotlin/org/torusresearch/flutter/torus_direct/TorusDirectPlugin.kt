package org.torusresearch.flutter.torus_direct

import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.torusresearch.torusdirect.types.DirectSdkArgs
import org.torusresearch.torusdirect.types.TorusNetwork

/** TorusDirectPlugin */
class TorusDirectPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var torusDirectArgs: DirectSdkArgs

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "torus_direct")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                torusDirectArgs = DirectSdkArgs(
                    "https://scripts.toruswallet.io/redirect.html",
                    TorusNetwork.valueOfLabel(call.argument("network")),
                    call.argument("redirectUri")
                )
                Log.d(
                    "${javaClass.simpleName}#init",
                    "network=${torusDirectArgs.network}, redirectUri=${torusDirectArgs.redirectUri}"
                )
                result.success(null)
            }
            "triggerLogin" -> {
                Log.d(
                    "${javaClass.simpleName}#triggerLogin", "" +
                            "typeOfLogin=${call.argument<String>("typeOfLogin")}, " +
                            "verifier=${call.argument<String>("verifier")}, " +
                            "clientId=${call.argument<String>("clientId")}"
                )
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
