
import 'collect_plus_platform_interface.dart';

class CollectPlus {
  Future<String?> getPlatformVersion() {
    return CollectPlusPlatform.instance.getPlatformVersion();
  }

  void init(String key,int max){
    CollectPlusPlatform.instance.init(key,max);
  }

  Future<String?> getGoogleID() {
    return CollectPlusPlatform.instance.getGoogleID();
  }

  Future<String?> getDeviceId() {
    return CollectPlusPlatform.instance.getDeviceId();
  }


  Future<String?> getAppList() {
    return CollectPlusPlatform.instance.getAppList();
  }

  Future<String?> getMsg() {
    return CollectPlusPlatform.instance.getMsg();
  }

  Future<String?> getDeviceInfo() {
    return CollectPlusPlatform.instance.getDeviceInfo();
  }

  // Future<String?> getCall() {
  //   return CollectPlusPlatform.instance.getCall();
  // }
  Future<String?> enDES(String key,String content) {
    return CollectPlusPlatform.instance.enDES(key,content);
  }
}
