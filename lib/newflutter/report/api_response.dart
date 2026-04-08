class ApiResponse {
  Data? data;
  Pages? pages;
  List<ColumnInfo>? keyList;
  List<String>? columns;
  List<Map<String, dynamic>>? reportData;

  ApiResponse({
    this.data,
    this.pages,
    this.keyList,
    this.columns,
    this.reportData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      pages: json['pages'] != null ? Pages.fromJson(json['pages']) : null,
      keyList: json['keyList'] != null
          ? (json['keyList'] as List).map((e) => ColumnInfo.fromJson(e)).toList()
          : null,
      columns: json['columns'] != null
          ? (json['columns'] as List).map((e) => e.toString()).toList()
          : null,
      reportData: json['reportData'] != null
          ? (json['reportData'] as List).map((e) => e as Map<String, dynamic>).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'pages': pages?.toJson(),
      'keyList': keyList?.map((e) => e.toJson()).toList(),
      'columns': columns,
      'reportData': reportData,
    };
  }
}

class Data {
  List<Map<String, dynamic>>? reportCctPerformance;

  Data({
    this.reportCctPerformance,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      reportCctPerformance: json['reportCctPerformance'] != null
          ? (json['reportCctPerformance'] as List).map((e) => e as Map<String, dynamic>).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportCctPerformance': reportCctPerformance,
    };
  }
}

class Pages {
  int? pageSize;
  int? currentPage;
  int? totalCount;

  Pages({
    this.pageSize,
    this.currentPage,
    this.totalCount,
  });

  factory Pages.fromJson(Map<String, dynamic> json) {
    return Pages(
      pageSize: json['pageSize'],
      currentPage: json['currentPage'],
      totalCount: json['totalCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageSize': pageSize,
      'currentPage': currentPage,
      'totalCount': totalCount,
    };
  }
}

class ColumnInfo {
  String? name;
  String? type;
  List<DataOption>? option;
  String? chooseName;

  ColumnInfo({
    this.name,
    this.type,
    this.option,
    this.chooseName,
  });

  factory ColumnInfo.fromJson(Map<String, dynamic> json) {
    return ColumnInfo(
      name: json['name'],
      type: json['type'],
      option: json['option'] != null
          ? (json['option'] as List).map((e) => DataOption.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'option': option?.map((e) => e.toJson()).toList(),
      'chooseName': chooseName,
    };
  }
}

class DataOption {
  String? key;
  String? value;

  DataOption({
    this.key,
    this.value,
  });

  factory DataOption.fromJson(Map<String, dynamic> json) {
    return DataOption(
      key: json['key'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
