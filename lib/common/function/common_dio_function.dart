import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mytestflutter/common/map/Common_dio_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../map/common_map.dart';

class CommonDioFunction {
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
        return PublicDioMap.fromJson(json);
      } else {
        throw Exception(response.data);
      }
    } catch (e) {
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
      String jsonString = jsonEncode(response.data);
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return PublicDioMap.fromJson(json);
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
        return PublicDioMap.fromJson(json);
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

      Map<String, dynamic> json = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        return PublicDioMap.fromJson(json);
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
        'pqrPrergJkbloIbve': deviceInof,
        'charset':'utf-8',
        'content-type': 'application/json',
        'homPvqxkLeyiTqpwx': '1',
        'ifuzlBxchLprYxg':app_appCode,
        'qfiYbtPdjSdgik':app_id,
        'cjtTceiSazYze':app_versionCode,
        'flgfHwwLex':prefs.get('adid')??'',
        'fqvHbsdlIhbsDvz':prefs.get('googleAdId')??'',
        'deljtRxwKletiQtral':token,

        'ldcvjDpbrpBzk':phone,
      };
    }
    return {
      'pqrPrergJkbloIbve': deviceInof,
      'charset':'utf-8',
      'content-type': 'application/json',
      'homPvqxkLeyiTqpwx': '1',
      'ifuzlBxchLprYxg':app_appCode,
      'qfiYbtPdjSdgik':app_id,
      'cjtTceiSazYze':app_versionCode,
      'fqvHbsdlIhbsDvz':prefs.get('googleAdId')??'',
      'flgfHwwLex':prefs.getString('adid')??'',

    };

  }

}
