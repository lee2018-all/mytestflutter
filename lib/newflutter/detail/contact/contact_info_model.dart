import 'package:flutter/cupertino.dart';

class ContactInfoModel {
  final List<ContactDTO>? contacts;
  final List<ContactDTO>? list;

  ContactInfoModel({
    this.contacts,
    this.list,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    List<ContactDTO> contactsList = [];
    if (json['contacts'] != null) {
      contactsList = (json['contacts'] as List)
          .map((item) => ContactDTO.fromJson(item))
          .toList();
    }

    List<ContactDTO> listList = [];
    if (json['list'] != null) {
      listList = (json['list'] as List)
          .map((item) => ContactDTO.fromJson(item))
          .toList();
    }

    return ContactInfoModel(
      contacts: contactsList,
      list: listList,
    );
  }
}

class ContactDTO {
  final String name;
  final String mobile;
  final String phone;
  final String relation;
  final int count;           // 通话次数
  final String duration;     // 通话时长
  final dynamic lastCallTime;        // 最后通话时间
  final dynamic lastCallDescribe;     // 最后通话描述
  final dynamic collectionContactRecord; // 联系人通话记录

  ContactDTO({
    required this.name,
    required this.mobile,
    required this.phone,
    required this.relation,
    required this.count,
    required this.duration,
    this.lastCallTime,
    this.lastCallDescribe,
    this.collectionContactRecord,
  });

  factory ContactDTO.fromJson(Map<String, dynamic> json) {
    return ContactDTO(
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relation: json['relation']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count'].toString()) ?? 0,
      duration: json['duration']?.toString() ?? '',
      lastCallTime: json['lastCallTime'],
      lastCallDescribe: json['lastCallDescribe'],
      collectionContactRecord: json['collectionContactRecord'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'phone': phone,
      'relation': relation,
      'count': count,
      'duration': duration,
      'lastCallTime': lastCallTime,
      'lastCallDescribe': lastCallDescribe,
      'collectionContactRecord': collectionContactRecord,
    };
  }
}

class FullHeightRecyclerView extends StatelessWidget {
  final Widget child;

  const FullHeightRecyclerView({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 0,
      ),
      child: child,
    );
  }
}

