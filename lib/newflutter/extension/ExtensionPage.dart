import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

import '../color/item_model.dart';
import '../detail/util/FileUtil.dart';
import '../detail/util/NumberFormatter.dart';
import '../detail/util/AESUtil.dart';
import '../utr/utr_viewmodel.dart';

class ExtensionPage extends StatefulWidget {
  final String? loanId;
  final String? collectionNo;
  final ItemModel? bean;
  final int? sel1; // 0: Extension, 1: Extension Rollback

  const ExtensionPage({
    Key? key,
    this.loanId,
    this.collectionNo,
    this.bean,
    this.sel1,
  }) : super(key: key);

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> with TickerProviderStateMixin {
  late final UtrViewModel _viewModel;

  // State
  bool _isExpanded = false;
  bool _isLoading = false;

  // Animation
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  // Data
  ItemModel? _item;
  String? _decryptedMobile;

  @override
  void initState() {
    super.initState();
    _viewModel = UtrViewModel();
    _viewModel.setContext(context);

    // 初始化动画
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _loadData();
    _setupListeners();
  }

  void _loadData() {
    _item = widget.bean;

    // 解密手机号
    if (_item?.mobile != null) {
      String decrypted = AESUtil.decryptWithFallback(_item!.mobile!);
      _decryptedMobile = decrypted.replaceAll('00910', '').replaceAll('+91', '');
    }
  }

  void _setupListeners() {
    _viewModel.loading.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
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

    _viewModel.result.listen((success) {
      if (success && mounted) {
        EasyLoading.showSuccess(
            widget.sel1 == 0 ? 'Extension successful' : 'Extension rollback successful'
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    });
  }

  void _flipArrow() {
    if (_isExpanded) {
      _arrowController.reverse();
    } else {
      _arrowController.forward();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onConfirm() {
    if (widget.sel1 == 0) {
      // Extension
      if (widget.loanId != null) {
        _viewModel.payExtension(widget.loanId!);
      }
    } else {
      // Extension Rollback
      if (widget.collectionNo != null) {
        _viewModel.payExtensionBack(widget.collectionNo!);
      }
    }
  }

  String _formatMobile(String mobile) {
    if (mobile.isEmpty) return '';
    if (mobile.length > 8) {
      return mobile.substring(0, mobile.length - 7) + '****' + mobile.substring(mobile.length - 3);
    }
    return mobile;
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
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final collectionDetail = _item!.collectionOrderDetailVoList?.isNotEmpty == true
        ? _item!.collectionOrderDetailVoList![0]
        : null;

    String title = widget.sel1 == 0 ? 'Extension' : 'Extension Rollback';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(title),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 应用信息卡片
                  _buildAppInfoCard(),
                  const SizedBox(height: 16),
                  // 贷款信息卡片
                  _buildLoanInfoCard(collectionDetail),
                  const SizedBox(height: 16),
                  // 还款金额卡片（可展开）
                  _buildRepaymentCard(collectionDetail),
                ],
              ),
            ),
          ),
          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
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

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
                _buildCopyableText(
                  text: _item?.originAppName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                _buildCopyableText(
                  text: _item?.appName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF262626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableText({
    required String text,
    required TextStyle style,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            FileUtil.copyToClipboard(context, text);
          },
          child: const Icon(
            Icons.copy,
            size: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

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
          _buildInfoRowWithCopy(
            label: 'LoanID',
            value: collectionDetail?.tradeNo ?? '',
            valueColor: const Color(0xFF409EFF),
          ),
          const Divider(height: 16),
          // Billing Day
          _buildInfoRow(
            label: 'Billing day',
            value: collectionDetail?.repaymentDate?.replaceAll('00:00:00', '') ?? '',
          ),
          const Divider(height: 16),
          // Name
          _buildInfoRowWithCopy(
            label: 'Name',
            value: _item?.name ?? '',
            valueColor: const Color(0xFF409EFF),
          ),
          const Divider(height: 16),
          // Mobile
          _buildInfoRowWithCopy(
            label: 'Mobile',
            value: _formatMobile(_decryptedMobile ?? ''),
            valueColor: const Color(0xFF409EFF),
            onCopy: () {
              FileUtil.copyToClipboard(context, _decryptedMobile ?? '');
            },
          ),
          const Divider(height: 16),
          // Overdue Days
          _buildInfoRow(
            label: 'Overdue Days',
            value: '${_item?.overdueDays ?? 0} days',
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentCard(dynamic collectionDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 可展开标题
          GestureDetector(
            onTap: _flipArrow,
            child: Row(
              children: [
                const Text(
                  'Total Repayment Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF262626),
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormatter.formatWithCommaTwoDecimal(
                    collectionDetail?.totalAmountShouldRepay ?? 0,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4040),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _arrowAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _arrowAnimation.value,
                      child: const Icon(
                        Icons.arrow_drop_up,
                        size: 24,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 展开的详细信息
          if (_isExpanded) ...[
            const Divider(height: 24),
            // Principal + Interest + Penalty
            _buildInfoRow(
              label: 'Principal+Interest+Penalty',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                _addNumbers(
                  collectionDetail?.realCapital ?? 0,
                  collectionDetail?.interest ?? 0,
                  collectionDetail?.lateFee ?? 0,
                ),
              ),
            ),
            const Divider(height: 16),
            // Total amount
            _buildInfoRow(
              label: 'Total amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.totalAmountShouldRepay ?? 0,
              ),
            ),
            const Divider(height: 16),
            // Paid amount
            _buildInfoRow(
              label: 'Paid amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.paidAmount ?? 0,
              ),
            ),
            const Divider(height: 16),
            // Deductible amount
            _buildInfoRow(
              label: 'Deductible amount',
              value: NumberFormatter.formatWithCommaTwoDecimal(
                collectionDetail?.deductAmount ?? 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF262626),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithCopy({
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? const Color(0xFF262626),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onCopy ?? () {
                  FileUtil.copyToClipboard(context, value);
                },
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
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
                  border: Border.all(
                    color: const Color(0xFF1E88E5),
                    width: 1,
                  ),
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
              onTap: _onConfirm,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
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
      ),
    );
  }

  double _addNumbers(double a, double b, double c) {
    return a + b + c;
  }
}