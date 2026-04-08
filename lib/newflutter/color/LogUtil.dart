// lib/utils/log_util.dart
import 'dart:convert';
import 'dart:developer' as developer;

class LogUtil {
  static const String tag = 'APP';
  static bool isDebug = true;

  static void d(String message) {
    if (!isDebug) return;
    _printWithLimit('[$tag] $message');
  }

  static void json(String title, dynamic data) {
    if (!isDebug) return;

    try {
      String jsonString;
      if (data is String) {
        // 尝试解析字符串
        var decoded = jsonDecode(data);
        jsonString = JsonEncoder.withIndent('  ').convert(decoded);
      } else {
        jsonString = JsonEncoder.withIndent('  ').convert(data);
      }

      developer.log('════════════════════════════════════════', name: 'JSON');
      developer.log('📦 $title', name: 'JSON');
      developer.log('════════════════════════════════════════', name: 'JSON');

      // 分段打印
      const int chunkSize = 800;
      for (int i = 0; i < jsonString.length; i += chunkSize) {
        int end = (i + chunkSize < jsonString.length) ? i + chunkSize : jsonString.length;
        developer.log(jsonString.substring(i, end), name: 'JSON');
      }

      developer.log('════════════════════════════════════════', name: 'JSON');
      developer.log('📊 Total length: ${jsonString.length} characters', name: 'JSON');
      developer.log('════════════════════════════════════════', name: 'JSON');

    } catch (e) {
      _printWithLimit('Error printing JSON: $e');
      _printWithLimit(data.toString());
    }
  }

  static void _printWithLimit(String message) {
    const int chunkSize = 800;
    for (int i = 0; i < message.length; i += chunkSize) {
      int end = (i + chunkSize < message.length) ? i + chunkSize : message.length;
      print(message.substring(i, end));
    }
  }

  // 专门用于打印API响应
  static void apiResponse(String url, Map<String, dynamic> response) {
    if (!isDebug) return;

    developer.log('════════════════════════════════════════', name: 'API');
    developer.log('🌐 API Response: $url', name: 'API');
    developer.log('════════════════════════════════════════', name: 'API');

    String prettyJson = JsonEncoder.withIndent('  ').convert(response);

    const int chunkSize = 800;
    for (int i = 0; i < prettyJson.length; i += chunkSize) {
      int end = (i + chunkSize < prettyJson.length) ? i + chunkSize : prettyJson.length;
      developer.log(prettyJson.substring(i, end), name: 'API');
    }

    developer.log('════════════════════════════════════════', name: 'API');
  }

  // 打印列表项
  static void items(String title, List items) {
    if (!isDebug) return;

    developer.log('════════════════════════════════════════', name: 'ITEMS');
    developer.log('📋 $title (${items.length} items)', name: 'ITEMS');
    developer.log('════════════════════════════════════════', name: 'ITEMS');

    for (int i = 0; i < items.length; i++) {
      if (i < 5) { // 只详细显示前5个
        developer.log('Item #$i: ${items[i].toString().substring(0, 200)}...', name: 'ITEMS');
      } else if (i == 5) {
        developer.log('... and ${items.length - 5} more items', name: 'ITEMS');
        break;
      }
    }

    developer.log('════════════════════════════════════════', name: 'ITEMS');
  }
}