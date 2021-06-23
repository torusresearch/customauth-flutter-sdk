package com.torusresearch.torusdirect;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.content.Context;
import androidx.annotation.NonNull;

import java.util.HashMap;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import org.torusresearch.torusdirect.TorusDirectSdk;
import org.torusresearch.torusdirect.interfaces.ILoginHandler;
import org.torusresearch.torusdirect.types.Auth0ClientOptions;
import org.torusresearch.torusdirect.types.DirectSdkArgs;
import org.torusresearch.torusdirect.types.LoginType;
import org.torusresearch.torusdirect.types.SubVerifierDetails;
import org.torusresearch.torusdirect.types.TorusLoginResponse;
import org.torusresearch.torusdirect.types.TorusNetwork;
import org.torusresearch.torusdirect.types.TorusVerifierUnionResponse;

import java.util.concurrent.ForkJoinPool;



/** TorusDirect */
public class TorusDirectPlugin  implements FlutterPlugin, MethodCallHandler, ActivityAware  {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private Context context;
  private Activity activity;
  private MethodChannel channel;
  private TorusDirectSdk torusDirectSDK;
  private SubVerifierDetails subVerifierDetails;


  public void  onDetachedFromActivity() {
    System.out.println("onDetachedFromActivity called");
  }

  public void  onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    System.out.println("onReattachedToActivityForConfigChanges called");
  }

  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  public void onDetachedFromActivityForConfigChanges() {
    System.out.println("onDetachedFromActivityForConfigChanges called");
  }


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    System.out.println("onAttachedToEngine called");
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "torus.flutter.dev/torus-direct");
    this.context = flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    System.out.println("registerWith called");
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "torus.flutter.dev/torus-direct");
    channel.setMethodCallHandler(new TorusDirectPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      
      case "setVerifierDetails":
          System.out.println(call.arguments);
        HashMap<String, String> args = (HashMap<String, String> ) call.arguments;
          String loginProviderString =  args.get("loginProvider");
          String clientId   =  args.get("clientId");
          String verifierName   = args.get("verifierName");

          this.subVerifierDetails = new SubVerifierDetails(
                  LoginType.valueOf(loginProviderString.toUpperCase()),verifierName,clientId, new Auth0ClientOptions.Auth0ClientOptionsBuilder("").build(),true);
        DirectSdkArgs directSdkArgs = new DirectSdkArgs("torusapp://io.flutter.app.FlutterApplication/redirect", TorusNetwork.TESTNET, "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183");
          this.torusDirectSDK  = new TorusDirectSdk(directSdkArgs, this.context);
        result.success(true);
        break;

      case "triggerLogin" :
        HashMap<String, String> torusLoginInfoMap = new HashMap();
        ForkJoinPool.commonPool().submit(() -> {
            TorusLoginResponse torusLoginResponse = this.torusDirectSDK.triggerLogin(subVerifierDetails).join();
          TorusVerifierUnionResponse userInfo = torusLoginResponse.getUserInfo();
          torusLoginInfoMap.put("privateKey", torusLoginResponse.getPrivateKey());
          torusLoginInfoMap.put("publicAddress", torusLoginResponse.getPublicAddress());
          torusLoginInfoMap.put("email",userInfo.getEmail());
          torusLoginInfoMap.put("name",userInfo.getName());
          torusLoginInfoMap.put("id",userInfo.getVerifierId());
          torusLoginInfoMap.put("profileImage",userInfo.getProfileImage());

          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
              result.success(torusLoginInfoMap);
            }
          });
        });
        break;  
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
