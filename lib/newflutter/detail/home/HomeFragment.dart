import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/detail/util/AESUtil.dart';
import 'package:mytestflutter/newflutter/detail/util/FileUtil.dart';
import 'package:mytestflutter/newflutter/detail/util/ImageBannerUtil.dart';
import 'package:mytestflutter/newflutter/detail/util/NumberFormatter.dart';
import 'package:mytestflutter/newflutter/detail/util/copyable_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import '../../color/item_model.dart';
import 'BaseInfoModel.dart';
import 'HomeViewModel.dart';
import 'image_banner_widget.dart';
import 'info_row_widget.dart';

class HomeFragment extends StatefulWidget {
  final Map<String, dynamic> args;

  const HomeFragment({Key? key, required this.args}) : super(key: key);

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment>
    with TickerProviderStateMixin {
  late final HomeViewModel _viewModel;

  // Data
  ItemModel? _item;
  BaseInfoModel? _baseInfo;
  UserUrlInfoModel? _userUrlInfo;
  String? _ocrPhotoUrl;

  // State
  bool _isLoading = true;
  bool _isDetailExpanded = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Animation
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();

    // 初始化动画
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setContext(context);
    });

    _loadData();
    _setupListeners();
  }

  void _loadData() {
    final loanId = widget.args['loanId'] ?? '';
    final userCode = widget.args['userCode'] ?? '';

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // 获取Item数据
    if (widget.args['bean'] != null) {
      _item = widget.args['bean'] as ItemModel?;
    }

    // 从API获取数据
    _viewModel.getBaseInfo(loanId);
    _viewModel.getUserUrlInfo(userCode);
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
        setState(() {
          _hasError = true;
          _errorMessage = error;
          _isLoading = false;
        });
        EasyLoading.showError(error);
      }
    });

    _viewModel.baseInfo.listen((data) {
      if (mounted) {
        print('BaseInfo received, items count: ${data.list.length}');
        setState(() {
          _baseInfo = data;
        });
      }
    });

    _viewModel.userUrlInfo.listen((data) {
      if (mounted) {
        print(
          'UserUrlInfo received: aadhaarBack=${data.aadhaarCardBackUrl != null}',
        );
        setState(() {
          _userUrlInfo = data;
        });

        // 获取到 userUrlInfo 后，再获取 OCR URL
        final userCode = widget.args['userCode'] ?? '';
        if (userCode.isNotEmpty) {
          _viewModel.getOcrUrlInfo(userCode);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });

    _viewModel.ocrUrlInfo.listen((data) {
      if (mounted) {
        print('OcrUrlInfo received: ocrPhotoUrl=${data.ocrPhotoUrl}');
        setState(() {
          _ocrPhotoUrl = data.ocrPhotoUrl;
          _isLoading = false;
        });
      }
    });

    _viewModel.linkData.listen((data) {
      final url = data['url'] as String;
      final isCopy = data['isCopy'] as bool;
      EasyLoading.showSuccess(url);
      if (isCopy) {
        FileUtil.copyToClipboard(context, url);
        EasyLoading.showSuccess('Link copied to clipboard');
      } else {
        _openUrl(url);
      }

    });
  }

  void _openUrl(String url) {
    // 打开链接
    // 可以使用url_launcher包
     launchUrl(Uri.parse(url));
  }

  void _flipArrow() {
    if (_isDetailExpanded) {
      _arrowController.reverse();
    } else {
      _arrowController.forward();
    }
    setState(() {
      _isDetailExpanded = !_isDetailExpanded;
    });
  }

  void _showBigImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      EasyLoading.showInfo('No image available');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
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
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    if (imageUrl.isEmpty) {
      EasyLoading.showInfo('No image available');
      return;
    }

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

  void _openWhatsApp(String phone) {
    // 实现 WhatsApp 打开逻辑
  }

  String _formatMobile(String mobile) {
    if (mobile.isEmpty) return '';
    if (mobile.length > 9) {
      return mobile.substring(0, mobile.length - 7) +
          '****' +
          mobile.substring(mobile.length - 3);
    }
    return mobile;
  }

  String _decryptMobile(String encrypted) {
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

  @override
  void dispose() {
    _arrowController.dispose();
    _viewModel.dispose();
    _viewModel.disposeContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 显示错误状态
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 检查数据是否完整
    if (_item == null) {
      return const Center(child: Text('No data available'));
    }

    final collectionDetail =
        _item!.collectionOrderDetailVoList?.isNotEmpty == true
        ? _item!.collectionOrderDetailVoList![0]
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 应用信息卡片
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          // 贷款信息卡片
          _buildLoanInfoCard(collectionDetail),
          const SizedBox(height: 16),
          // 照片信息卡片
          _buildPhotoInfoCard(),
          const SizedBox(height: 16),
          // 详细信息卡片（可展开）
          _buildDetailInfoCard(collectionDetail),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 应用信息卡片
  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: _item?.ocrPhotoUrl ?? '',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 16),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 应用名称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CopyableText(
                      text: _item?.originAppName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                    ),
                    if (_item?.appName != null && _item!.appName!.isNotEmpty)
                      CopyableText(
                        text: _item!.appName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF262626),
                        ),
                      ),
                  ],
                ),
              ),
              // App Link
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _viewModel.getAppLink(_item!.tradeNo ?? '', false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'APP Link',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () =>
                        _viewModel.getAppLink(_item!.tradeNo ?? '', true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _viewModel.getRepaymentLink(
                  _item!.collectionNo ?? '',
                  false,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Repay Link',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _viewModel.getRepaymentLink(
                  _item!.collectionNo ?? '',
                  true,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 贷款信息卡片
  Widget _buildLoanInfoCard(dynamic collectionDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Loan ID
          InfoRow(
            label: 'LoanID',
            value: _item?.tradeNo ?? '',
            isCopyable: true,
            valueColor: const Color(0xFF409EFF),
          ),
          const Divider(height: 16),

          // Payment Amount (如果有扩展则不显示)
          if (_item?.isExtend != 1) ...[
            InfoRow(
              label: 'Payment Amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.paymentAmount ?? 0,
              ),
            ),
            const Divider(height: 16),
            // Payment Day
            InfoRow(
              label: 'Payment Day',
              value:
                  collectionDetail?.paymentDate != null &&
                      collectionDetail!.paymentDate!.length > 10
                  ? collectionDetail.paymentDate!.substring(0, 10)
                  : '',
            ),
            const Divider(height: 16),
          ],

          // Billing Day
          InfoRow(
            label: 'Billing Day',
            value:
                collectionDetail?.repaymentDate?.replaceAll('00:00:00', '') ??
                '',
          ),
          const Divider(height: 16),

          // Total Amount Should Repay
          InfoRow(
            label: 'Total Amount Should Repay',
            value: NumberFormatter.formatWithCommaTwoDecimal(
              collectionDetail?.totalAmountShouldRepay ?? 0,
            ),
          ),
          const Divider(height: 16),

          // Overdue Days
          InfoRow(
            label: 'Overdue Days',
            value: '${_item?.overdueDays ?? 0} days',
          ),
          const Divider(height: 16),

          // Name
          InfoRow(label: 'Name', value: _baseInfo?.getValue('Name') ?? ''),
          const Divider(height: 16),

          // Mobile
          InfoRow(
            label: 'Mobile',
            value: _formatMobile(
              _decryptMobile(_baseInfo?.getValue('Mobile') ?? ''),
            ),
            isCopyable: true,
            valueColor: const Color(0xFF409EFF),
            onCopy: () {
              String mobile = _decryptMobile(
                _baseInfo?.getValue('Mobile') ?? '',
              );
              FileUtil.copyToClipboard(context, mobile);
            },
          ),
          const Divider(height: 16),

          // WhatsApp
          InfoRow(
            label: 'WhatsApp',
            value: _formatMobile(
              _decryptMobile(_baseInfo?.getValue('WhatsApp') ?? ''),
            ),
            isCopyable: true,
            valueColor: const Color(0xFF409EFF),
            onCopy: () {
              String whatsapp = _decryptMobile(
                _baseInfo?.getValue('WhatsApp') ?? '',
              );
              FileUtil.copyToClipboard(context, whatsapp);
            },
            onTap: () {
              String whatsapp = _decryptMobile(
                _baseInfo?.getValue('WhatsApp') ?? '',
              );
              _openWhatsApp(whatsapp);
            },
          ),
          const Divider(height: 16),

          // Account No
          InfoRow(
            label: 'AccountNo',
            value: _baseInfo?.getValue('BankNo') ?? '',
          ),
          const Divider(height: 16),

          // Sex
          InfoRow(label: 'Sex', value: _baseInfo?.getValue('Sex') ?? ''),
          const SizedBox(height: 16),

          // Download buttons
          Row(
            children: [
              Expanded(
                child: _buildDownloadButton(
                  label: 'PanImage',
                  onTap: () => _downloadImage(_userUrlInfo?.panCardFrontUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDownloadButton(
                  label: 'AadhaarFrontImage',
                  onTap: () =>
                      _downloadImage(_userUrlInfo?.aadhaarCardFrontUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDownloadButton(
                  label: 'LivingImage',
                  onTap: () => _downloadImage(_ocrPhotoUrl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            const Icon(Icons.download, color: Colors.white, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _downloadImage(String? url) {
    if (url == null || url.isEmpty) {
      EasyLoading.showInfo('No image available');
      return;
    }
    _showImageDialog(url);
  }

  // 照片信息卡片
  Widget _buildPhotoInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Photo Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF262626),
                ),
              ),
              // 调试按钮：显示图片数量
              GestureDetector(
                onTap: () {
                  int count = 0;
                  if (_userUrlInfo?.aadhaarCardBackUrl?.isNotEmpty == true)
                    count++;
                  if (_userUrlInfo?.aadhaarCardFrontUrl?.isNotEmpty == true)
                    count++;
                  if (_userUrlInfo?.panCardFrontUrl?.isNotEmpty == true)
                    count++;
                  if (_ocrPhotoUrl?.isNotEmpty == true) count++;
                  EasyLoading.showInfo('Images count: $count');
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Refresh', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 150, child: _buildImageBanner()),
        ],
      ),
    );
  }

  Widget _buildImageBanner() {
    List<String> images = [];

    // 按照Android代码的顺序添加图片
    // 1. 先添加 Aadhaar 背面
    if (_userUrlInfo?.aadhaarCardBackUrl != null &&
        _userUrlInfo!.aadhaarCardBackUrl!.isNotEmpty) {
      images.add(_userUrlInfo!.aadhaarCardBackUrl!);
    }

    // 2. 添加 Aadhaar 正面
    if (_userUrlInfo?.aadhaarCardFrontUrl != null &&
        _userUrlInfo!.aadhaarCardFrontUrl!.isNotEmpty) {
      images.add(_userUrlInfo!.aadhaarCardFrontUrl!);
    }

    // 3. 添加 PAN 卡正面
    if (_userUrlInfo?.panCardFrontUrl != null &&
        _userUrlInfo!.panCardFrontUrl!.isNotEmpty) {
      images.add(_userUrlInfo!.panCardFrontUrl!);
    }

    // 4. 最后添加 OCR 照片
    if (_ocrPhotoUrl != null && _ocrPhotoUrl!.isNotEmpty) {
      images.add(_ocrPhotoUrl!);
    }

    print('ImageBanner - images count: ${images.length}');
    for (int i = 0; i < images.length; i++) {
      print('ImageBanner - image $i: ${images[i]}');
    }

    if (images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Text('No images available')),
      );
    }

    return ImageBannerWidget(
      images: images,
      onImageTap: (index, imageUrl) {
        print('Image tapped: index=$index, url=$imageUrl');
        _showImageDialog(imageUrl);
      },
    );
  }

  // 详细信息卡片
  Widget _buildDetailInfoCard(dynamic collectionDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题
          GestureDetector(
            onTap: _flipArrow,
            child: Row(
              children: [
                const Text(
                  'Detail',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF262626),
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _arrowAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _arrowAnimation.value,
                      child: const Icon(Icons.arrow_drop_down, size: 24),
                    );
                  },
                ),
              ],
            ),
          ),

          // 详细信息
          if (_isDetailExpanded) ...[
            const Divider(height: 24),

            // Principal + Interest + Penalty
            InfoRow(
              label: 'Principal + Interest + Penalty',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                _addNumbers(
                  collectionDetail?.realCapital ?? 0,
                  collectionDetail?.interest ?? 0,
                  collectionDetail?.lateFee ?? 0,
                ),
              ),
            ),
            const Divider(height: 16),

            // Total Amount
            InfoRow(
              label: 'Total Amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.totalAmountShouldRepay ?? 0,
              ),
            ),
            const Divider(height: 16),

            // Paid Amount
            InfoRow(
              label: 'Paid Amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.paidAmount ?? 0,
              ),
            ),
            const Divider(height: 16),

            // Deduct Amount
            InfoRow(
              label: 'Deduct Amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.deductAmount ?? 0,
              ),
            ),
            const Divider(height: 16),

            // Actually Repayment Date
            InfoRow(
              label: 'Actually Repayment Date',
              value: collectionDetail?.actualRepaymentDate ?? '',
            ),
            const Divider(height: 16),

            // Email
            InfoRow(
              label: 'Email',
              value: _baseInfo?.getValue('Email') ?? '',
              isCopyable: true,
              valueColor: const Color(0xFF409EFF),
              onCopy: () {
                FileUtil.copyToClipboard(
                  context,
                  _baseInfo?.getValue('Email') ?? '',
                );
              },
            ),
            const Divider(height: 16),

            // PAN
            InfoRow(label: 'PAN', value: _baseInfo?.getValue('PAN') ?? ''),
            const Divider(height: 16),

            // AadhaarNo
            InfoRow(
              label: 'AadhaarNo',
              value: _baseInfo?.getValue('AadhaarNo') ?? '',
            ),
            const Divider(height: 16),

            // Aadhaar Back Image
            InfoRow(
              label: 'Aadhaar Back Image',
              value: 'AadhaarBackImage',
              valueColor: const Color(0xFF409EFF),
              onTap: () =>
                  _showBigImage(_userUrlInfo?.aadhaarCardBackUrl ?? ''),
            ),
            const Divider(height: 16),

            // Province
            InfoRow(
              label: 'Province',
              value: _baseInfo?.getValue('Province') ?? '',
            ),
            const Divider(height: 16),

            // City
            InfoRow(label: 'City', value: _baseInfo?.getValue('City') ?? ''),
            const Divider(height: 16),

            // Address
            InfoRow(
              label: 'Address',
              value: _baseInfo?.getValue('Address') ?? '',
            ),
            const Divider(height: 16),

            // Pincode
            InfoRow(
              label: 'Pincode',
              value: _baseInfo?.getValue('PinCode') ?? '',
            ),
            const Divider(height: 16),

            // CompanyName
            InfoRow(
              label: 'CompanyName',
              value: _baseInfo?.getValue('CompanyName') ?? '',
            ),
            const Divider(height: 16),

            // Age
            InfoRow(label: 'Age', value: _baseInfo?.getValue('age') ?? ''),
            const Divider(height: 16),

            // mobile_1
            InfoRow(
              label: 'mobile_1',
              value: _formatMobile(
                _decryptMobile(_baseInfo?.getValue('mobile_1') ?? ''),
              ),
              isCopyable: true,
              valueColor: const Color(0xFF409EFF),
              onCopy: () {
                String mobile = _decryptMobile(
                  _baseInfo?.getValue('mobile_1') ?? '',
                );
                if (mobile.isNotEmpty && mobile != '-') {
                  FileUtil.copyToClipboard(context, mobile);
                }
              },
            ),
            const Divider(height: 16),

            // mobile_2
            InfoRow(
              label: 'mobile_2',
              value: _formatMobile(
                _decryptMobile(_baseInfo?.getValue('mobile_2') ?? ''),
              ),
              isCopyable: true,
              valueColor: const Color(0xFF409EFF),
              onCopy: () {
                String mobile = _decryptMobile(
                  _baseInfo?.getValue('mobile_2') ?? '',
                );
                if (mobile.isNotEmpty && mobile != '-') {
                  FileUtil.copyToClipboard(context, mobile);
                }
              },
            ),
            const Divider(height: 16),

            // Birthday
            InfoRow(
              label: 'Birthday',
              value: _baseInfo?.getValue('Birthday') ?? '',
            ),
            const Divider(height: 16),

            // Marriage
            InfoRow(
              label: 'Marriage',
              value: _baseInfo?.getValue('Marriage') ?? '',
            ),
            const Divider(height: 16),

            // Education
            InfoRow(
              label: 'Education',
              value: _baseInfo?.getValue('Education') ?? '',
            ),
          ],
        ],
      ),
    );
  }

  double _addNumbers(double a, double b, double c) {
    return a + b + c;
  }
}
