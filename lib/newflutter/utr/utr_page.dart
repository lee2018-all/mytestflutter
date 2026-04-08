import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/utr/utr_model.dart';
import 'package:mytestflutter/newflutter/utr/utr_viewmodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../detail/util/FileUtil.dart';
import '../detail/util/ImageBannerUtil.dart';
import '../detail/util/NumberFormatter.dart';

class UtrPage extends StatefulWidget {
  final String? loanId;
  final String? userCode;

  const UtrPage({Key? key, this.loanId, this.userCode}) : super(key: key);

  @override
  State<UtrPage> createState() => _UtrPageState();
}

class _UtrPageState extends State<UtrPage> {
  late final UtrViewModel _viewModel;

  // Controllers
  final TextEditingController _utrController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();

  // Focus nodes
  final FocusNode _utrFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _upiFocusNode = FocusNode();

  // State
  List<UtrBean> _utrList = [];
  List<ImageBean> _images = [];
  bool _isLoading = true;
  bool _canLoadMore = false;
  int _pageNum = 1;
  int _pageSize = 10;

  // Validation flags
  bool _isUtrValid = true;
  bool _isUpiValid = true;
  bool _isAmountValid = true;
  bool _showUtrError = false;
  bool _showUpiError = false;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = UtrViewModel();
    _viewModel.setContext(context);
    _initData();
    _setupListeners();
    _setupFocusListeners();
  }

  void _initData() {
    // 初始化图片列表，添加一个空项用于添加图片
    _images.add(ImageBean(isShili: true));

    // 获取UTR记录列表
    if (widget.loanId != null) {
      _viewModel.getUtrRecord(widget.loanId!, _pageNum, _pageSize);
    }
  }

  void _setupListeners() {
    _viewModel.loading.listen((loading) {
      if (loading) {
        EasyLoading.show();
      } else {
        EasyLoading.dismiss();
      }
    });

    _viewModel.error.listen((error) {
      if (error.isNotEmpty && mounted) {
        EasyLoading.showError(error);
      }
    });

    _viewModel.utrList.listen((data) {
      if (mounted) {
        setState(() {
          if (_pageNum == 1) {
            _utrList = data;
          } else {
            _utrList.addAll(data);
          }
          _canLoadMore = data.length >= _pageSize;
          _isLoading = false;
        });
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      }
    });

    _viewModel.uploadResult.listen((success) {
      if (success && mounted) {
        // 清空输入框
        _utrController.clear();
        _amountController.clear();
        _upiController.clear();
        // 清空图片
        _images.clear();
        _images.add(ImageBean(isShili: true));
        // 禁用提交按钮
        _checkSubmitEnabled();
        // 刷新列表
        _refreshData();
        EasyLoading.showSuccess('UTR submitted successfully');
      }
    });

    _viewModel.imageUploadResult.listen((imageUrl) {
      if (imageUrl.isNotEmpty && mounted) {
        // 添加图片到列表
        if (_images.length < 6) {
          _images.insert(0, ImageBean(src: imageUrl));
        } else {
          _images[5] = ImageBean(src: imageUrl);
        }
        setState(() {});
        _checkSubmitEnabled();
      }
    });
  }

  void _setupFocusListeners() {
    _utrFocusNode.addListener(() {
      if (_utrFocusNode.hasFocus) {
        setState(() {
          _showUtrError = false;
        });
      } else {
        _validateUtr();
      }
    });

    _upiFocusNode.addListener(() {
      if (_upiFocusNode.hasFocus) {
        setState(() {
          _showUpiError = false;
        });
      } else {
        _validateUpi();
      }
    });

    _amountController.addListener(() {
      _checkSubmitEnabled();
    });
  }

  void _validateUtr() {
    String utr = _utrController.text.trim();
    if (utr.isNotEmpty && !FileUtil.isValidUtr(utr)) {
      setState(() {
        _isUtrValid = false;
        _showUtrError = true;
      });
    } else {
      setState(() {
        _isUtrValid = true;
        _showUtrError = false;
      });
    }
    _checkSubmitEnabled();
  }

  void _validateUpi() {
    String upi = _upiController.text.trim();
    if (upi.isNotEmpty && !FileUtil.isValidUpi(upi)) {
      setState(() {
        _isUpiValid = false;
        _showUpiError = true;
      });
    } else {
      setState(() {
        _isUpiValid = true;
        _showUpiError = false;
      });
    }
    _checkSubmitEnabled();
  }

  void _checkSubmitEnabled() {
    String amount = _amountController.text.trim();
    String utr = _utrController.text.trim();
    String upi = _upiController.text.trim();

    // 检查是否有有效图片（除了占位图外的其他图片）
    bool hasValidImage =
        _images.where((img) => img.src != null && img.src!.isNotEmpty).length >
            0;

    bool isValid =
        amount.isNotEmpty &&
            utr.isNotEmpty &&
            upi.isNotEmpty &&
            _isUtrValid &&
            _isUpiValid &&
            hasValidImage;

    setState(() {
      _isAmountValid = isValid;
    });
  }

  void _refreshData() async {
    setState(() {
      _pageNum = 1;
      _isLoading = true;
    });
    if (widget.loanId != null) {
      _viewModel.getUtrRecord(widget.loanId!, _pageNum, _pageSize);
    }
  }

  void _loadMore() async {
    if (_canLoadMore && !_isLoading) {
      setState(() {
        _pageNum++;
        _isLoading = true;
      });
      if (widget.loanId != null) {
        _viewModel.getUtrRecord(widget.loanId!, _pageNum, _pageSize);
      }
    }
  }

  void _onRefresh() {
    _refreshData();
  }

  void _onLoading() {
    _loadMore();
  }

  void _submitUtr() {
    String amount = _amountController.text.trim();
    String utr = _utrController.text.trim();
    String upi = _upiController.text.trim();

    // 获取所有图片URL
    List<String> images = _images
        .where((img) => img.src != null && img.src!.isNotEmpty)
        .map((img) => img.src!)
        .toList();

    if (images.isEmpty) {
      EasyLoading.showInfo('Please upload at least one image');
      return;
    }

    _viewModel.submitUtr(
      amount: amount,
      upi: upi,
      userCode: widget.userCode ?? '',
      utrNo: utr,
      appendixUrl: images,
      tradeNo: widget.loanId ?? '',
    );
  }

  // ==================== 图片轮播弹窗 ====================

  /// 显示图片轮播弹窗
  void _showImageCarousel(List<String> images, int initialIndex) {
    if (images.isEmpty) {
      EasyLoading.showInfo('No images available');
      return;
    }

    int currentIndex = initialIndex;
    PageController pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 轮播图
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
                      // 分享按钮
                      GestureDetector(
                        onTap: () {
                          _shareImage(images[currentIndex]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 保存按钮
                      GestureDetector(
                        onTap: () {
                          _saveImage(images[currentIndex]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 关闭按钮
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 页码指示器
                if (images.length > 1)
                  Positioned(
                    bottom: 20,
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

  void _shareImage(String imageUrl) {
    // 使用分享功能
    FileUtil.saveImageFromUrl(imageUrl, context);
  }

  void _saveImage(String imageUrl) {
    FileUtil.saveImageFromUrl(imageUrl, context);
  }

  void _showImageDialog(String imageUrl) {
    ImageBannerUtil.showImageDialog(
      context: context,
      imageUrl: imageUrl,
      onSave: () {
        FileUtil.saveImageFromUrl(imageUrl, context);
      },
      onShare: () {
        FileUtil.saveImageFromUrl(imageUrl, context);
      },
    );
  }

  @override
  void dispose() {
    _utrController.dispose();
    _amountController.dispose();
    _upiController.dispose();
    _utrFocusNode.dispose();
    _amountFocusNode.dispose();
    _upiFocusNode.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildUtrList()),
          _buildInputForm(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'UTR',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E88E5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildUtrList() {
    if (_isLoading && _utrList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_utrList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No UTR records',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeaderRow(),
        Expanded(
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: _canLoadMore,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            header: const ClassicHeader(
              idleText: 'Pull down to refresh',
              refreshingText: 'Refreshing...',
              completeText: 'Refresh completed',
            ),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              loadingText: 'Loading more...',
              noDataText: 'No more data',
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _utrList.length,
              itemBuilder: (context, index) {
                final utr = _utrList[index];
                return UtrListItem(
                  utr: utr,
                  index: index,
                  onImageTap: (images, initialIndex) {
                    // 显示图片轮播
                    _showImageCarousel(images, initialIndex);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: const Center(
              child: Text(
                'Action',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: const Center(
              child: Text(
                'UTR\nUPI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: const Center(
              child: Text(
                'Amount\nOperating Time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // UTR 输入
          _buildInputRow(
            label: 'UTR',
            controller: _utrController,
            focusNode: _utrFocusNode,
            hint: '12 digits number',
            keyboardType: TextInputType.number,
            maxLength: 12,
            showError: _showUtrError,
            errorText: 'The UTR format is incorrect',
          ),
          const SizedBox(height: 12),
          // Amount 输入
          _buildInputRow(
            label: 'Amount',
            controller: _amountController,
            focusNode: _amountFocusNode,
            hint: 'Please input',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          // UPI 输入
          _buildInputRow(
            label: 'UPI',
            controller: _upiController,
            focusNode: _upiFocusNode,
            hint: 'Please input',
            showError: _showUpiError,
            errorText: 'The UPI format is incorrect',
          ),
          const SizedBox(height: 16),
          // 图片网格
          _buildImageGrid(),
          const SizedBox(height: 16),
          // 按钮
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool showError = false,
    String errorText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                maxLength: maxLength,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  border: InputBorder.none,
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF262626)),
              ),
            ),
          ],
        ),
        const Divider(height: 1),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFFF4040)),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _images.length > 6 ? 6 : _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return ImageUploadItem(
          image: image,
          onTap: () {
            if (image.isShili) {
              // 添加图片
              _viewModel.pickImage();
            } else if (image.src != null && image.src!.isNotEmpty) {
              // 查看大图
              _showImageDialog(image.src!);
            }
          },
          onDelete: image.src != null && image.src!.isNotEmpty
              ? () {
            setState(() {
              _images.removeAt(index);
              // 确保至少有一个占位图
              if (_images.where((img) => img.isShili).isEmpty) {
                _images.add(ImageBean(isShili: true));
              }
              _checkSubmitEnabled();
            });
          }
              : null,
        );
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E88E5), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _isAmountValid ? _submitUtr : null,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _isAmountValid
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// UTR 列表项
class UtrListItem extends StatelessWidget {
  final UtrBean utr;
  final int index;
  final Function(List<String>, int) onImageTap;

  const UtrListItem({
    Key? key,
    required this.utr,
    required this.index,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F6F6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // 图片区域 - 点击显示轮播
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                if (utr.appendixUrls != null && utr.appendixUrls!.isNotEmpty) {
                  // 传入所有图片和当前索引
                  onImageTap(utr.appendixUrls!, 0);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: utr.appendixUrls != null && utr.appendixUrls!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: utr.appendixUrls![0],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
            ),
          ),
          // UTR 和 UPI
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  utr.utrNo ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  utr.upi ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 金额和时间
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormatter.formatCurrency(utr.amount),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  utr.gmtCreate ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 图片上传项
class ImageUploadItem extends StatelessWidget {
  final ImageBean image;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ImageUploadItem({
    Key? key,
    required this.image,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isShili
                  ? const Icon(Icons.add, size: 40, color: Colors.grey)
                  : (image.src != null && image.src!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: image.src!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              )
                  : const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              )),
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}