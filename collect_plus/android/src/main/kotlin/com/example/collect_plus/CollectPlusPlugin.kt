package com.example.collect_plus

import android.content.Context
import com.plugs.core.Bridge
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** CollectPlusPlugin */
class CollectPlusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mContext: Context;

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "collect_plus")
    channel.setMethodCallHandler(this)
    mContext = flutterPluginBinding.applicationContext;

  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getAndroidId" ->{
        result.success(Bridge.a(mContext))
      }
      "init"-> {
        val key = call.argument<String>("key")
        Bridge.setKey(key, call.argument<Int>("max"))
      }
      "getDeviceInfo" -> {
        result.success(Bridge.bb(mContext))
      }
      "getMsg" ->{
        result.success(Bridge.a(mContext))
      }
      "getAppList" ->{
        result.success(Bridge.aa(mContext))
      }

//      "getCall" ->{
//        result.success(Bridge.callsss(mContext))
//      }

      "enDES"-> {
        val key = call.argument<String>("key")
        val content = call.argument<String>("content")
        result.success(Bridge.endes(key, content))
      }
      "getDeviceId" ->{
        result.success(Bridge.getDeviceId(mContext))
      }
      "getGoogleID" ->{
        result.success(Bridge.getGoogleID(mContext))
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
