import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/detail/util/FileUtil.dart';
import 'package:mytestflutter/newflutter/utr/utr_page.dart';
import 'dart:convert';

import '../color/color_viewmodel.dart';
import '../color/item_model.dart';
import '../followup/followup_page.dart';
import 'CouponDialog.dart';
import 'DraggableFloatingView.dart';
import 'EventBus.dart';
import 'contact/contact_fragment.dart';
import 'followrecord/FollowRecordFragment.dart';
import 'home/HomeFragment.dart';
import 'OperationBottomSheet.dart';

class DetailPage extends StatefulWidget {
  final String? loanId;
  final String? userCode;
  final ItemModel? bean;
  final int? isPaid;
  final int? selectedStatus;

  const DetailPage({
    Key? key,
    this.loanId,
    this.userCode,
    this.bean,
    this.isPaid,
    this.selectedStatus,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  // ViewModel
  late final ColorViewModel _viewModel;

  // State
  ItemModel? _item;
  int _isPaid = 0;
  bool _isFragmentChanging = false;
  String _currentFragmentTag = 'HomeFragment';

  // Fragment cache
  final Map<String, Widget> _fragmentCache = {};

  // Fragment tags
  static const String TAG_HOME = 'HomeFragment';
  static const String TAG_CONTACT = 'ContactFragment';
  static const String TAG_FOLLOW_RECORD = 'FollowRecordFragment';

  // Animation controllers for fragment transitions
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 浮窗控制器
  late DraggableFloatingView _floatingView;

  @override
  void initState() {
    super.initState();
    _viewModel = ColorViewModel();

    // 初始化数据
    _item = widget.bean;
    _isPaid = widget.isPaid ?? 0;

    // 初始化动画
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // 初始化Fragment缓存
    _initFragmentCache();

    // 设置事件监听
    _setupEventListeners();

    // 设置ViewModel监听
    _setupViewModelListeners();

    // 初始化浮窗
    _initFloatingView();

    // 显示浮窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFloat();
      // 播放淡入动画
      _fadeController.forward();
    });
  }

  void _initFloatingView() {
    _floatingView = DraggableFloatingView(
      onTap: _goToFollowUp,
      size: 60,
      snapToEdge: true,
      edgeMargin: 0,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/genzong.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _setupEventListeners() {
    // 监听操作事件
    eventBus.on<PositionEvent>().listen((event) {
      _handleOperationEvent(event);
    });
  }

  void _setupViewModelListeners() {
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

    _viewModel.appLinkData.listen((appLinkData) {

        FileUtil.openUrl(appLinkData);

    });

    _viewModel.repayLinkData.listen((repayLinkData) {

        FileUtil.openUrl(repayLinkData);

    });
  }

  void _handleOperationEvent(PositionEvent event) {
    int position = event.position;
    if (_item == null) return;

    switch (position) {
      case 0: // Deduction
        break;
      case 1: // App Link
        _viewModel.getAppLink(_item!.tradeNo ?? '');
        break;
      case 2: // Repay Links
        _viewModel.getRepaymentLink(_item!.collectionNo ?? '');
        break;
      case 3: // UTR
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UtrPage(
              loanId: _item!.tradeNo ?? '',
              userCode: _item!.userCode ?? '',
            ),
          ),
        );
        break;
      case 4: // Extension / Extension Rollback
        break;
      case 5: // Issue Coupons
        _showCouponDialog();
        break;
      case 6: // Close
        break;
    }
  }

  void _showLinkDialog(String title, String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(context);
              EasyLoading.showSuccess('Copied to clipboard');
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => CouponDialog(
        onConfirm: () {
          Navigator.pop(context);
          _viewModel.issueCoupon(_item!.tradeNo ?? '');
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showOperationBottomSheet() {
    if (_item == null) return;

    List<String> menuItems = [];
    menuItems.addAll(['Deduction', 'App Link', 'Repay Links', 'UTR']);

    if (_isPaid == 0) {
      menuItems.addAll(['Extension', 'Issue Coupons', 'Close']);
    } else {
      if (_item?.extension == true) {
        menuItems.add('Extension Rollback');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OperationBottomSheet(
        menuItems: menuItems,
        onItemSelected: (index) {
          _handleOperationEvent(PositionEvent(position: index));
        },
      ),
    );
  }

  void _goToFollowUp() {
    if (_item == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FollowupPage(bean: _item)),
    );
  }

  void _initFragmentCache() {
    // 检查必要参数
    if (widget.loanId == null || widget.userCode == null) {
      print('Error: loanId or userCode is null');
      return;
    }

    // 准备参数，包含 bean 对象
    Map<String, dynamic> args = {
      'loanId': widget.loanId,
      'userCode': widget.userCode,
      'bean': _item,
      'isPaid': _isPaid,
    };

    // 初始化各个 Fragment
    _fragmentCache[TAG_HOME] = HomeFragment(args: args);
    _fragmentCache[TAG_CONTACT] = ContactFragment(args: args);
    _fragmentCache[TAG_FOLLOW_RECORD] = FollowRecordFragment(args: args);
  }

  void _switchToFragment(String fragmentTag) {
    // 检查缓存是否存在
    if (!_fragmentCache.containsKey(fragmentTag)) {
      print('Error: Fragment $fragmentTag not found in cache');
      return;
    }

    // 如果目标Fragment就是当前显示的Fragment，直接返回
    if (fragmentTag == _currentFragmentTag) return;

    // 防止快速连续点击
    if (_isFragmentChanging) return;

    setState(() {
      _isFragmentChanging = true;
      _currentFragmentTag = fragmentTag;
    });

    // 启动淡入淡出动画
    _fadeController.forward(from: 0.0);

    // 重置切换标志
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isFragmentChanging = false;
        });
      }
    });
  }

  void _showFloat() {
    // 显示浮窗的逻辑
  }

  void _hideFloat() {
    // 隐藏浮窗的逻辑
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildTabBar(),
                      Expanded(child: _buildFragmentContainer()),
                    ],
                  ),
                  // 只有在 HomeFragment 时才显示浮窗按钮
                  if (_currentFragmentTag == TAG_HOME) _buildFloatingButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 48,
      color: const Color(0xFF1E88E5),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Detail',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showOperationBottomSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Operation',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildTabButton(
            text: 'Basic-Info',
            isSelected: _currentFragmentTag == TAG_HOME,
            onTap: () => _switchToFragment(TAG_HOME),
          ),
          _buildTabButton(
            text: 'Contact',
            isSelected: _currentFragmentTag == TAG_CONTACT,
            onTap: () => _switchToFragment(TAG_CONTACT),
          ),
          _buildTabButton(
            text: 'Follow Up Record',
            isSelected: _currentFragmentTag == TAG_FOLLOW_RECORD,
            onTap: () => _switchToFragment(TAG_FOLLOW_RECORD),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF262626),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFragmentContainer() {
    // 检查缓存是否为空
    if (_fragmentCache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 检查当前Fragment是否存在
    if (!_fragmentCache.containsKey(_currentFragmentTag)) {
      return const Center(child: Text('Fragment not found'));
    }

    // 使用淡入淡出动画切换Fragment
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _fragmentCache[_currentFragmentTag]!,
    );
  }

  Widget _buildFloatingButton() {
    return _floatingView;
  }
}

// 扩展方法，用于设置Fragment参数
extension FragmentExtension on StatefulWidget {
  void setArguments(Map<String, dynamic> args) {
    // 这里可以通过构造函数传递参数
  }
}
