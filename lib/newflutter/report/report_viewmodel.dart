import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mytestflutter/newflutter/httpurl.dart';

import '../../main.dart';
import '../Normal_String.dart';
import '../normalhttp.dart';
import '../sp_utils.dart';
import 'api_response.dart';

class ReportViewModel extends GetxController {
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
  final _resController = StreamController<ApiResponse>.broadcast();
  final _stringController = StreamController<String>.broadcast();
  final _ocrUrlInfoController = StreamController<List<dynamic>>.broadcast();
  final _refreshController = StreamController<bool>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final https = NormalHttp();

  // Getters for streams
  Stream<ApiResponse> get res => _resController.stream;
  Stream<String> get stringMutableLiveData => _stringController.stream;
  Stream<List<dynamic>> get ocrUrlInfo => _ocrUrlInfoController.stream;
  Stream<bool> get refreshStream => _refreshController.stream;
  Stream<bool> get loading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;

  // 查询Python数据
  Future<void> queryPythonv2(Map<String, dynamic> mapdata, int pageNum) async {
    try {
      _loadingController.add(true);

      NormalString model = await https.postother2(mapdata, pythonUrl);

      var s = model.toJson();
      debugPrint('Report model: $s');
      if (model.code == 0) {
        _stringController.add(model.data.toString());
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
    _resController.close();
    _stringController.close();
    _ocrUrlInfoController.close();
    _refreshController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}
