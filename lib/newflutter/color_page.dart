import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mytestflutter/newflutter/extension/ExtensionPage.dart';
import 'package:mytestflutter/newflutter/sp_utils.dart';
import 'package:mytestflutter/newflutter/utr/utr_page.dart';

import 'color/color_picker_dialog.dart';
import 'color/color_viewmodel.dart';
import 'color/db_helper.dart';
import 'color/config_model.dart';
import 'color/filter_grid_view.dart';
import 'color/item_model.dart';
import 'detail/DetailPage.dart';
import 'detail/util/FileUtil.dart';
import 'extension/DeductionPage.dart';
import 'followup/followup_page.dart';

class ColorPage extends StatefulWidget {
  const ColorPage({super.key});

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State variables
  int _pageNum = 1;
  int _totalCount = 0;
  bool _canLoadMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isChooseColor = false;
  int _colorPos = -1;
  int _selectedStatus = -1; // -1: all, 0: doing, 1: completed
  int _selectedNewStatus = -1;
  int _selectedSortType = -1; // -1: none, 0: amount, 1: overdueDays
  String _selectedOverdueTime = '';
  String _selectedCollectionStatus = '';
  String _tradeNo = '';
  String _mobile = '';
  int _operationPos = -1;

  // Lists
  List<ItemModel> _items = [];
  List<String> _selectedColorList = [];
  List<ConfigOverdueTimeDTO> _overdueTimeList = [];
  List<ConfigCollectionStatusDTO> _collectionStatusList = [];

  // 颜色缓存，避免重复查询数据库
  final Map<String, List<TypeBean>> _colorCache = {};

  // Colors
  final List<Color> _colors = const [
    Color(0xFFF4F4F4), // 0 - 灰色
    Color(0xFFEBF4FF), // 1 - 浅蓝色
    Color(0xFFFAF2FF), // 2 - 浅紫色
    Color(0xFFF2FFF1), // 3 - 浅绿色
    Color(0xFFFFFCF0), // 4 - 浅黄色
    Color(0xFFFFEFF2), // 5 - 浅粉色
    Color(0xFFF6F6F6), // 6 - 浅灰色（清除颜色）
  ];

  final List<Color> _borderColors = const [
    Color(0xFFFF4040), // 0 - 红色边框
    Color(0xFF409EFF), // 1 - 蓝色边框
    Color(0xFFB948FA), // 2 - 紫色边框
    Color(0xFF48D040), // 3 - 绿色边框
    Color(0xFFFFD91B), // 4 - 黄色边框
    Color(0xFFFF7990), // 5 - 粉色边框
    Color(0xFF262626), // 6 - 黑色边框（清除颜色）
  ];

  // Services
  final SpUtils _spUtils = SpUtils();
  final DbHelper _dbHelper = DbHelper();
  late final ColorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ColorViewModel();
    _initData();
    _setupListeners();
    _initFilter();

