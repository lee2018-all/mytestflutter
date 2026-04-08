import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mytestflutter/newflutter/RSAUtil.dart';
import 'package:mytestflutter/newflutter/sp_utils.dart';


import 'Normal_map.dart';
import 'base_page.dart';
import 'httpurl.dart';
import 'normalhttp.dart';


class LoginViewModel extends BaseViewModel {
  final RxBool _booleanMutableLiveData = false.obs;
  RxBool get booleanMutableLiveData => _booleanMutableLiveData;
  final http = NormalHttp();

  void login(String phone, String pwd, double latitude, double longitude, bool isFromMockProvider) {
    // TODO: Implement actual login logic
    // Simulate login result
    codeBtnAction(phone, pwd);
   // codeBtnAction2(phone, pwd);
  }
  final SpUtils _spUtils = SpUtils();

  get imageUrl => null;

  void codeBtnAction2(String phone, String pwd) async {


    EasyLoading.show();
  //  phone="15673170001";
//    pwd="Yz^-y3l3Rn";
    phone="admini";
    pwd="GP#jBDaA39!s6iG@Dx";
    try {
      NormalMap model = await http.post({
        'username': RSAUtil.encryptSafe(phone, ANDROID_KEY_STORE),
        'password': RSAUtil.encryptSafe(pwd, ANDROID_KEY_STORE),
        'latitude': '0',
        'longitude': '0',
        'isFromMockProvider': '0',
        'language': 'en',
      }, login1Url);
      var pho= RSAUtil.encryptSafe(phone, ANDROID_KEY_STORE);
      var pwds= RSAUtil.encryptSafe(pwd, ANDROID_KEY_STORE);
      print('Login attempt: $pho, pwd: $pwds');
      var phosss= RSAUtil.decryptSafe(pho, PRIVATE);
      var pwdsss= RSAUtil.decryptSafe(pwds, PRIVATE);
      print('Login attempt: $phosss, pwd: $pwdsss');
      var s=  model.toJson();
      debugPrint('Login model: $s');
      //  debugPrint('Login model: '+model.data['token'].toString());

      EasyLoading.dismiss();
      if (model.code == 200) {


        EasyLoading.showSuccess("Code sent successfully");

      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Login error: $e');

      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }


  void codeBtnAction(String phone, String pwd) async {
    EasyLoading.show();
 //   phone="15673170001";
  //  pwd="Yz^-y3l3Rn";
    phone="admin";
    pwd="GP#jBDaA39!s6iG@Dx";
    try {
      Map<String, dynamic> json = await http.postother({
        'username': RSAUtil.encryptSafe(phone, ANDROID_KEY_STORE),
        'password': RSAUtil.encryptSafe(pwd, ANDROID_KEY_STORE),
        'latitude': '0',
        'longitude': '0',
        'isFromMockProvider': '0',
        'language': 'en',
      }, login1Url);
     var pho= RSAUtil.encryptSafe(phone, ANDROID_KEY_STORE);
     var pwds= RSAUtil.encryptSafe(pwd, ANDROID_KEY_STORE);
      debugPrint('Login attempt: $pho, pwd: $pwds');
      var phosss= RSAUtil.decryptSafe(pho, PRIVATE);
      var pwdsss= RSAUtil.decryptSafe(pwds, PRIVATE);
      debugPrint('Login attempt: $phosss, pwd: $pwdsss');
      var s=  json.toString();
      debugPrint('Login model: $s');

      EasyLoading.dismiss();
      if (json['code'] == 200) {

        await _spUtils.putString('token', json['token'].toString());
        await _spUtils.putString('username', json['username'].toString());
        await _spUtils.putString('leaderName', json['leaderName'].toString());

        var username = await _spUtils.getString("username");
        print(username+'sss');
        EasyLoading.showSuccess("Code sent successfully");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _booleanMutableLiveData.value = true;
        });
      } else {
        EasyLoading.showError(json['msg']);
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Login error: $e');

      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }

  void verilogin(String veri) async {

    EasyLoading.show();

    try {
      Map<String, dynamic> json = await http.postother({

        'verifyCode': veri,
      }, veriloginUrl);

      var s=  json.toString();
      debugPrint('Login model: $s');
    //  debugPrint('Login model: '+model.data['token'].toString());

      EasyLoading.dismiss();
      if (json['code'] == 200) {

        await _spUtils.putString('token', json['token'].toString());
        await _spUtils.putString('userID', json['userID'].toString());

        EasyLoading.showSuccess("Code sent successfully");
        _booleanMutableLiveData.value = true;

      } else {
        EasyLoading.showError(json['msg']);
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Login error: $e');

      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }

}