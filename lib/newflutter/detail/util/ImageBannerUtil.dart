import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class ImageBannerUtil {
  /// 显示图片对话框
  static void showImageDialog({
    required BuildContext context,
    required String imageUrl,
    List<String>? allImages,
    int initialIndex = 0,
    VoidCallback? onSave,      // 改为 VoidCallback，因为实际使用中可能不需要传回图片
    VoidCallback? onShare,
  }) {
    // 如果有多个图片，显示轮播对话框
    if (allImages != null && allImages.length > 1) {
      _showCarouselDialog(
        context: context,
        images: allImages,
        initialIndex: initialIndex,
        onSave: onSave,
        onShare: onShare,
      );
    } else {
      // 单张图片
      _showSingleImageDialog(
        context: context,
        imageUrl: imageUrl,
        onSave: onSave,
        onShare: onShare,
      );
    }
  }

  /// 显示单张图片对话框
  static void _showSingleImageDialog({
    required BuildContext context,
    required String imageUrl,
    VoidCallback? onSave,
    VoidCallback? onShare,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 可缩放查看的图片
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 顶部按钮
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Icons.download,
                    onTap: () async {
                      Navigator.pop(context);
                      await _handleImageAction(imageUrl, 'save');
                      if (onSave != null) onSave();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.share,
                    onTap: () async {
                      Navigator.pop(context);
                      await _handleImageAction(imageUrl, 'share');
                      if (onShare != null) onShare();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示轮播图片对话框
  /// 使用 PageView 实现轮播对话框
  static void _showCarouselDialog({
    required BuildContext context,
    required List<String> images,
    required int initialIndex,
    VoidCallback? onSave,
    VoidCallback? onShare,
  }) {
    int currentIndex = initialIndex;
    PageController pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                // 使用 PageView 实现轮播
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 顶部按钮
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _buildIconButton(
                        icon: Icons.download,
                        onTap: () async {
                          Navigator.pop(dialogContext);
                          await _handleImageAction(images[currentIndex], 'save');
                          if (onSave != null) onSave();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.share,
                        onTap: () async {
                          Navigator.pop(dialogContext);
                          await _handleImageAction(images[currentIndex], 'share');
                          if (onShare != null) onShare();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.close,
                        onTap: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                ),

                // 底部指示器
                if (images.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == index
                                ? Colors.blue
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  ),

                // 左右导航按钮
                if (images.length > 1) ...[
                  Positioned(
                    left: 10,
                    top: 200,
                    child: GestureDetector(
                      onTap: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 200,
                    child: GestureDetector(
                      onTap: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建图标按钮
  static Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 处理图片操作
  static Future<void> _handleImageAction(String imageUrl, String action) async {
    try {
      // 下载图片
      final image = await _loadImage(imageUrl);
      if (image == null) return;

      if (action == 'save') {
        await _saveImage(image);
      } else if (action == 'share') {
        await _shareImage(image);
      }
    } catch (e) {
      print('Image action error: $e');
    }
  }

  /// 保存图片
  static Future<void> _saveImage(ui.Image image) async {
    try {
      // 将 ui.Image 转换为字节
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 保存到相册
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      print('Save result: $result');
    } catch (e) {
      print('Save image error: $e');
    }
  }

  /// 分享图片
  static Future<void> _shareImage(ui.Image image) async {
    try {
      // 将 ui.Image 转换为字节
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'share_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
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

  /// 加载图片
  static Future<ui.Image?> _loadImage(String url) async {
    final completer = Completer<ui.Image?>();

    try {
      final image = NetworkImage(url);
      final stream = image.resolve(const ImageConfiguration());

      late final ImageStreamListener listener;
      listener = ImageStreamListener(
            (ImageInfo info, bool _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);

      // 设置超时
      Future.delayed(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.complete(null);  // 超时返回 null
          stream.removeListener(listener);
        }
      });

      return await completer.future;
    } catch (e) {
      print('Load image error: $e');
      return null;
    }
  }
}