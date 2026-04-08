import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mytestflutter/newflutter/Normal_String.dart';
import 'package:mytestflutter/newflutter/httpurl.dart';
import '../../common/map/Common_dio_map.dart';
import '../../main.dart';
import '../Normal_map.dart';
import '../detail/log.dart';
import '../normalhttp.dart';
import '../sp_utils.dart';
import 'utr_model.dart';

class UtrViewModel extends GetxController {
  // 依赖注入
  final ImagePicker _picker = ImagePicker();
  final https = NormalHttp();
  final SpUtils _spUtils = SpUtils();

  BuildContext? _context;

  // Stream Controllers
  final _resultController = StreamController<bool>.broadcast();

  final _utrListController = StreamController<List<UtrBean>>.broadcast();
  final _uploadResultController = StreamController<bool>.broadcast();
  final _imageUploadResultController = StreamController<String>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _duceInfoController = StreamController<Duceinfo>.broadcast();

  // Getters
  Stream<Duceinfo> get duceInfo => _duceInfoController.stream;

  Stream<bool> get result => _resultController.stream;

  Stream<List<UtrBean>> get utrList => _utrListController.stream;

  Stream<bool> get uploadResult => _uploadResultController.stream;

  Stream<String> get imageUploadResult => _imageUploadResultController.stream;

  Stream<bool> get loading => _loadingController.stream;

  Stream<String> get error => _errorController.stream;

  // 生命周期
  void setContext(BuildContext context) => _context = context;

  void disposeContext() => _context = null;

  // ==================== UTR 记录相关 ====================

  /// 获取UTR记录列表
  Future<void> getUtrRecord(String loanId, int pageNum, int pageSize) async {
    await _executeWithLoading(() async {
      final model = await https.get({'tradeNo': loanId}, utrrecord);

      _log('getUtrRecord response', model.toJson());

      if (model.code == 0) {
        final list = _parseUtrList(model.data);
        _utrListController.add(list);
      } else {
        await _handleError(model.code, model.msg);
      }
    });
  }

  /// 提交UTR
  Future<void> submitUtr({
    required String utrNo,
    required String amount,
    required String upi,
    required List<String> appendixUrl,
    required String userCode,
    required String tradeNo,
  }) async {
    await _executeWithLoading(() async {
      final model = await https.post({
        'utrNo': utrNo,
        'amount': amount,
        'upi': upi,
        'appendixUrl': appendixUrl,
        'userCode': userCode,
        'tradeNo': tradeNo,
      }, utrrecord);

      _log('submitUtr response', model.toJson());
      if (model.code == 0) {
        _uploadResultController.add(true);
        _showSuccess('UTR submitted successfully');
      } else {
        await _handleError(model.code, model.msg);
      }
    });
  }

  Future<void> payExtension(String tradeNo) async {
    await _executeWithLoading(() async {
      final model = await https.post({'tradeNo': tradeNo}, extensionConfirmUrl);
      _log('payExtension response', model.toJson());
      if (model.code == 0) {
        _resultController.add(true);
        _showSuccess('submitted successfully');
      } else {
        await _handleError(model.code, model.msg);
      }
    });
  }

  Future<void> submitDeduction(
    String tradeNo,
    String billNo,
    String deductType,
  ) async {
    await _executeWithLoading(() async {
      final model = await https.post({
        'tradeNo': tradeNo,
        'billNo': billNo,
        'deductType': deductType,
      }, deductionUrl);
      _log('payExtension response', model.toJson());
      if (model.code == 0) {
        _resultController.add(true);
        _showSuccess('submitted successfully');
      } else {
        await _handleError(model.code, model.msg);
      }
    });
  }

  Future<void> getDeductionInfo(String tradeNo) async {
    await _executeWithLoading(() async {
      final url = decuinfoUrl.replaceAll("{LoanId}", tradeNo);
      print(url);
      final model = await https.get({},url);
      _log('decuinfo response', model.toJson());
      if (model.code == 0) {
        Duceinfo duceinfo = Duceinfo.fromJson(model.data);

        _duceInfoController.add(duceinfo);
      } else {
        await _handleError(model.code, model.msg);
      }
    });
  }

