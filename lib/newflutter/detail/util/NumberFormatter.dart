class NumberFormatter {
  /// 格式化数字，添加千位分隔符，保留两位小数
  /// 例如: 1234567.89 -> 1,234,567.89
  static String formatWithCommaTwoDecimal(dynamic number) {
    if (number == null) return '0.00';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0.00';
    }

    return _formatNumber(value, 2, true);
  }

  /// 格式化数字，添加千位分隔符，保留指定小数位
  static String formatWithComma(dynamic number, [int decimalPlaces = 2]) {
    if (number == null) return '0${_getDecimalString(decimalPlaces)}';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0${_getDecimalString(decimalPlaces)}';
    }

    return _formatNumber(value, decimalPlaces, true);
  }

  /// 格式化数字，不加千位分隔符，保留两位小数
  static String formatPlainTwoDecimal(dynamic number) {
    if (number == null) return '0.00';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0.00';
    }

    return _formatNumber(value, 2, false);
  }

  /// 格式化数字，不加千位分隔符，保留指定小数位
  static String formatPlain(dynamic number, [int decimalPlaces = 2]) {
    if (number == null) return '0${_getDecimalString(decimalPlaces)}';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0${_getDecimalString(decimalPlaces)}';
    }

    return _formatNumber(value, decimalPlaces, false);
  }

  /// 格式化数字为货币格式（带货币符号）
  static String formatCurrency(dynamic number, {String currencySymbol = '₹', int decimalPlaces = 2}) {
    String formatted = formatWithCommaTwoDecimal(number);
    return '$currencySymbol $formatted';
  }

  /// 格式化百分比
  static String formatPercentage(dynamic number, {int decimalPlaces = 2}) {
    if (number == null) return '0%';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0%';
    }

    return '${_formatNumber(value * 100, decimalPlaces, false)}%';
  }

  /// 格式化数字为简写形式（K, M, B）
  /// 例如: 1234 -> 1.2K, 1234567 -> 1.2M
  static String formatShort(dynamic number, {int decimalPlaces = 1}) {
    if (number == null) return '0';

    double value;
    if (number is String) {
      value = double.tryParse(number) ?? 0.0;
    } else if (number is int) {
      value = number.toDouble();
    } else if (number is double) {
      value = number;
    } else {
      return '0';
    }

    if (value < 1000) {
      return _formatNumber(value, 0, false);
    } else if (value < 1000000) {
      return '${_formatNumber(value / 1000, decimalPlaces, false)}K';
    } else if (value < 1000000000) {
      return '${_formatNumber(value / 1000000, decimalPlaces, false)}M';
    } else {
      return '${_formatNumber(value / 1000000000, decimalPlaces, false)}B';
    }
  }

  /// 核心格式化方法
  static String _formatNumber(double value, int decimalPlaces, bool addCommas) {
    // 处理负数
    bool isNegative = value < 0;
    double absValue = value.abs();

    // 格式化小数部分
    String formatted = absValue.toStringAsFixed(decimalPlaces);

    // 分割整数和小数部分
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // 添加千位分隔符
    if (addCommas && integerPart.length > 3) {
      integerPart = _addCommas(integerPart);
    }

    // 重新组合
    String result = decimalPart.isNotEmpty
        ? '$integerPart.$decimalPart'
        : integerPart;

    // 添加负号
    if (isNegative) {
      result = '-$result';
    }

    return result;
  }

  /// 添加千位分隔符
  static String _addCommas(String integerPart) {
    String result = '';
    int length = integerPart.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        result += ',';
      }
      result += integerPart[i];
    }

    return result;
  }

  /// 获取小数字符串
  static String _getDecimalString(int decimalPlaces) {
    if (decimalPlaces <= 0) return '';
    return '.${'0' * decimalPlaces}';
  }

  /// 解析格式化的数字字符串回double
  static double parseFormattedNumber(String formatted) {
    if (formatted.isEmpty) return 0.0;

    // 移除货币符号和千位分隔符
    String clean = formatted.replaceAll(RegExp(r'[₹,\s]'), '');

    // 处理百分比
    if (clean.endsWith('%')) {
      clean = clean.substring(0, clean.length - 1);
      return double.tryParse(clean) ?? 0.0 / 100;
    }

    // 处理简写 (K, M, B)
    if (clean.endsWith('K') || clean.endsWith('k')) {
      clean = clean.substring(0, clean.length - 1);
      return (double.tryParse(clean) ?? 0.0) * 1000;
    } else if (clean.endsWith('M') || clean.endsWith('m')) {
      clean = clean.substring(0, clean.length - 1);
      return (double.tryParse(clean) ?? 0.0) * 1000000;
    } else if (clean.endsWith('B') || clean.endsWith('b')) {
      clean = clean.substring(0, clean.length - 1);
      return (double.tryParse(clean) ?? 0.0) * 1000000000;
    }

    return double.tryParse(clean) ?? 0.0;
  }

  /// 格式化银行账号（显示后四位）
  static String formatBankAccount(String accountNumber) {
    if (accountNumber.isEmpty) return '';
    if (accountNumber.length <= 4) return accountNumber;

    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return '**** $lastFour';
  }

  /// 格式化手机号（显示后四位）
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    if (phoneNumber.length <= 4) return phoneNumber;

    String lastFour = phoneNumber.substring(phoneNumber.length - 4);
    String stars = '*' * (phoneNumber.length - 4);
    return '$stars$lastFour';
  }

  /// 格式化身份证号/Aadhaar号（显示后四位）
  static String formatAadhaarNumber(String aadhaarNumber) {
    if (aadhaarNumber.isEmpty) return '';
    if (aadhaarNumber.length <= 4) return aadhaarNumber;

    String lastFour = aadhaarNumber.substring(aadhaarNumber.length - 4);
    return 'XXXX-XXXX-$lastFour';
  }

  /// 添加两个数字的和
  static double addNumbers(dynamic a, dynamic b, [dynamic c]) {
    double num1 = _toDouble(a);
    double num2 = _toDouble(b);
    double result = num1 + num2;

    if (c != null) {
      result += _toDouble(c);
    }

    return result;
  }

  /// 转换为double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// 扩展方法，方便直接调用
extension NumberFormatterExtension on num {
  /// 格式化数字，添加千位分隔符，保留两位小数
  String get toCurrency => NumberFormatter.formatCurrency(this);

  /// 格式化数字，添加千位分隔符，保留两位小数
  String get withComma => NumberFormatter.formatWithCommaTwoDecimal(this);

  /// 格式化数字为简写形式
  String get short => NumberFormatter.formatShort(this);
}

extension StringNumberExtension on String {
  /// 解析字符串为double
  double get parseNumber => NumberFormatter.parseFormattedNumber(this);

  /// 如果字符串是数字，格式化它
  String get formatIfNumber {
    double? value = double.tryParse(this);
    if (value != null) {
      return NumberFormatter.formatWithCommaTwoDecimal(value);
    }
    return this;
  }
}