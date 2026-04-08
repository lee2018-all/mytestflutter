import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'collect_plus_method_channel.dart';

abstract class CollectPlusPlatform extends PlatformInterface {
  /// Constructs a CollectPlusPlatform.
  CollectPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static CollectPlusPlatform _instance = MethodChannelCollectPlus();

  /// The default instance of [CollectPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelCollectPlus].
  static CollectPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CollectPlusPlatform] when
  /// they register themselves.
  static set instance(CollectPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  void init(String key,int max){
    throw UnimplementedError('init() has not been implemented.');
  }

  // Future<String?> getCall(){
  //   throw UnimplementedError('getCall() has not been implemented.');
  // }
  Future<String?> getDeviceInfo(){
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }
  Future<String?> getMsg(){
    throw UnimplementedError('getMsg() has not been implemented.');
  }
  Future<String?> getAppList(){
    throw UnimplementedError('getAppList() has not been implemented.');
  }
  Future<String?> getDeviceId(){
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  Future<String?> getGoogleID() {
    throw UnimplementedError('getGoogleID() has not been implemented.');
  }

  Future<String?> enDES(String key,String content) {
    throw UnimplementedError('enDES() has not been implemented.');
  }
}
