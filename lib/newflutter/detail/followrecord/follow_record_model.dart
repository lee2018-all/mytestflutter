class FollowlistBean {
  final String? mobile;
  final String? relation;
  final String? content;
  final String? name;
  final String? gmtCreate;
  final String? followUp;
  final String? callingResult;

  FollowlistBean({
    this.mobile,
    this.relation,
    this.content,
    this.name,
    this.gmtCreate,
    this.followUp,
    this.callingResult,
  });

  factory FollowlistBean.fromJson(Map<String, dynamic> json) {
    return FollowlistBean(
      mobile: json['mobile'],
      relation: json['relation'],
      content: json['content'],
      name: json['name'],
      gmtCreate: json['gmtCreate'],
      followUp: json['followUp'],
      callingResult: json['callingResult'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'relation': relation,
      'content': content,
      'name': name,
      'gmtCreate': gmtCreate,
      'followUp': followUp,
      'callingResult': callingResult,
    };
  }
}

class FollowRecordModel {
  final List<FollowlistBean>? phoneRecordList;
  final bool? hasNextPage;

  FollowRecordModel({
    this.phoneRecordList,
    this.hasNextPage,
  });

  factory FollowRecordModel.fromJson(Map<String, dynamic> json) {
    List<FollowlistBean> list = [];
    if (json['phoneRecordList'] != null) {
      list = (json['phoneRecordList'] as List)
          .map((item) => FollowlistBean.fromJson(item))
          .toList();
    }

    return FollowRecordModel(
      phoneRecordList: list,
      hasNextPage: json['hasNextPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneRecordList': phoneRecordList?.map((e) => e.toJson()).toList(),
      'hasNextPage': hasNextPage,
    };
  }
}