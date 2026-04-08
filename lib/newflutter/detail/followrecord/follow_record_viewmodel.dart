import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../main.dart';
import '../../Normal_map.dart';
import '../../httpurl.dart';
import '../../normalhttp.dart';
import '../../sp_utils.dart';
import 'follow_record_model.dart';

class FollowRecordViewModel extends GetxController {

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




  final _followListController = StreamController<FollowRecordModel>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<FollowRecordModel> get followList => _followListController.stream;
  Stream<bool> get loading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;



  /// 获取跟进记录列表
  Future<void> getFollowList(String tradeNo, int pageNum, int pageSize) async {
    try {
      _loadingController.add(true);

 /*     final response = await _apiService.getFollowList(tradeNo, pageNum, pageSize);

      if (response['code'] == 200) {
        FollowRecordModel data = FollowRecordModel.fromJson(response['data']);
        _followListController.add(data);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load follow records');
        if (_context != null) {
          EasyLoading.showError(response['message'] ?? 'Failed to load follow records');
        }
      }*/
      NormalMap model = await https.post({

        'tradeNo': tradeNo,
        'currentPage': pageNum,
     //   'pageSize': pageSize,

      }, followlist);

      var s = model.toJson();
      debugPrint('follow: $s');
      if (model.code == 0) {
        FollowRecordModel data = FollowRecordModel.fromJson(model.data);
      _followListController.add(data);

        // LogUtil.json('API Response', model.data);
      } else {
        if(model.code == 401){
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status',0);
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
      if (_context != null) {
        EasyLoading.showError('Network error: $e');
      }
    } finally {
      _loadingController.add(false);
    }
  }

  @override
  void onClose() {
    _followListController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}