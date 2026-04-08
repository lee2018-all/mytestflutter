import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mytestflutter/newflutter/color/LogUtil.dart';

import '../../main.dart';
import '../Normal_String.dart';
import '../Normal_map.dart';
import '../httpurl.dart';
import '../normalhttp.dart';
import '../sp_utils.dart';
import 'config_model.dart';
import 'item_model.dart';

class ColorViewModel extends GetxController {

  BuildContext? _context;

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  // 清除上下文
  void disposeContext() {
    _context = null;
  }




  // Observables
  final _pageData = Rx<PageBean?>(null);
  final _totalCount = 0.obs;
  final _configData = Rx<ConfigModel?>(null);
  final _loading = false.obs;
  final _error = ''.obs;
  final _applinkdata = ''.obs;
  final _repaylinkdata = ''.obs;
  final https = NormalHttp();

  // Getters
  Rx<PageBean?> get pageData => _pageData;

  Rx<int> get totalCount => _totalCount;

  Rx<ConfigModel?> get configData => _configData;

  Rx<bool> get loading => _loading;

  Rx<String> get error => _error;
  Rx<String> get appLinkData => _applinkdata;
  Rx<String> get repayLinkData => _repaylinkdata;

  final SpUtils _spUtils = SpUtils();

  Future<void> getConfig() async {
    try {
      _loading.value = true;
      String token = await _spUtils.getString('token');

      final response = await http.post(
        Uri.parse('your_api_url/config'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _configData.value = ConfigModel.fromJson(data);
      } else {
        _error.value = 'Failed to load config';
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _loading.value = false;
    }
  }

  Future<void> getList({
    required int pageNum,
    required int isNewAdd,
    required String overdueTime,
    required String workTaskStatus,
    required String tradeNo,
    required String mobile,
    required String sortType,
    required int sort,
    required String collectionStatus,
    required List<String> selectedColors,
    required bool isChooseColor,
  }) async {
    try {
      _loading.value = true;
      /*  String token = await _spUtils.getString('token');

      final response = await http.post(
        Uri.parse('your_api_url/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'pageNum': pageNum,
          'isNewAdd': isNewAdd,
          'overdueTime': overdueTime,
          'workTaskStatus': workTaskStatus,
          'tradeNo': tradeNo,
          'mobile': mobile,
          'sortType': sortType,
          'sort': sort,
          'collectionStatus': collectionStatus,
          'selectedColors': selectedColors,
          'isChooseColor': isChooseColor,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _pageData.value = PageBean.fromJson(data);
        _totalCount.value = data['totalCount'] ?? 0;
      } else {
        _error.value = 'Failed to load list';
      }*/

      NormalMap model = await https.post({
        'pageNum': pageNum,
        'isNewAdd': isNewAdd,
        'overdueTime': overdueTime,
        'workTaskStatus': workTaskStatus,
        'tradeNo': tradeNo,
        'mobile': mobile,
        'sortType': sortType,
        'sort': sort,
        'collectionStatus': collectionStatus,
        'collectionNoList': selectedColors,
        'isChooseColor': isChooseColor,
        'pageSize': 30,
      }, collectOrderUrl);
      print("selectedColors: $selectedColors");
      var s = model.toJson();
   //   LogUtil.json('API Response', model);
      debugPrint('Login model: $s');
     if (model.code == 0) {
       PageBean pageBean = PageBean.fromJson(model.data);

       LogUtil.json('API Response', model.data);

       _pageData.value = PageBean.fromJson(model.data);

      //  EasyLoading.showSuccess("Code sent successfully");
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
      _error.value = e.toString();
    } finally {
      _loading.value = false;
    }
  }

  Future<void> getAppLink(String tradeNo) async {
    try {
      NormalString model = await https.getWithQueryParams( appLinkUrl+tradeNo,{});

      var s = model.toJson();
      debugPrint('OcrUrlInfo: $s');
      if (model.code == 0) {
        String link = model.data ?? '';

        _applinkdata.value=link;

      /*  _linkDataController.add({
          'url': link,
          'isCopy': isCopy,
        });*/
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
      _error.value = e.toString();
    }
  }

  Future<void> getRepaymentLink(String collectionNo) async {
    try {
  /*    String token = await _spUtils.getString('token');
      final response = await http.post(
        Uri.parse('your_api_url/repaymentlink'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'collectionNo': collectionNo}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle repayment link
      }*/
      NormalString model = await https.getWithQueryParams( repaymentLinkUrl+collectionNo,{});

      var s = model.toJson();
      debugPrint('OcrUrlInfo: $s');
      if (model.code == 0) {
        String link = model.data ?? '';
        _repaylinkdata.value=link;
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
      _error.value = e.toString();
    }
  }

  Future<void> issueCoupon(String tradeNo) async {
    try {
      String token = await _spUtils.getString('token');
      final response = await http.post(
        Uri.parse('your_api_url/coupon'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'tradeNo': tradeNo}),
      );

      if (response.statusCode == 200) {
        // Handle success
      }
    } catch (e) {
      _error.value = e.toString();
    }
  }
}
