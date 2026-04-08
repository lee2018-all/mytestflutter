import 'dart:async';
import 'dart:convert' as LogUtil;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mytestflutter/newflutter/httpurl.dart';

import '../../../main.dart';
import '../../Normal_String.dart';
import '../../Normal_map.dart';
import '../../normalhttp.dart';
import '../../sp_utils.dart';
import 'BaseInfoModel.dart';


class HomeViewModel extends GetxController {
  // Services
  final SpUtils _spUtils = SpUtils();
  BuildContext? _context;

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  // 清除上下文
  void disposeContext() {
    _context = null;
  }

  // Controllers for data streams
  final _baseInfoController = StreamController<BaseInfoModel>.broadcast();
  final _userUrlInfoController = StreamController<UserUrlInfoModel>.broadcast();
  final _ocrUrlInfoController = StreamController<OcrUrlInfoModel>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _linkDataController = StreamController<Map<String, dynamic>>.broadcast();
  final https = NormalHttp();

  // Getters for streams
  Stream<BaseInfoModel> get baseInfo => _baseInfoController.stream;
  Stream<UserUrlInfoModel> get userUrlInfo => _userUrlInfoController.stream;
  Stream<OcrUrlInfoModel> get ocrUrlInfo => _ocrUrlInfoController.stream;
  Stream<bool> get loading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;
  Stream<Map<String, dynamic>> get linkData => _linkDataController.stream;

  // 获取基本信息
  Future<void> getBaseInfo(String loanId) async {
    try {
   /*   _loadingController.add(true);

      final response = await _apiService.getBaseInfo(loanId);

      if (response['code'] == 200) {
        BaseInfoModel baseInfo = BaseInfoModel.fromJson(response['data']);
        _baseInfoController.add(baseInfo);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load base info');
      }*/
      NormalMap model = await https.post({

        'tradeNo': loanId,

      }, userBaseInfoUrl);

      var s = model.toJson();
      debugPrint('Login model: $s');
      if (model.code == 0) {
        BaseInfoModel baseInfo = BaseInfoModel.fromJson(model.data);
        _baseInfoController.add(baseInfo);
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

  // 获取用户URL信息
  Future<void> getUserUrlInfo(String userCode) async {
    try {
   /*   final response = await _apiService.getUserUrlInfo(userCode);

      if (response['code'] == 200) {
        UserUrlInfoModel userUrlInfo = UserUrlInfoModel.fromJson(response['data']);
        _userUrlInfoController.add(userUrlInfo);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load user URL info');
      }*/
      NormalMap model = await https.post({

        'userCode': userCode,

      }, userUrlInfoUrl);

      var s = model.toJson();
      debugPrint('userUrlInfo: $s');
      if (model.code == 0) {
        UserUrlInfoModel userUrlInfo = UserUrlInfoModel.fromJson(model.data);
        _userUrlInfoController.add(userUrlInfo);
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
    }
  }

  // 获取OCR URL信息
  Future<void> getOcrUrlInfo(String userCode) async {
    try {
   /*   final response = await _apiService.getOcrUrlInfo(userCode);

      if (response['code'] == 200) {
        OcrUrlInfoModel ocrUrlInfo = OcrUrlInfoModel.fromJson(response['data']);
        _ocrUrlInfoController.add(ocrUrlInfo);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load OCR URL info');
      }*/

      NormalMap model = await https.post({

        'userCode': userCode,

      }, ocrurl);

      var s = model.toJson();
      debugPrint('OcrUrlInfo: $s');
      if (model.code == 0) {
        OcrUrlInfoModel ocrUrlInfo = OcrUrlInfoModel.fromJson(model.data);
        _ocrUrlInfoController.add(ocrUrlInfo);
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
    }
  }

  // 获取App链接
  Future<void> getAppLink(String tradeNo, bool isCopy) async {
    try {
      _loadingController.add(true);

  /*    final response = await _apiService.getAppLink(tradeNo);

      if (response['code'] == 200) {
        String link = response['data']['link'] ?? '';
        _linkDataController.add({
          'url': link,
          'isCopy': isCopy,
        });
      } else {
        _errorController.add(response['message'] ?? 'Failed to get app link');
      }*/

      NormalString model = await https.getWithQueryParams( appLinkUrl+tradeNo,{});

      var s = model.toJson();
      debugPrint('OcrUrlInfo: $s');
      if (model.code == 0) {
        String link = model.data ?? '';
        _linkDataController.add({
          'url': link,
          'isCopy': isCopy,
        });
      } else {
        if (model.code == 401) {
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status', 0);
          if (_context != null && _context!.mounted) {
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

  // 获取还款链接
  Future<void> getRepaymentLink(String collectionNo, bool isCopy) async {
    try {
      _loadingController.add(true);

  /*    final response = await _apiService.getRepaymentLink(collectionNo);

      if (response['code'] == 200) {
        String link = response['data']['link'] ?? '';
        _linkDataController.add({
          'url': link,
          'isCopy': isCopy,
        });
      } else {
        _errorController.add(response['message'] ?? 'Failed to get repayment link');
      }*/
      NormalString model = await https.getWithQueryParams( repaymentLinkUrl+collectionNo,{});

      var s = model.toJson();
      debugPrint('OcrUrlInfo: $s');
      if (model.code == 0) {
        String link = model.data ?? '';
        _linkDataController.add({
          'url': link,
          'isCopy': isCopy,
        });
      } else {
        if (model.code == 401) {
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status', 0);
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
    _baseInfoController.close();
    _userUrlInfoController.close();
    _ocrUrlInfoController.close();
    _loadingController.close();
    _errorController.close();
    _linkDataController.close();
    super.onClose();
  }
}