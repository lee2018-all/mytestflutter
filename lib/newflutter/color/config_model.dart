import 'package:flutter/cupertino.dart';

class ConfigModel {

  BuildContext? _context;
  void setContext(BuildContext context) {
    _context = context;
  }

  void disposeContext() {
    _context = null;
  }

  List<ConfigOverdueTimeDTO>? overdueTime;
  List<ConfigCollectionStatusDTO>? collectionStatus;
  List<ConfigRelativesDTO>? relatives;

  ConfigModel({this.overdueTime, this.collectionStatus,this.relatives});

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      overdueTime: (json['overdueTime'] as List?)
          ?.map((e) => ConfigOverdueTimeDTO.fromJson(e))
          .toList(),
      collectionStatus: (json['collectionStatus'] as List?)
          ?.map((e) => ConfigCollectionStatusDTO.fromJson(e))
          .toList(),
      relatives: (json['relatives'] as List?)
          ?.map((e) => ConfigRelativesDTO.fromJson(e))
          .toList(),
    );
  }
}

class ConfigOverdueTimeDTO {
  String? value;
  bool isChoose;

  ConfigOverdueTimeDTO({this.value, this.isChoose = false});

  factory ConfigOverdueTimeDTO.fromJson(Map<String, dynamic> json) {
    return ConfigOverdueTimeDTO(
      value: json['value'],
    );
  }
}

class ConfigCollectionStatusDTO {
  String? value;
  String? name;
  bool isChoose;

  ConfigCollectionStatusDTO({this.value, this.name, this.isChoose = false});

  factory ConfigCollectionStatusDTO.fromJson(Map<String, dynamic> json) {
    return ConfigCollectionStatusDTO(
      name: json['name'],
      value: json['value'],
    );
  }
}



class ConfigRelativesDTO {
  final String? name;
  final String? value;

  ConfigRelativesDTO({this.name, this.value});

  factory ConfigRelativesDTO.fromJson(Map<String, dynamic> json) {
    return ConfigRelativesDTO(
      name: json['name'],
      value: json['value'],
    );
  }
}