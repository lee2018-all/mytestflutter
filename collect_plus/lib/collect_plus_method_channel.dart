import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'collect_plus_platform_interface.dart';

/// An implementation of [CollectPlusPlatform] that uses method channels.
class MethodChannelCollectPlus extends CollectPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('collect_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  void init(String key,int max){
    methodChannel.invokeMethod('init', {"key":key,"max":max});
  }


  Future<String?> getMsg() async{
    final dMsg = await methodChannel.invokeMethod('getMsg');
    return dMsg;
}

  // Future<String?> getCall() async {
  //   final dAppList = await methodChannel.invokeMethod('getCall');
  //   return dAppList;
  // }

  Future<String?> getAppList() async {
    final dAppList = await methodChannel.invokeMethod('getAppList');
    return dAppList;
  }

  Future<String?> getDeviceId() async {
    final dDeviceId = await methodChannel.invokeMethod('getDeviceId');
    return dDeviceId;
  }

  Future<String?> getDeviceInfo() async {
    final ddeviceInfo = await methodChannel.invokeMethod('getDeviceInfo');
    return ddeviceInfo!;
  }

  Future<String?> getGoogleID() async{
    final dADID = await methodChannel.invokeMethod('getGoogleID');
    return dADID;
  }

  Future<String?> enDES(String key,String content) async{
    final dADID = await methodChannel.invokeMethod('enDES', {"key":key,"content":content});
    return dADID;
  }
}
