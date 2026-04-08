class NormalMap {
  int code = -1;
  String msg = '';
  dynamic data;

  NormalMap({
    this.code = -1,
    this.msg = '',
    this.data,
  });

  factory NormalMap.fromJson(Map<String, dynamic> json) {
    return NormalMap(
      code: json['code'] is int ? json['code'] : int.tryParse(json['code'].toString()) ?? -1,
      msg: json['msg']?.toString() ?? '',
      data: json['data'],
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
    return 'NormalMap{code: $code, msg: $msg, data: $data}';
  }
}

