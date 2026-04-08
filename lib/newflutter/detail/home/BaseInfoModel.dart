class BaseInfoModel {
  final List<BaseInfoItem> list;

  BaseInfoModel({
    required this.list,
  });

  factory BaseInfoModel.fromJson(Map<String, dynamic> json) {
    List<BaseInfoItem> items = [];
    if (json['list'] != null) {
      items = (json['list'] as List)
          .map((item) => BaseInfoItem.fromJson(item))
          .toList();
    }
    return BaseInfoModel(
      list: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
    };
  }

  // 根据名称获取值
  String getValue(String name) {
    for (var item in list) {
      if (item.name == name) {
        return item.value ?? '';
      }
    }
    return '';
  }

  // 根据名称获取加密的值
  String getEncryptedValue(String name) {
    for (var item in list) {
      if (item.name == name) {
        return item.encryptValue ?? '';
      }
    }
    return '';
  }
}

class BaseInfoItem {
  final String? name;
  final String? value;
  final String? encryptValue;

  BaseInfoItem({
    this.name,
    this.value,
    this.encryptValue,
  });

  factory BaseInfoItem.fromJson(Map<String, dynamic> json) {
    return BaseInfoItem(
      name: json['name'],
      value: json['value'],
      encryptValue: json['encryptValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'encryptValue': encryptValue,
    };
  }
}
class UserUrlInfoModel {
  final String? userCode;
  final String? aadhaarCardFrontUrl;
  final String? aadhaarCardBackUrl;
  final String? panCardFrontUrl;
  final String? panCardBackUrl;
  final String? signatureUrl;
  final String? photoUrl;

  UserUrlInfoModel({
    this.userCode,
    this.aadhaarCardFrontUrl,
    this.aadhaarCardBackUrl,
    this.panCardFrontUrl,
    this.panCardBackUrl,
    this.signatureUrl,
    this.photoUrl,
  });

  factory UserUrlInfoModel.fromJson(Map<String, dynamic> json) {
    return UserUrlInfoModel(
      userCode: json['userCode'],
      aadhaarCardFrontUrl: json['aadhaarCardFrontUrl'],
      aadhaarCardBackUrl: json['aadhaarCardBackUrl'],
      panCardFrontUrl: json['panCardFrontUrl'],
      panCardBackUrl: json['panCardBackUrl'],
      signatureUrl: json['signatureUrl'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userCode': userCode,
      'aadhaarCardFrontUrl': aadhaarCardFrontUrl,
      'aadhaarCardBackUrl': aadhaarCardBackUrl,
      'panCardFrontUrl': panCardFrontUrl,
      'panCardBackUrl': panCardBackUrl,
      'signatureUrl': signatureUrl,
      'photoUrl': photoUrl,
    };
  }
}


class OcrUrlInfoModel {
  final String? userCode;
  final String? ocrPhotoUrl;
  final String? ocrAadhaarFrontUrl;
  final String? ocrAadhaarBackUrl;
  final String? ocrPanFrontUrl;
  final String? ocrPanBackUrl;

  OcrUrlInfoModel({
    this.userCode,
    this.ocrPhotoUrl,
    this.ocrAadhaarFrontUrl,
    this.ocrAadhaarBackUrl,
    this.ocrPanFrontUrl,
    this.ocrPanBackUrl,
  });

  factory OcrUrlInfoModel.fromJson(Map<String, dynamic> json) {
    return OcrUrlInfoModel(
      userCode: json['userCode'],
      ocrPhotoUrl: json['ocrPhotoUrl'],
      ocrAadhaarFrontUrl: json['ocrAadhaarFrontUrl'],
      ocrAadhaarBackUrl: json['ocrAadhaarBackUrl'],
      ocrPanFrontUrl: json['ocrPanFrontUrl'],
      ocrPanBackUrl: json['ocrPanBackUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userCode': userCode,
      'ocrPhotoUrl': ocrPhotoUrl,
      'ocrAadhaarFrontUrl': ocrAadhaarFrontUrl,
      'ocrAadhaarBackUrl': ocrAadhaarBackUrl,
      'ocrPanFrontUrl': ocrPanFrontUrl,
      'ocrPanBackUrl': ocrPanBackUrl,
    };
  }
}