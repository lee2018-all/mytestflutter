import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AESUtil.dart';

class FileUtil {
  // UTR 正则表达式：12位数字
  static final RegExp _utrPattern = RegExp(r'^\d{12}$');

  // UPI 正则表达式：字母数字组合，通常格式如 username@bank
  // 例如：abc@okhdfcbank, 1234567890@ybl 等
  static final RegExp _upiPattern = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');

  /// 验证 UTR 格式是否正确（12位数字）
  static bool isValidUtr(String input) {
    if (input.isEmpty) return false;
    return _utrPattern.hasMatch(input);
  }


  static String getSafeImageUrl(String originalUrl) {
    if (!kIsWeb) return originalUrl;

    // 如果已经是处理过的 URL，直接返回
    if (originalUrl.contains('x-oss-process')) return originalUrl;

    // 添加图片处理参数
    final uri = Uri.parse(originalUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    params['x-oss-process'] = 'image/info,ignore-error/1';  // 不改变图片，只重写响应头

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path,
      queryParameters: params.isNotEmpty ? params : null,
    ).toString();
  }

  static String decryptMobile(String encrypted) {
    if (encrypted.isEmpty) return '';
    try {
      print(encrypted);
      String decrypted = AESUtil.decryptWithFallback(encrypted);
      print(decrypted);

      return decrypted.replaceAll('00910', '').replaceAll('+91', '');
    } catch (e) {
      return encrypted;
    }
  }

  /// 验证 UPI 格式是否正确
  /// UPI ID 格式：username@bankname
  /// 例如：abc@okhdfcbank, 1234567890@ybl
  static bool isValidUpi(String input) {
    if (input.isEmpty) return false;
    return _upiPattern.hasMatch(input);
  }

  static void openUrl(String url) {
    launchUrl(Uri.parse(url));
  }

  /// 复制文本到剪贴板
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // 显示提示
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }



  /// 为TextView设置复制功能
  static void copyToClipboardTextView(BuildContext context, Widget widget) {
    // 这个函数在Flutter中通常不需要，因为我们可以直接给Text添加点击复制功能
    // 这里保留为兼容性，但在实际使用中建议直接使用copyToClipboard
  }

  /// 复制视图
  static Widget copyview(Widget copyButton, Widget textWidget, BuildContext context) {
    // 这个函数在Flutter中可以通过组合实现
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        textWidget,
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            if (textWidget is Text) {
              copyToClipboard(context, textWidget.data ?? '');
            } else if (textWidget is SelectableText) {
              copyToClipboard(context, textWidget.data ?? '');
            }
          },
          child: copyButton,
        ),
      ],
    );
  }

  /// 保存图片
  static Future<void> saveImage(ui.Image image, BuildContext context) async {
    try {
      // 将ui.Image转换为字节
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        // Web平台处理
        _saveImageWeb(pngBytes);
      } else {
        // 移动平台处理
        await _saveImageMobile(pngBytes, context);
      }
    } catch (e) {
      print('Save image error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }




  /// 移动平台保存图片
  static Future<void> _saveImageMobile(Uint8List bytes, BuildContext context) async {
    // 请求存储权限
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // 保存到相册
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (context.mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  /// Web平台保存图片
  static void _saveImageWeb(Uint8List bytes) {
    // Web平台通过创建下载链接保存
    // 需要导入dart:html (仅Web平台可用)
    // 这里简化处理
    print('Web save image not implemented');
  }

  /// 保存图片（通过URL）
  static Future<void> saveImageFromUrl(String url, BuildContext context) async {
    try {
      // 下载图片
      var response = await HttpClient().getUrl(Uri.parse(url));
      var bytes = await response.close().then((res) => res.fold(<int>[], (List<int> list, data) {
        list.addAll(data);
        return list;
      }));

      Uint8List uint8list = Uint8List.fromList(bytes);

      if (kIsWeb) {
        _saveImageWeb(uint8list);
      } else {
        await _saveImageMobile(uint8list, context);
      }
    } catch (e) {
      print('Save image from url error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  /// 分享图片
  static Future<void> shareImage(ui.Image image, BuildContext context) async {
    try {
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(pngBytes);

      // 分享
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Shared image',
      );
    } catch (e) {
      print('Share image error: $e');
    }
  }

  /// 读取文件
  static Future<String> readFile(String filePath) async {
    try {
      File file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      print('Read file error: $e');
      return '';
    }
  }

  /// 写入文件
  static Future<void> writeFile(String filePath, String content) async {
    try {
      File file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      print('Write file error: $e');
    }
  }

  /// 获取应用文档目录
  static Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 获取缓存目录
  static Future<String> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String filePath) async {
    File file = File(filePath);
    return await file.exists();
  }

  /// 删除文件
  static Future<void> deleteFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Delete file error: $e');
    }
  }
}

/// 扩展方法，方便使用
extension FileUtilExtension on String {
  /// 验证是否为有效的 UTR（12位数字）
  bool get isValidUtr => FileUtil.isValidUtr(this);

  /// 验证是否为有效的 UPI ID
  bool get isValidUpi => FileUtil.isValidUpi(this);
}