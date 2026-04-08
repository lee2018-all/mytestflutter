import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageBannerWidget extends StatefulWidget {
  final List<String> images;
  final Function(int, String) onImageTap;
  final Duration autoPlayInterval; // 自动轮播间隔
  final bool autoPlay; // 是否自动轮播

  const ImageBannerWidget({
    Key? key,
    required this.images,
    required this.onImageTap,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<ImageBannerWidget> createState() => _ImageBannerWidgetState();
}

class _ImageBannerWidgetState extends State<ImageBannerWidget> {
  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 如果启用自动轮播且有多张图片，启动定时器
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_pageController.hasClients && widget.images.length > 1) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  void _resetAutoPlay() {
    if (widget.autoPlay && widget.images.length > 1) {
      _stopAutoPlay();
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text('No images available'),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) {
        // 用户按下时暂停自动轮播
        if (widget.autoPlay && widget.images.length > 1) {
          _stopAutoPlay();
        }
      },
      onTapUp: (_) {
        // 用户抬起时恢复自动轮播
        if (widget.autoPlay && widget.images.length > 1) {
          _startAutoPlay();
        }
      },
      onTapCancel: () {
        // 用户取消时恢复自动轮播
        if (widget.autoPlay && widget.images.length > 1) {
          _startAutoPlay();
        }
      },
      child: Stack(
        children: [
          // PageView 轮播
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _resetAutoPlay();
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => widget.onImageTap(index, widget.images[index]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 左侧导航按钮
          if (widget.images.length > 1)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  _resetAutoPlay();
                },
                child: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: const Center(
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black45,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 右侧导航按钮
          if (widget.images.length > 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  _resetAutoPlay();
                },
                child: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: const Center(
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black45,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 页码指示器
          if (widget.images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}