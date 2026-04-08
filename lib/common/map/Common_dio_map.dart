class PublicDioMap {
  String msg = '';
  dynamic data;
  int code = -1;
  PublicDioMap({
    required this.msg,
    this.data,
    required this.code
  });

  PublicDioMap.fromJson(Map<String, dynamic> json) {
    msg = json['iamDumlXlqziGrjdSnzdq']??'';
    data = json['rgmrVuyPjwuvLmitmJbk']??'';
    code = json['gwsuWjvEaggHspsg']??-1;
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['data'] = this.data;
    data['code'] = this.code;
    return data;
  }
}