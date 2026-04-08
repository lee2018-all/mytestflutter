import 'dart:convert';

class NormalString {
  int code = -1;
  String msg = '';
  String data = '';

  NormalString({
    this.code = -1,
    this.msg = '',
    this.data = '',
  });

  factory NormalString.fromJson(Map<String, dynamic> json) {
    // 安全地获取 data 值，确保转换为字符串
    String dataValue = '';
    if (json['data'] != null) {
      if (json['data'] is String) {
        dataValue = json['data'];
      } else if (json['data'] is Map) {
        // 如果 data 是 Map，尝试获取 link 字段或转为 JSON 字符串
        dataValue = json['data']['link']?.toString() ?? jsonEncode(json['data']);
      } else {
        dataValue = json['data'].toString();
      }
    }

    return NormalString(
      code: json['code'] is int ? json['code'] : int.tryParse(json['code'].toString()) ?? -1,
      msg: json['msg']?.toString() ?? '',
      data: dataValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'NormalString{code: $code, msg: $msg, data: $data}';
  }
}