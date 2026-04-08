class UtrBean {
  final String? utrNo;
  final String? upi;
  final String? amount;
  final String? gmtCreate;
  final List<String>? appendixUrls;

  UtrBean({
    this.utrNo,
    this.upi,
    this.amount,
    this.gmtCreate,
    this.appendixUrls,
  });

  factory UtrBean.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['appendixUrls'] != null) {
      urls = (json['appendixUrls'] as List).map((e) => e.toString()).toList();
    }
    return UtrBean(
      utrNo: json['utrNo'],
      upi: json['upi'],
      amount: json['amount']?.toString(),
      gmtCreate: json['gmtCreate'],
      appendixUrls: urls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utrNo': utrNo,
      'upi': upi,
      'amount': amount,
      'gmtCreate': gmtCreate,
      'appendixUrls': appendixUrls,
    };
  }
}

class ImageBean {
  final String? src;
  final bool isShili;
  final int? id;

  ImageBean({
    this.src,
    this.isShili = false,
    this.id,
  });
}

class Duceinfo {
  final RepaymentInfo? repaymentInfo;

  Duceinfo({this.repaymentInfo});

  factory Duceinfo.fromJson(Map<String, dynamic> json) {
    return Duceinfo(
      repaymentInfo: json['repaymentInfo'] != null
          ? RepaymentInfo.fromJson(json['repaymentInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repaymentInfo': repaymentInfo?.toJson(),
    };
  }
}

class RepaymentInfo {
  final String? orderNo;
  final String? billNo;
  final String? repaymentCapital;
  final String? borrowCapital;
  final String? discountCapital;
  final int? periodLength;
  final int? overdueDays;
  final String? interest;
  final String? serviceFee;
  final String? overdueServiceFee;
  final String? overdueFee;
  final String? remainCapital;

  RepaymentInfo({
    this.orderNo,
    this.billNo,
    this.repaymentCapital,
    this.borrowCapital,
    this.discountCapital,
    this.periodLength,
    this.overdueDays,
    this.interest,
    this.serviceFee,
    this.overdueServiceFee,
    this.overdueFee,
    this.remainCapital,
  });

  factory RepaymentInfo.fromJson(Map<String, dynamic> json) {
    return RepaymentInfo(
      orderNo: json['orderNo'],
      billNo: json['billNo'],
      repaymentCapital: json['repaymentCapital']?.toString(),
      borrowCapital: json['borrowCapital']?.toString(),
      discountCapital: json['discountCapital']?.toString(),
      periodLength: json['periodLength'],
      overdueDays: json['overdueDays'],
      interest: json['interest']?.toString(),
      serviceFee: json['serviceFee']?.toString(),
      overdueServiceFee: json['overdueServiceFee']?.toString(),
      overdueFee: json['overdueFee']?.toString(),
      remainCapital: json['remainCapital']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNo': orderNo,
      'billNo': billNo,
      'repaymentCapital': repaymentCapital,
      'borrowCapital': borrowCapital,
      'discountCapital': discountCapital,
      'periodLength': periodLength,
      'overdueDays': overdueDays,
      'interest': interest,
      'serviceFee': serviceFee,
      'overdueServiceFee': overdueServiceFee,
      'overdueFee': overdueFee,
      'remainCapital': remainCapital,
    };
  }
}