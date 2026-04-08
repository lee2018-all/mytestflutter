import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Normal_String.dart';
import 'Normal_map.dart';
import 'httpurl.dart';


class NormalHttp {
  final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 12),
      sendTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(seconds: 30)
  ));

  Future<dynamic> get(Map<String, dynamic> para, String url) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.get(
          url,
          options: options,
          queryParameters: para
      );
      String jsonString = jsonEncode(response.data);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return NormalMap.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> getWithQueryParams(String url, Map<String, dynamic>? queryParams) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.get(
        url,
        options: options,
        queryParameters: queryParams,
      );

      // 打印请求信息用于调试
      print('GET Request - URL: $url');
      print('GET Request - QueryParams: $queryParams');
      print('GET Request - Headers: $header');
      print('GET Response - Status: ${response.statusCode}');
      print('GET Response - Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map) {
          return NormalString.fromJson(response.data);
        } else if (response.data is String) {
          Map<String, dynamic> json = jsonDecode(response.data);
          return NormalString.fromJson(json);
        }
        return NormalMap.fromJson(response.data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      print('GET Request Error: $e');
      throw Exception(e);
    }
  }


  Future<dynamic> getHtml(Map<String, dynamic> para, String url) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.get(
          url,
          options: options,
          queryParameters: para
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }


  Future<dynamic> uploadFile(Map<String, dynamic> para, String url,File file) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      Response response = await dio.post(
          url,
          data: formData,
          options: options,
          queryParameters: para
      );
      print('uploadImage: ${response.data}');

      String jsonString = jsonEncode(response.data);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return NormalString.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> uploadFilenew(Map<String, dynamic> para, String url,File file) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      Response response = await dio.post(
          url,
          data: formData,
          options: options,
          queryParameters: para
      );
      print('uploadImage: ${response.data}');

      String jsonString = jsonEncode(response.data);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return NormalString.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> uploadJsonData(Map<String, dynamic> para, String url,String json) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    DateTime currentTime = DateTime.now();
    MultipartFile file = MultipartFile.fromString(json, filename: currentTime.millisecondsSinceEpoch.toString() + '.text');
    FormData formData = FormData.fromMap({
      'file': file,
    });

    try {
      Response response = await dio.post(
          url,
          data: formData,
          options: options,
          queryParameters: para
      );
      String jsonString = jsonEncode(response.data);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return NormalMap.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> post(Map<String, dynamic> para, String url) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.post(
          url,
          options: options,
          data: para
      );
      String jsonString = jsonEncode(response.data);
      print(jsonString);
      Map<String, dynamic> json = jsonDecode(jsonString);

      debugPrint('Login model: $json');

      if (response.statusCode == 200) {
        return NormalMap.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<dynamic> postother(Map<String, dynamic> para, String url) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.post(
          url,
          options: options,
          data: para
      );
      String jsonString = jsonEncode(response.data);
      print(jsonString);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return  json;
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<dynamic> postother2(Map<String, dynamic> para, String url) async {
    Map<String, dynamic> header = await _getHeader();
    var options = Options(
      headers: header,
    );
    try {
      Response response = await dio.post(
          url,
          options: options,
          data: para
      );
      String jsonString = jsonEncode(response.data);
      print(jsonString);
      NormalString normalString = NormalString.fromJson(response.data);
      if (response.statusCode == 200) {
        return  normalString;
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }



  Future<Map<String, dynamic>> _getHeader() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')??'';

    String phone = prefs.getString('mobile')??'';
    phone = phone.replaceFirst('00910', '');
    String deviceInof;
    if (kIsWeb) {
      // 运行在 Web 平台上的代码
      deviceInof="web";
    } else {
      const MethodChannel _channel = MethodChannel('AndroidId');
      deviceInof = await _channel.invokeMethod('getAndroidId');
    }
    if (token.length != 0) {
      return {
        'deviceno': deviceInof,
        'charset':'utf-8',
        'content-type': 'application/json',
        'riskManagementApp': '1',
        'packageName':app_id,
        'versionCode':app_versionCode,
        'clVersionCode':app_versionCode,

        'Authorization':token,

      };
    }
    return {
    'deviceno': deviceInof,
    'charset':'utf-8',
    'content-type': 'application/json',
    'riskManagementApp': '1',
    'packageName':app_id,
    'versionCode':app_versionCode,
    'clVersionCode':app_versionCode,

    };

  }

}
