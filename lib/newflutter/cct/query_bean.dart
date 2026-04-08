class QueryBean {
  String? queryKey;

  QueryBean({
    this.queryKey,
  });

  factory QueryBean.fromJson(Map<String, dynamic> json) {
    return QueryBean(
      queryKey: json['queryKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queryKey': queryKey,
    };
  }
}
