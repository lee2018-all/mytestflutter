import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../Normal_map.dart';
import '../../httpurl.dart';
import '../../normalhttp.dart';
import '../../sp_utils.dart';
import 'contact_info_model.dart';

class ContactViewModel extends GetxController {
//  final ApiService _apiService = ApiService();
  BuildContext? _context;
  final https = NormalHttp();
  final SpUtils _spUtils = SpUtils();

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  // 清除上下文
  void disposeContext() {
    _context = null;
  }
  final _contactInfoController = StreamController<ContactInfoModel>.broadcast();
  final _contactInfoZiController = StreamController<ContactInfoModel>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ContactInfoModel> get contactInfo => _contactInfoController.stream;
  Stream<ContactInfoModel> get contactInfoZi => _contactInfoZiController.stream;
  Stream<bool> get loading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;

  /// 获取联系人列表
  Future<void> getContactsList(String tradeNo) async {
    try {
      _loadingController.add(true);

/*      final response = await _apiService.getContactsList(tradeNo);

      if (response['code'] == 200) {
        ContactInfoModel contactInfo = ContactInfoModel.fromJson(response['data']);
        _contactInfoController.add(contactInfo);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load contacts');
      }*/

      NormalMap model = await https.post({

        'tradeNo': tradeNo,

      }, emergencyContactsUrl);

      var s = model.toJson();
      debugPrint('contactInfo: $s');
      if (model.code == 0) {
        ContactInfoModel contactInfo = ContactInfoModel.fromJson(model.data);
        _contactInfoController.add(contactInfo);

        // LogUtil.json('API Response', model.data);
      } else {
        if(model.code == 401){
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status',0);
          if (_context != null && _context!.mounted) {
            /*   Navigator.of(_context!).pushNamedAndRemoveUntil(
             '/login',
                 (route) => false,
           );*/
            Navigator.pushAndRemoveUntil(
              _context!,
              MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
                  (route) => false,
            );
          }
          //  Get.offAllNamed('/login');
        }

        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      _errorController.add('Network error: $e');
    } finally {
      _loadingController.add(false);
    }
  }

  /// 获取子联系人列表
  Future<void> getContactsListZi(String tradeNo) async {
    try {
      _loadingController.add(true);

 /*     final response = await _apiService.getContactsListZi(tradeNo);

      if (response['code'] == 200) {
        ContactInfoModel contactInfo = ContactInfoModel.fromJson(response['data']);
        _contactInfoZiController.add(contactInfo);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load sub contacts');
      }*/
      NormalMap model = await https.post({

        'tradeNo': tradeNo,

      }, addressbookContactsUrl);

      var s = model.toJson();
      debugPrint('contactInfo: $s');
      if (model.code == 0) {
        ContactInfoModel contactInfo = ContactInfoModel.fromJson(model.data);
        _contactInfoZiController.add(contactInfo);

        // LogUtil.json('API Response', model.data);
      } else {
        if(model.code == 401){
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status',0);
          if (_context != null && _context!.mounted) {
            /*   Navigator.of(_context!).pushNamedAndRemoveUntil(
             '/login',
                 (route) => false,
           );*/
            Navigator.pushAndRemoveUntil(
              _context!,
              MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
                  (route) => false,
            );
          }
          //  Get.offAllNamed('/login');
        }

        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      _errorController.add('Network error: $e');
    } finally {
      _loadingController.add(false);
    }
  }

  @override
  void onClose() {
    _contactInfoController.close();
    _contactInfoZiController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}