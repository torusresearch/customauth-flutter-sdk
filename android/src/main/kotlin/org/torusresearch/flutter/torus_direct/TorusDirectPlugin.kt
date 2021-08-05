package org.torusresearch.flutter.torus_direct

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.torusresearch.torusdirect.TorusDirectSdk
import org.torusresearch.torusdirect.types.*
import org.torusresearch.torusdirect.utils.Helpers.unwrapCompletionException

/** TorusDirectPlugin */
class TorusDirectPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var activity: Activity? = null
    private lateinit var context: Context
    private lateinit var torusDirectArgs: DirectSdkArgs

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "torus_direct")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                val response = runMethodCall(call)
                launch(Dispatchers.Main) { result.success(response) }
            } catch (e: NotImplementedError) {
                launch(Dispatchers.Main) { result.notImplemented() }
            } catch (e: Throwable) {
                launch(Dispatchers.Main) {
                    val unwrappedError = unwrapCompletionException(e)
                    result.error(unwrappedError::class.simpleName, unwrappedError.message, null)
                }
            }
        }
    }

    private fun runMethodCall(@NonNull call: MethodCall): Any? {
        when (call.method) {
            "init" -> {
                torusDirectArgs = DirectSdkArgs(
                    call.argument("browserRedirectUri"),
                    TorusNetwork.valueOfLabel(call.argument("network")),
                    call.argument("redirectUri")
                )
                Log.d(
                    "${TorusDirectPlugin::class.qualifiedName}#init",
                    "network=${torusDirectArgs.network}, redirectUri=${torusDirectArgs.redirectUri}"
                )
                return null
            }
            "triggerLogin" -> {
                val torusDirectSdk =
                    TorusDirectSdk(torusDirectArgs, activity ?: context)
                val torusResponse = torusDirectSdk.triggerLogin(
                    SubVerifierDetails(
                        LoginType.valueOfLabel(call.argument("typeOfLogin")),
                        call.argument<String>("verifier"),
                        call.argument<String>("clientId"),
                        mapJwtParams(call.argument("jwtParams")),
                        activity == null
                    )
                ).join()
                Log.d(
                    "${TorusDirectPlugin::class.qualifiedName}#triggerLogin",
                    "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                    "userInfo" to torusResponse.userInfo,
                    "publicAddress" to torusResponse.publicAddress,
                    "privateKey" to torusResponse.privateKey
                )
            }
            "getTorusKey" -> {
                val torusDirectSdk =
                    TorusDirectSdk(torusDirectArgs, activity ?: context)
                val torusResponse = torusDirectSdk.getTorusKey(
                    call.argument("verifier"),
                    call.argument("verifierId"),
                    call.argument("verifierParams"),
                    call.argument("idToken")
                ).join()
                Log.d(
                    "${TorusDirectPlugin::class.qualifiedName}#getTorusKey",
                    "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                    "publicAddress" to torusResponse.publicAddress,
                    "privateKey" to torusResponse.privateKey
                )
            }
        }
        throw NotImplementedError()
    }

    private fun mapJwtParams(jwtParams: Map<String, Any>?): Auth0ClientOptions? {
        if (jwtParams == null || !jwtParams.containsKey("domain")) {
            return Auth0ClientOptions.Auth0ClientOptionsBuilder("").build()
        }

        val builder = Auth0ClientOptions.Auth0ClientOptionsBuilder(jwtParams["domain"] as String)
        if (jwtParams.containsKey("isVerifierIdCaseSensitive")) {
            builder.setVerifierIdCaseSensitive(jwtParams["isVerifierIdCaseSensitive"] as Boolean)
        }
        if (jwtParams.containsKey("client_id")) {
            builder.setClient_id(jwtParams["client_id"] as String)
        }
        if (jwtParams.containsKey("leeway")) {
            builder.setLeeway(jwtParams["leeway"] as String)
        }
        if (jwtParams.containsKey("verifierIdField")) {
            builder.setVerifierIdField(jwtParams["verifierIdField"] as String)
        }
        if (jwtParams.containsKey("display")) {
            builder.setDisplay(Display.valueOfLabel(jwtParams["display"] as String))
        }
        if (jwtParams.containsKey("prompt")) {
            builder.setPrompt(Prompt.valueOfLabel(jwtParams["prompt"] as String))
        }
        if (jwtParams.containsKey("max_age")) {
            builder.setMax_age(jwtParams["max_age"] as String)
        }
        if (jwtParams.containsKey("ui_locales")) {
            builder.setUi_locales(jwtParams["ui_locales"] as String)
        }
        if (jwtParams.containsKey("id_token_hint")) {
            builder.setId_token_hint(jwtParams["id_token_hint"] as String)
        }
        if (jwtParams.containsKey("login_hint")) {
            builder.setLogin_hint(jwtParams["login_hint"] as String)
        }
        if (jwtParams.containsKey("acr_values")) {
            builder.setAcr_values(jwtParams["acr_values"] as String)
        }
        if (jwtParams.containsKey("scope")) {
            builder.setScope(jwtParams["scope"] as String)
        }
        if (jwtParams.containsKey("audience")) {
            builder.setAudience(jwtParams["audience"] as String)
        }
        if (jwtParams.containsKey("connection")) {
            builder.setConnection(jwtParams["connection"] as String)
        }
        if (jwtParams.containsKey("additionalParams")) {
            builder.setAdditionalParams(jwtParams["additionalParams"] as HashMap<String, String>)
        }

        return builder.build()
    }
}