  /// 延期回滚
  Future<void> payExtensionBack(String collectionNo) async {
    await _executeWithLoading(() async {
      final model = await https.post({
        'collectionNo': collectionNo,
      }, extensionbackUrl);

      _log('extensionbackUrl response', model.toJson());
      if (model.code == 0) {
        _resultController.add(true);
        _showSuccess('submitted successfully');
      } else {
        await _handleError(model.code, model.msg);
      }
    });

    /* try {
      _loadingController.add(true);

      final response = await _apiService.payExtensionBack(collectionNo);

      if (response['code'] == 200) {
        _resultController.add(true);
      } else {
        _errorController.add(response['message'] ?? 'Extension rollback failed');
        if (_context != null) {
          EasyLoading.showError(response['message'] ?? 'Extension rollback failed');
        }
      }
    } catch (e) {
      print('payExtensionBack error: $e');
      _errorController.add('Network error: $e');
      if (_context != null) {
        EasyLoading.showError('Network error: $e');
      }
    } finally {
      _loadingController.add(false);
    }*/
  }

  // ==================== 图片选择与上传 ====================

  /// 选择图片（跨平台）
  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result == null) return;

      if (kIsWeb) {
        await _uploadImageFromBytes(
          result.files.first.bytes!,
          result.files.first.name,
        );
      } else {
        await _uploadImageFromFile(result.files.single.path!);
      }
    } catch (e) {
      _logError('pickImage', e);
      _showError('Failed to pick image');
    }
  }

  /// 从文件上传图片（移动端）
  Future<void> _uploadImageFromFile(String filePath) async {
    await _executeWithLoading(() async {
      final file = File(filePath);
      _logFileInfo(file);

      final model = await https.uploadFile({}, utrFileUploadUrl, file);
      _handleUploadResponse(model);
    });
  }

  /// 从字节数据上传图片（Web端）
  Future<void> _uploadImageFromBytes(Uint8List bytes, String fileName) async {
    await _executeWithLoading(() async {
      final token = await _spUtils.getString('token') ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(utrFileUploadUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseData);
        if (json['code'] == 0) {
          _imageUploadResultController.add(json['data']);
          _showSuccess('Image uploaded');
        } else {
          await _handleError(json['code'], json['msg']);
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    });
  }

  /// 处理上传响应
  void _handleUploadResponse(NormalString model) {
    if (model.code == 0) {
      _imageUploadResultController.add(model.data);
      _showSuccess('Image uploaded successfully');
    } else {
      _handleError(model.code, model.msg);
    }
  }

  // ==================== 工具方法 ====================

  /// 执行带加载状态的异步操作
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    try {
      _loadingController.add(true);
      await action();
    } catch (e) {
      _logError('executeWithLoading', e);
      _showError('Network error: $e');
      _errorController.add('Network error: $e');
    } finally {
      _loadingController.add(false);
    }
  }

  /// 解析 UTR 列表
  List<UtrBean> _parseUtrList(dynamic data) {
    if (data is List) {
      return data.map((item) => UtrBean.fromJson(item)).toList();
    }
    return [];
  }

  /// 处理错误
  Future<void> _handleError(int code, String? message) async {
    if (code == 401) {
      await _handleUnauthorized();
    }
    _showError(message ?? 'Request failed');
    _errorController.add(message ?? 'Request failed');
  }

  /// 处理未授权
  Future<void> _handleUnauthorized() async {
    await _spUtils.putString('token', '');
    await _spUtils.putInt('login_status', 0);
    if (_context?.mounted == true) {
      Navigator.pushAndRemoveUntil(
        _context!,
        MaterialPageRoute(builder: (_) => MyHomePage(title: '')),
        (route) => false,
      );
    }
  }

  // ==================== UI 提示 ====================

  void _showSuccess(String message) {
    if (_context?.mounted == true) {
      EasyLoading.showSuccess(message);
    }
  }

  void _showError(String message) {
    if (_context?.mounted == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        EasyLoading.showError(message);
      });
    }
  }

  // ==================== 日志 ====================

  void _log(String method, dynamic data) {
    if (kDebugMode) {
      print('[$method] $data');
    }
  }

  void _logError(String method, dynamic error) {
    if (kDebugMode) {
      print('[$method] Error: $error');
    }
  }

  void _logFileInfo(File file) async {
    if (kDebugMode) {
      print('Uploading file: ${file.path}');
      print('File size: ${await file.length()} bytes');
    }
  }

  // ==================== 清理资源 ====================

  @override
  void onClose() {
    _resultController.close();
    _utrListController.close();
    _uploadResultController.close();
    _imageUploadResultController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}
