import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mytestflutter/newflutter/httpurl.dart';

import '../../main.dart';
import '../Normal_map.dart';
import '../normalhttp.dart';
import '../sp_utils.dart';
import 'rute_bean.dart';


class CctViewModel extends GetxController {
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
  final _ruteController = StreamController<List<RuteBean>>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final https = NormalHttp();

  // Getters for streams
  Stream<List<RuteBean>> get rute => _ruteController.stream;
  Stream<bool> get loading => _loadingController.stream;
  Stream<String> get error => _errorController.stream;

  // 获取路由数据
  Future<void> getrute() async {
    try {
      _loadingController.add(true);

      NormalMap model = await https.get({}, ruteUrl);

      var s = model.toJson();
      debugPrint('Rute model: $s');
      if (model.code == 200) {
        List<RuteBean> ruteList = [];
        if (model.data is List) {
          for (var item in model.data) {
            ruteList.add(RuteBean.fromJson(item));
          }
        }
        _ruteController.add(ruteList);
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
    _ruteController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}
