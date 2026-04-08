import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemModel {
  String? originAppName;
  String? appName;
  String? sourceMerchantCode;
  String? productCategory;
  String? productCategoryName;
  String? channel;
  String? name;
  String? mobile;
  String? period;
  int? totalPeriod;
  String? collectionStatus;
  dynamic followDays;
  dynamic collectionType;
  String? collectionNo;
  String? tradeNo;
  String? userCode;
  int? followId;
  String? followUp;
  int? maxOverdueDays;
  int? overdueDays;
  String? city;
  dynamic followTime;
  dynamic nextTime;
  dynamic noRepayAmount;
  String? agentName;
  List<CollectionOrderDetailVo>? collectionOrderDetailVoList;
  String? lastOperation;
  int? isShowSendCoupon;
  int? isExtend;
  bool? extension;
  int? borrowType;
  String? ocrPhotoUrl;
  String? cardNumber;
  String? ifsc;
  String? utr;
  String? upi;

  // UI 相关属性（非JSON字段）
  dynamic color;
  dynamic borderColor;

  ItemModel({
    this.originAppName,
    this.appName,
    this.sourceMerchantCode,
    this.productCategory,
    this.productCategoryName,
    this.channel,
    this.name,
    this.mobile,
    this.period,
    this.totalPeriod,
    this.collectionStatus,
    this.followDays,
    this.collectionType,
    this.collectionNo,
    this.tradeNo,
    this.userCode,
    this.followId,
    this.followUp,
    this.maxOverdueDays,
    this.overdueDays,
    this.city,
    this.followTime,
    this.nextTime,
    this.noRepayAmount,
    this.agentName,
    this.collectionOrderDetailVoList,
    this.lastOperation,
    this.isShowSendCoupon,
    this.isExtend,
    this.extension,
    this.borrowType,
    this.ocrPhotoUrl,
    this.cardNumber,
    this.ifsc,
    this.utr,
    this.upi,
    this.color,
    this.borderColor,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      originAppName: json['originAppName'],
      appName: json['appName'],
      sourceMerchantCode: json['sourceMerchantCode'],
      productCategory: json['productCategory'],
      productCategoryName: json['productCategoryName'],
      channel: json['channel'],
      name: json['name'],
      mobile: json['mobile'],
      period: json['period']?.toString(),
      totalPeriod: json['totalPeriod'],
      collectionStatus: json['collectionStatus'],
      followDays: json['followDays'],
      collectionType: json['collectionType'],
      collectionNo: json['collectionNo'],
      tradeNo: json['tradeNo'],
      userCode: json['userCode'],
      followId: json['followId'],
      followUp: json['followUp'],
      maxOverdueDays: json['maxOverdueDays'],
      overdueDays: json['overdueDays'],
      city: json['city'],
      followTime: json['followTime'],
      nextTime: json['nextTime'],
      noRepayAmount: json['noRepayAmount'],
      agentName: json['agentName'],
      collectionOrderDetailVoList: json['collectionOrderDetailVoList'] != null
          ? (json['collectionOrderDetailVoList'] as List)
          .map((e) => CollectionOrderDetailVo.fromJson(e))
          .toList()
          : [],
      lastOperation: json['lastOperation'],
      isShowSendCoupon: json['isShowSendCoupon'],
      isExtend: json['isExtend'],
      extension: json['extension'] ?? false,
      borrowType: json['borrowType'],
      ocrPhotoUrl: json['ocrPhotoUrl'],
      cardNumber: json['cardNumber'],
      ifsc: json['ifsc'],
      utr: json['utr'],
      upi: json['upi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originAppName': originAppName,
      'appName': appName,
      'sourceMerchantCode': sourceMerchantCode,
      'productCategory': productCategory,
      'productCategoryName': productCategoryName,
      'channel': channel,
      'name': name,
      'mobile': mobile,
      'period': period,
      'totalPeriod': totalPeriod,
      'collectionStatus': collectionStatus,
      'followDays': followDays,
      'collectionType': collectionType,
      'collectionNo': collectionNo,
      'tradeNo': tradeNo,
      'userCode': userCode,
      'followId': followId,
      'followUp': followUp,
      'maxOverdueDays': maxOverdueDays,
      'overdueDays': overdueDays,
      'city': city,
      'followTime': followTime,
      'nextTime': nextTime,
      'noRepayAmount': noRepayAmount,
      'agentName': agentName,
      'collectionOrderDetailVoList': collectionOrderDetailVoList?.map((e) => e.toJson()).toList(),
      'lastOperation': lastOperation,
      'isShowSendCoupon': isShowSendCoupon,
      'isExtend': isExtend,
      'extension': extension,
      'borrowType': borrowType,
      'ocrPhotoUrl': ocrPhotoUrl,
      'cardNumber': cardNumber,
      'ifsc': ifsc,
      'utr': utr,
      'upi': upi,
    };
  }

  // 获取过期金额的便捷方法
  double? get expireAmount {
    if (collectionOrderDetailVoList?.isNotEmpty ?? false) {
      return collectionOrderDetailVoList!.first.expireAmount;
    }
    return null;
  }

  // 获取已付金额的便捷方法
  double? get paidAmount {
    if (collectionOrderDetailVoList?.isNotEmpty ?? false) {
      return collectionOrderDetailVoList!.first.paidAmount;
    }
    return null;
  }

  set relation(String relation) {}

  @override
  String toString() {
    return 'ItemModel(tradeNo: $tradeNo, name: $name, overdueDays: $overdueDays, amount: $expireAmount)';
  }
}


class CollectionOrderDetailVo {
  String? tradeNo;
  int? period;
  String? repaymentDate;
  double? realCapital;
  double? interest;
  double? lateFee;
  dynamic noRepayAmount;
  double? expireAmount;
  int? overdueDays;
  dynamic actualRepaymentDate;
  double? deductAmount;
  double? paidAmount;
  dynamic newPaidAmount;
  double? totalAmountShouldRepay;
  String? paymentDate;
  double? paymentAmount;

  CollectionOrderDetailVo({
    this.tradeNo,
    this.period,
    this.repaymentDate,
    this.realCapital,
    this.interest,
    this.lateFee,
    this.noRepayAmount,
    this.expireAmount,
    this.overdueDays,
    this.actualRepaymentDate,
    this.deductAmount,
    this.paidAmount,
    this.newPaidAmount,
    this.totalAmountShouldRepay,
    this.paymentDate,
    this.paymentAmount,
  });

  factory CollectionOrderDetailVo.fromJson(Map<String, dynamic> json) {
    return CollectionOrderDetailVo(
      tradeNo: json['tradeNo'],
      period: json['period'],
      repaymentDate: json['repaymentDate'],
      realCapital: json['realCapital']?.toDouble(),
      interest: json['interest']?.toDouble(),
      lateFee: json['lateFee']?.toDouble(),
      noRepayAmount: json['noRepayAmount'],
      expireAmount: json['expireAmount']?.toDouble(),
      overdueDays: json['overdueDays'],
      actualRepaymentDate: json['actualRepaymentDate'],
      deductAmount: json['deductAmount']?.toDouble(),
      paidAmount: json['paidAmount']?.toDouble(),
      newPaidAmount: json['newPaidAmount'],
      totalAmountShouldRepay: json['totalAmountShouldRepay']?.toDouble(),
      paymentDate: json['paymentDate'],
      paymentAmount: json['paymentAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tradeNo': tradeNo,
      'period': period,
      'repaymentDate': repaymentDate,
      'realCapital': realCapital,
      'interest': interest,
      'lateFee': lateFee,
      'noRepayAmount': noRepayAmount,
      'expireAmount': expireAmount,
      'overdueDays': overdueDays,
      'actualRepaymentDate': actualRepaymentDate,
      'deductAmount': deductAmount,
      'paidAmount': paidAmount,
      'newPaidAmount': newPaidAmount,
      'totalAmountShouldRepay': totalAmountShouldRepay,
      'paymentDate': paymentDate,
      'paymentAmount': paymentAmount,
    };
  }

  // 计算剩余应还金额
  double? get remainingAmount {
    if (totalAmountShouldRepay != null && paidAmount != null) {
      return totalAmountShouldRepay! - paidAmount!;
    }
    return null;
  }

  @override
  String toString() {
    return 'CollectionOrderDetailVo(tradeNo: $tradeNo, period: $period, expireAmount: $expireAmount, paidAmount: $paidAmount)';
  }
}

class BottomSheetMenu extends StatelessWidget {
  final List<String> menuItems;
  final Function(int) onItemSelected;

  const BottomSheetMenu({
    super.key,
    required this.menuItems,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部手柄
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // 菜单标题
          const Text(
            'Operation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 菜单项列表
          ...List.generate(menuItems.length, (index) {
            return _buildMenuItem(
              text: menuItems[index],
              isLast: index == menuItems.length - 1,
              onTap: () {
                Navigator.pop(context);
                onItemSelected(index);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String text,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}



class PageBean {
  List<ItemModel>? itemList;

  PageBean({this.itemList});

  factory PageBean.fromJson(Map<String, dynamic> json) {
    return PageBean(
      itemList: json['itemList'] != null
          ? (json['itemList'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList()
          : []

    );
  }

  @override
  String toString() {
    return 'PageBean(itemList: ${itemList?.length ?? 0} items)';
  }
}