    // 添加滚动监听，实现上拉加载更多
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setContext(context);
    });
  }

  // 滚动监听方法
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50 &&
        !_isLoading &&
        !_isLoadingMore &&
        _canLoadMore) {
      _loadMore();
    }
  }

  Future<void> _initData() async {
    await _loadConfig();
    await _refreshData();
  }

  void _setupListeners() {
    _viewModel.pageData.listen((data) {
      if (data != null) {
        _loadData(data.itemList ?? []);
      }
    });

    _viewModel.totalCount.listen((count) {
      setState(() {
        _totalCount = count;
      });
    });

    _viewModel.appLinkData.listen((appLinkData) {
      FileUtil.openUrl(appLinkData);
    });

    _viewModel.repayLinkData.listen((repayLinkData) {
      FileUtil.openUrl(repayLinkData);
    });

    _viewModel.configData.listen((config) {
      if (config != null) {
        setState(() {
          _overdueTimeList = config.overdueTime ?? [];
          _collectionStatusList = config.collectionStatus ?? [];
        });
      }
    });

    _viewModel.loading.listen((loading) {
      setState(() {
        _isLoading = loading;
        if (!loading) {
          _isLoadingMore = false;
        }
      });
      if (loading) {
        EasyLoading.show();
      } else {
        EasyLoading.dismiss();
      }
    });

    _viewModel.error.listen((error) {
      if (error.isNotEmpty) {
        EasyLoading.showError(error);
      }
    });
  }

  Future<void> _loadConfig() async {
    await _viewModel.getConfig();
  }

  Future<void> _refreshData() async {
    setState(() {
      _pageNum = 1;
      _isLoading = true;
      _canLoadMore = true;
    });

    // 刷新时清除缓存，确保重新加载最新的颜色
    String userId = await _spUtils.getString('userID');
    if (userId.isNotEmpty) {
      _colorCache.remove(userId);
    }

    await _fetchData();
  }

  Future<void> _loadMore() async {
    if (!_canLoadMore || _isLoading || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _pageNum++;
    });

    await _fetchData();
  }

  Future<void> _fetchData() async {
    String workTaskStatus = '';
    if (_selectedStatus == 0) {
      workTaskStatus = 'doing';
    } else if (_selectedStatus == 1) {
      workTaskStatus = 'completed';
    }

    String sortType = '';
    int sort = -1;
    if (_selectedSortType == 0) {
      sort = 2;
      sortType = 'amount';
    } else if (_selectedSortType == 1) {
      sort = 1;
      sortType = 'overdueDays';
    }

    // 筛选颜色模式：如果没有选中的颜色，直接返回空
    if (_isChooseColor && _selectedColorList.isEmpty) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _totalCount = 0;
        _items.clear();
      });
      return;
    }

    await _viewModel.getList(
      pageNum: _pageNum,
      isNewAdd: _selectedNewStatus,
      overdueTime: _selectedOverdueTime,
      workTaskStatus: workTaskStatus,
      tradeNo: _tradeNo,
      mobile: _mobile,
      sortType: sortType,
      sort: sort,
      collectionStatus: _selectedCollectionStatus,
      selectedColors: _selectedColorList,
      isChooseColor: _isChooseColor,
    );
  }

  // 修复 _loadData - 异步加载颜色
  Future<void> _loadData(List<ItemModel> newItems) async {
    // 先应用颜色（异步）
    if (_colorPos != -1 && _colorPos != 6) {
      // 全选颜色模式（非清除）- 为所有项目应用选中的颜色
      for (var item in newItems) {
        item.color = _colors[_colorPos];
        item.borderColor = _borderColors[_colorPos];
      }
    } else {
      // 普通模式或筛选模式 - 从数据库加载保存的颜色
      await _applySavedColors(newItems);
    }

    // 颜色应用完成后，再更新 UI
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;

      if (_pageNum == 1) {
        _items = newItems;
      } else {
        _items.addAll(newItems);
      }
      _canLoadMore = newItems.length >= 30;
    });
  }

  // 从数据库加载保存的颜色（带缓存）
  Future<void> _applySavedColors(List<ItemModel> items) async {
    String userId = await _spUtils.getString('userID');
    if (userId.isEmpty) return;

    // 使用缓存避免重复查询数据库
    List<TypeBean>? savedColors = _colorCache[userId];
    if (savedColors == null) {
      savedColors = await _dbHelper.getUserList(userId);
      _colorCache[userId] = savedColors;
    }

    // 创建映射表提高查找效率
    final colorMap = <String, int>{};
    for (var bean in savedColors) {
      colorMap[bean.tradeno] = bean.img;
    }

    // 应用颜色
    for (var item in items) {
      final colorIndex = colorMap[item.collectionNo];
      if (colorIndex != null) {
        if (colorIndex == 6) {
          item.color = Colors.transparent;
          item.borderColor = Colors.transparent;
        } else {
          item.color = _colors[colorIndex];
          item.borderColor = _borderColors[colorIndex];
        }
      } else {
        // 没有保存的颜色，使用默认透明
        item.color = Colors.transparent;
        item.borderColor = Colors.transparent;
      }
    }
  }

  // 保存颜色到数据库
  Future<void> _saveColorToDb(String tradeNo, int colorIndex) async {
    String userId = await _spUtils.getString('userID');
    if (userId.isEmpty) return;

    List<TypeBean> existing = await _dbHelper.getUserList(userId);

    bool exists = false;
    for (var bean in existing) {
      if (bean.tradeno == tradeNo) {
        await _dbHelper.update(tradeNo, userId, colorIndex);
        exists = true;
        break;
      }
    }

    if (!exists) {
      await _dbHelper.add(tradeNo, userId, colorIndex);
    }

    // 清除缓存，确保下次刷新时重新加载
    _colorCache.remove(userId);
  }

  // 从数据库删除颜色
  Future<void> _deleteColorFromDb(String tradeNo) async {
    String userId = await _spUtils.getString('userID');
    if (userId.isEmpty) return;

    await _dbHelper.deleteByTradeNo(tradeNo);
    _colorCache.remove(userId);
  }

  // 标记单个项目颜色
  void _markItemColor(int position, int colorIndex) {
    final item = _items[position];
    final tradeNo = item.collectionNo.toString();

    setState(() {
      if (colorIndex == 6) {
        item.color = Colors.transparent;
        item.borderColor = Colors.transparent;
      } else {
        item.color = _colors[colorIndex];
        item.borderColor = _borderColors[colorIndex];
      }
    });

    // 异步保存到数据库
    if (colorIndex == 6) {
      _deleteColorFromDb(tradeNo);
    } else {
      _saveColorToDb(tradeNo, colorIndex);
    }
  }

  // 重置单个颜色
  Future<void> _resetSingleColor(int position) async {
    final item = _items[position];
    final tradeNo = item.collectionNo.toString();

    setState(() {
      item.color = Colors.transparent;
      item.borderColor = Colors.transparent;
    });
    await _deleteColorFromDb(tradeNo);
  }

  // 重置所有颜色
  Future<void> _resetAllColors() async {
    setState(() {
      for (var item in _items) {
        item.color = Colors.transparent;
        item.borderColor = Colors.transparent;
      }
    });
    String userId = await _spUtils.getString('userID');
    if (userId.isNotEmpty) {
      await _dbHelper.deleteByUserCode(userId);
      _colorCache.remove(userId);
    }
  }

  // 处理全选颜色
  void _handleAllColorSelection(int colorIndex) {
    if (colorIndex == 6) {
      // 清除颜色模式
      setState(() {
        _isChooseColor = false;
        _colorPos = -1;
        _selectedColorList.clear();
      });
      _refreshData();
    } else {
      setState(() {
        _isChooseColor = true;
        _colorPos = colorIndex;
      });
      _loadColoredItems(colorIndex);
    }
  }

  // 加载指定颜色的项目
  Future<void> _loadColoredItems(int colorIndex) async {
    String userId = await _spUtils.getString('userID');
    if (userId.isEmpty) return;

    List<TypeBean> coloredItems = await _dbHelper.getUserAndColorList(userId, colorIndex);

    setState(() {
      _selectedColorList = coloredItems.map((e) => e.tradeno).toList();
    });

    if (_selectedColorList.isNotEmpty) {
      await _refreshData();
    } else {
      setState(() {
        _totalCount = 0;
        _items.clear();
      });
    }
  }

  void _showImageDialog(String imageUrl) {
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
                imageUrl: FileUtil.getSafeImageUrl(imageUrl),
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
                        Icon(Icons.error_outline, color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Text('Failed to load image', style: TextStyle(color: Colors.white)),
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

  void _showColorPicker({int? position}) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        isForAll: position == null,
        colors: _colors,
        borderColors: _borderColors,
        onColorSelected: (colorIndex) {
          if (position != null) {
            _markItemColor(position, colorIndex);
          } else {
            _handleAllColorSelection(colorIndex);
          }
        },
      ),
    );
  }

  void _showBottomMenu(int position) {
    ItemModel item = _items[position];
    bool isDoing = _selectedStatus == 0;
    bool hasExtension = item.extension ?? false;

    List<String> menuItems;
    if (isDoing) {
      menuItems = [
        'Deduction',
        'App Link',
        'Repay Links',
        'UTR',
        'Extension',
        'Issue Coupons',
        'Close',
        'Color Reset',
        'All Color Reset',
      ];
    } else {
      if (hasExtension) {
        menuItems = [
          'Deduction',
          'App Link',
          'Repay Links',
          'UTR',
          'Extension Rollback',
          'Color Reset',
          'All Color Reset',
        ];
      } else {
        menuItems = [
          'Deduction',
          'App Link',
          'Repay Links',
          'UTR',
          'Color Reset',
          'All Color Reset',
        ];
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BottomSheetMenu(
        menuItems: menuItems,
        onItemSelected: (index) => _handleMenuSelection(index, item, position),
      ),
    );
  }

  void _handleMenuSelection(int index, ItemModel item, int position) {
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (index) {
        case 0:
          _handleQuickAction(position, 'deduction');
          break;
        case 1:
          _viewModel.getAppLink(item.tradeNo ?? '');
          break;
        case 2:
          _viewModel.getRepaymentLink(item.collectionNo ?? '');
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UtrPage(loanId: item.tradeNo, userCode: item.userCode ?? ''),
            ),
          );
          break;
        case 4:
          if (_selectedStatus == 0) {
            _handleQuickAction(position, 'extension');
          } else {
            _showColorResetDialog(position, isAll: false);
          }
          break;
        case 5:
          if (_selectedStatus == 0) {
            _showCouponDialog(item.tradeNo ?? '');
          } else {
            _showColorResetDialog(position, isAll: true);
          }
          break;
        case 6:
          break;
        case 7:
          _showColorResetDialog(position, isAll: false);
          break;
        case 8:
          _showColorResetDialog(position, isAll: true);
          break;
      }
    });
  }

  void _handleQuickAction(int index, String action) {
    ItemModel item = _items[index];

    switch (action) {
      case 'deduction':
        EasyLoading.showSuccess('Deduction');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeductionPage(loanId: item.tradeNo ?? ''),
          ),
        );
        break;
      case 'extension':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExtensionPage(
              loanId: item.tradeNo,
              collectionNo: item.collectionNo ?? '',
              bean: item,
              sel1: _selectedStatus,
            ),
          ),
        );
        break;
      case 'reset':
        _showColorResetDialog(index, isAll: false);
        break;
      case 'more':
        _showBottomMenu(index);
        break;
    }
  }

  void _showCouponDialog(String tradeNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure to issue coupons?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              EasyLoading.show();
              _viewModel.issueCoupon(tradeNo);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showColorResetDialog(int position, {required bool isAll}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          isAll
              ? 'Are you sure to reset the color of all orders?'
              : 'Are you sure to reset the color of this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isAll) {
                await _resetAllColors();
              } else {
                await _resetSingleColor(position);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _initFilter() {}

  void _applyFilter() {
    setState(() {
      _pageNum = 1;
    });
    _fetchData();
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _selectedStatus = -1;
      _selectedNewStatus = -1;
      _selectedSortType = -1;
      _selectedOverdueTime = '';
      _selectedCollectionStatus = '';
      _tradeNo = '';
      _mobile = '';
      _searchController.clear();

      for (var item in _overdueTimeList) {
        item.isChoose = false;
      }
      for (var item in _collectionStatusList) {
        item.isChoose = false;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    _viewModel.disposeContext();
    _colorCache.clear(); // 清理缓存
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: _buildBody(),
      endDrawer: _buildFilterDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(48 + MediaQuery.of(context).padding.top),
      child: Container(
        color: const Color(0xFF1E88E5),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            const SizedBox(width: 15),
            _buildColorSelector(),
            const SizedBox(width: 10),
            Text(
              'Total: $_totalCount',
              style: const TextStyle(color: Color(0xFF262626), fontSize: 14),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return GestureDetector(
      onTap: () => _showColorPicker(),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _colorPos == -1 ? Colors.grey[400] : _borderColors[_colorPos],
                shape: BoxShape.circle,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 15, color: Color(0xFF262626)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeaderRow(),
        Expanded(child: _buildRefreshList()),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 62,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: const Center(
              child: Text(
                'Photo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF262626)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: const Center(
              child: Text(
                'Amount\nDPD\nN/R',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF262626)),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: const Center(
              child: Text(
                'LoanID\nMobile\nName',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF262626)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _buildLoadMoreIndicator();
          }
          return _buildSlidableListItem(_items[index], index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    if (!_canLoadMore && _items.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text('No more data', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSlidableListItem(ItemModel item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        key: Key(item.tradeNo ?? index.toString()),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[400]!, Colors.blue[700]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FollowupPage(bean: item)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.follow_the_signs, color: Colors.white, size: 28),
                        SizedBox(height: 4),
                        Text('Follow up', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[500]!, Colors.grey[700]!],
                  ),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showBottomMenu(index),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.more_horiz, color: Colors.white, size: 28),
                        SizedBox(height: 4),
                        Text('More', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        child: _buildItemContent(item, index),
      ),
    );
  }

  void _navigateToDetail(ItemModel item, int index) {
    setState(() {
      _operationPos = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          loanId: item.tradeNo,
          userCode: item.userCode,
          bean: item,
          isPaid: _selectedStatus,
          selectedStatus: _selectedStatus,
        ),
      ),
    );
  }

  // ==================== 列表项UI ====================
  Widget _buildItemContent(ItemModel item, int index) {
    return GestureDetector(
      onTap: () {
        _operationPos = index;
        _navigateToDetail(item, index);
      },
      onLongPress: () => _showColorPicker(position: index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: item.borderColor != null && item.borderColor != Colors.transparent ? item.borderColor! : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _getItemBackgroundColor(item, index),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: Center(child: _buildPhotoPlaceholder(item.ocrPhotoUrl)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${_formatAmount(_getTotalAmount(item))}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF409EFF)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.overdueDays ?? 0}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getOverdueColor(item.overdueDays ?? 0)),
                    ),
                    const SizedBox(height: 4),
                    _buildNRELabels(item),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRowWithCopy(text: item.tradeNo ?? '', onCopy: () => FileUtil.copyToClipboard(context, item.tradeNo ?? '')),
                      const SizedBox(height: 6),
                      _buildInfoRowWithCopy(
                        text: _formatMobile(FileUtil.decryptMobile(item.mobile ?? '')),
                        onCopy: () => FileUtil.copyToClipboard(context, item.mobile ?? ''),
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRowWithCopy(text: item.name ?? '', onCopy: () => FileUtil.copyToClipboard(context, item.name ?? '')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getItemBackgroundColor(ItemModel item, int index) {
    if (item.color != null && item.color != Colors.transparent) return item.color!;
    return index % 2 == 0 ? const Color(0xFFF6F6F6) : Colors.white;
  }

  double _getTotalAmount(ItemModel item) {
    if (item.collectionOrderDetailVoList != null && item.collectionOrderDetailVoList!.isNotEmpty) {
      return item.collectionOrderDetailVoList![0].totalAmountShouldRepay ?? 0;
    }
    return item.expireAmount ?? 0;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String _formatMobile(String mobile) {
    if (mobile.isEmpty) return '';
    if (mobile.length > 8) {
      return mobile.substring(0, mobile.length - 7) + '****' + mobile.substring(mobile.length - 3);
    }
    return mobile;
  }

  Widget _buildInfoRowWithCopy({required String text, required VoidCallback onCopy}) {
    return Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF606060)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 4),
        GestureDetector(onTap: onCopy, child: const Icon(Icons.copy, size: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildNRELabels(ItemModel item) {
    bool showN = item.borrowType == 1;
    bool showR = item.borrowType != 1;
    bool showE = item.isExtend == 1;

    if (!showN && !showR && !showE) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showN)
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(color: _getLabelColor('N'), borderRadius: BorderRadius.circular(4)),
            child: const Center(child: Text('N', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        if (showR) ...[
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(color: _getLabelColor('R'), borderRadius: BorderRadius.circular(4)),
            child: const Center(child: Text('R', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ],
        if (showE) ...[
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(color: _getLabelColor('E'), borderRadius: BorderRadius.circular(4)),
            child: const Center(child: Text('E', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ],
      ],
    );
  }

  Color _getOverdueColor(int days) {
    if (days < 0) return const Color(0xFFFF4040);
    if (days == 0) return const Color(0xFFFFA500);
    return const Color(0xFFFF4040);
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'N':
        return const Color(0xFFFF4040);
      case 'R':
        return const Color(0xFFFFA500);
      case 'E':
        return const Color(0xFF48D040);
      default:
        return Colors.grey;
    }
  }

  Widget _buildPhotoPlaceholder(String? imageUrl) {
    return GestureDetector(
      onTap: () {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          _showImageDialog(imageUrl);
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: FileUtil.getSafeImageUrl(imageUrl),
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
          )
              : const Icon(Icons.person, color: Colors.grey),
        ),
      ),
    );
  }

  // ==================== 筛选抽屉 ====================
  Widget _buildFilterDrawer() {
    return Drawer(
      width: 300,
      elevation: 16,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusFilter(),
                    const SizedBox(height: 15),
                    _buildNewStatusFilter(),
                    const SizedBox(height: 20),
                    _buildSearchInput(),
                    const SizedBox(height: 15),
                    _buildCollectionStatusGrid(),
                    const SizedBox(height: 15),
                    _buildSortOptions(),
                  ],
                ),
              ),
            ),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Row(
      children: [
        Expanded(child: _FilterButton(text: 'Unpaid', isSelected: _selectedStatus == 0, onTap: () => setState(() => _selectedStatus = 0))),
        const SizedBox(width: 15),
        Expanded(child: _FilterButton(text: 'Paid', isSelected: _selectedStatus == 1, onTap: () => setState(() => _selectedStatus = 1))),
      ],
    );
  }

  Widget _buildNewStatusFilter() {
    return Row(
      children: [
        Expanded(
          child: _FilterButton(
            text: 'New',
            isSelected: _selectedNewStatus == 0,
            onTap: () => setState(() => _selectedNewStatus = _selectedNewStatus == 0 ? -1 : 0),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _FilterButton(
            text: 'Repeat',
            isSelected: _selectedNewStatus == 1,
            onTap: () => setState(() => _selectedNewStatus = _selectedNewStatus == 1 ? -1 : 1),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Loan ID/Mobile',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      onChanged: (value) {
        if (value.contains('TD')) {
          _tradeNo = value;
          _mobile = '';
        } else {
          _mobile = value;
          _tradeNo = '';
        }
      },
    );
  }

  Widget _buildCollectionStatusGrid() {
    return FilterGridView(
      items: _collectionStatusList.map((e) => e.value ?? '').toList(),
      selectedIndex: _collectionStatusList.indexWhere((e) => e.isChoose),
      onItemSelected: (index) {
        setState(() {
          for (var item in _collectionStatusList) item.isChoose = false;
          if (index >= 0 && index < _collectionStatusList.length) {
            _collectionStatusList[index].isChoose = true;
            _selectedCollectionStatus = _collectionStatusList[index].value ?? '';
          } else {
            _selectedCollectionStatus = '';
          }
        });
      },
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildSortOption(text: 'Amount: high-low', isSelected: _selectedSortType == 0, onTap: () => setState(() => _selectedSortType = 0)),
          const SizedBox(height: 8),
          _buildSortOption(text: 'Overdue: low-high', isSelected: _selectedSortType == 1, onTap: () => setState(() => _selectedSortType = 1)),
        ],
      ),
    );
  }

  Widget _buildSortOption({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.blue : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _resetFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet Menu
class BottomSheetMenu extends StatelessWidget {
  final List<String> menuItems;
  final Function(int) onItemSelected;

  const BottomSheetMenu({super.key, required this.menuItems, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Operation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(menuItems[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(index);
                      },
                    ),
                    if (index < menuItems.length - 1) const Divider(height: 1, indent: 20, endIndent: 20),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// Filter Button Widget
class _FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }
}