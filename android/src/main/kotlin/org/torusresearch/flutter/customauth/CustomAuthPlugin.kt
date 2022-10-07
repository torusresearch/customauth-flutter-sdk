package org.torusresearch.flutter.customauth

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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.torusresearch.customauth.CustomAuth
import org.torusresearch.customauth.types.*
import org.torusresearch.customauth.utils.Helpers.unwrapCompletionException
import org.torusresearch.fetchnodedetails.types.TorusNetwork
import org.torusresearch.torusutils.helpers.Utils
import java.util.*
import kotlin.collections.HashMap

/** TorusDirectPlugin */
class CustomAuthPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var activity: Activity? = null
    private lateinit var context: Context
    private lateinit var torusDirectArgs: CustomAuthArgs

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "customauth")
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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                val response = runMethodCall(call)
                launch(Dispatchers.Main) { result.success(response) }
            } catch (e: NotImplementedError) {
                launch(Dispatchers.Main) { result.notImplemented() }
            } catch (e: Throwable) {
                launch(Dispatchers.Main) {
                    val unwrappedError = unwrapCompletionException(e)
                    unwrappedError::class.simpleName?.let { result.error(it, unwrappedError.message, null) }
                }
            }
        }
    }

    private fun runMethodCall(@NonNull call: MethodCall): Any? {
        when (call.method) {
            "init" -> {
                torusDirectArgs = CustomAuthArgs(
                        call.argument("browserRedirectUri"),
                    (call.argument("network") as String?)?.uppercase(Locale.ROOT)?.let { TorusNetwork.valueOf(it) },
                        call.argument("redirectUri")
                )
                val enableOneKey = call.argument<Boolean>("enableOneKey")
                if (enableOneKey != null) {
                    torusDirectArgs.isEnableOneKey = enableOneKey
                }
                val networkUrl = call.argument<String>("networkUrl")
                if (networkUrl != null) {
                    torusDirectArgs.networkUrl = networkUrl
                }
                Log.d(
                        "${CustomAuthPlugin::class.qualifiedName}#init",
                        "network=${torusDirectArgs.network}, redirectUri=${torusDirectArgs.redirectUri}, networkUrl=${torusDirectArgs.networkUrl}"
                )
                return null
            }
            "triggerLogin" -> {
                val torusDirectSdk =
                        CustomAuth(torusDirectArgs, activity ?: context)
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
                        "${CustomAuthPlugin::class.qualifiedName}#triggerLogin",
                        "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                        "publicAddress" to torusResponse.publicAddress,
                        "privateKey" to Utils.padLeft(torusResponse.privateKey.toString(16), '0', 64),
                        "userInfo" to listOf(mapOf(
                                "email" to torusResponse.userInfo.email,
                                "name" to torusResponse.userInfo.name,
                                "profileImage" to torusResponse.userInfo.profileImage,
                                "verifier" to torusResponse.userInfo.verifier,
                                "verifierId" to torusResponse.userInfo.verifierId,
                                "typeOfLogin" to torusResponse.userInfo.typeOfLogin.name,
                                "accessToken" to torusResponse.userInfo.accessToken,
                                "idToken" to torusResponse.userInfo.idToken
                        ))
                )
            }
            "triggerAggregateLogin" -> {
                val torusDirectSdk =
                        CustomAuth(torusDirectArgs, activity ?: context)
                val torusResponse = torusDirectSdk.triggerAggregateLogin(
                        AggregateLoginParams(
                                AggregateVerifierType.valueOfLabel(call.argument<String>("aggregateVerifierType")),
                                call.argument<String>("verifierIdentifier"),
                                (call.argument<List<Map<String, Any>?>>("subVerifierDetailsArray")!!
                                        .map { mapSubVerifierDetails(it) }).toTypedArray()
                        )
                ).join()
                Log.d(
                        "${CustomAuthPlugin::class.qualifiedName}#triggerAggregateLogin",
                        "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                        "publicAddress" to torusResponse.publicAddress,
                        "privateKey" to Utils.padLeft(torusResponse.privateKey.toString(16), '0', 64),
                        "userInfo" to torusResponse.userInfo.map {
                            mapOf(
                                "email" to it.email,
                                "name" to it.name,
                                "profileImage" to it.profileImage,
                                "verifier" to it.verifier,
                                "verifierId" to it.verifierId,
                                "typeOfLogin" to it.typeOfLogin.name,
                                "accessToken" to it.accessToken,
                                "idToken" to it.idToken
                            )
                        }

                )
            }

            "getTorusKey" -> {
                val torusDirectSdk =
                        CustomAuth(torusDirectArgs, activity ?: context)
                val torusResponse = torusDirectSdk.getTorusKey(
                        call.argument("verifier"),
                        call.argument("verifierId"),
                        call.argument("verifierParams"),
                        call.argument("idToken")
                ).join()
                Log.d(
                        "${CustomAuthPlugin::class.qualifiedName}#getTorusKey",
                        "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                        "publicAddress" to torusResponse.publicAddress,
                        "privateKey" to Utils.padLeft(torusResponse.privateKey.toString(16), '0', 64),
                )
            }

            "getAggregateTorusKey" -> {
                val torusDirectSdk =
                        CustomAuth(torusDirectArgs, activity ?: context)
                val torusResponse = torusDirectSdk.getAggregateTorusKey(
                        call.argument("verifier"),
                        call.argument("verifierId"),
                        (call.argument<List<Map<String, Any>?>>("subVerifierInfoArray")!!
                                .map { mapTorusSubVerifierInfo(it) }).toTypedArray()
                ).join()
                Log.d(
                        "${CustomAuthPlugin::class.qualifiedName}#getAggregateTorusKey",
                        "publicAddress=${torusResponse.publicAddress}"
                )
                return mapOf(
                        "publicAddress" to torusResponse.publicAddress,
                        "privateKey" to Utils.padLeft(torusResponse.privateKey.toString(16), '0', 64),
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

    private fun mapSubVerifierDetails(m: Map<String, Any>?): SubVerifierDetails? {
        if (m == null) {
            return null
        }

        return SubVerifierDetails(
                LoginType.valueOfLabel(m["typeOfLogin"] as String),
                m["verifier"] as String,
                m["clientId"] as String,
                @Suppress("UNCHECKED_CAST")
                mapJwtParams(m["jwtParams"] as Map<String, Any>?),
                activity == null
        )
    }

    private fun mapTorusSubVerifierInfo(m: Map<String, Any>?): TorusSubVerifierInfo? {
        if (m == null) {
            return null
        }

        return TorusSubVerifierInfo(
                m["verifier"] as String,
                m["idToken"] as String
        )
    }
}
