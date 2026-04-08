import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../color/item_model.dart';
import '../EventBus.dart';
import 'FollowRecordItem.dart';
import 'follow_record_model.dart';
import 'follow_record_viewmodel.dart';

class FollowRecordFragment extends StatefulWidget {
  final Map<String, dynamic> args;

  const FollowRecordFragment({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<FollowRecordFragment> createState() => _FollowRecordFragmentState();
}

class _FollowRecordFragmentState extends State<FollowRecordFragment> {
  late final FollowRecordViewModel _viewModel;

  // Data
  ItemModel? _item;
  List<FollowlistBean> _records = [];

  // State
  bool _isLoading = true;
  int _pageNum = 1;
  int _pageSize = 10;
  bool _canLoadMore = false;

  // Refresh Controller
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = FollowRecordViewModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setContext(context);
    });

    _loadData();
    _setupListeners();
    _setupEventBus();
  }

  void _loadData() {
    // 获取Item数据 - 从 args 中获取
    if (widget.args.containsKey('bean') && widget.args['bean'] != null) {
      _item = widget.args['bean'] as ItemModel;
      print('FollowRecordFragment - Item loaded: tradeNo=${_item?.tradeNo}');
    } else {
      print('FollowRecordFragment - No bean found in args');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 获取跟进记录
    if (_item != null && _item!.tradeNo != null && _item!.tradeNo!.isNotEmpty) {
      print('FollowRecordFragment - Calling getFollowList with tradeNo=${_item!.tradeNo}');
      _viewModel.getFollowList(_item!.tradeNo!, _pageNum, _pageSize);
    } else {
      print('FollowRecordFragment - tradeNo is null or empty');
      setState(() {
        _isLoading = false;
      });
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
        print('FollowRecordFragment - Error: $error');
        EasyLoading.showError(error);
        setState(() {
          _isLoading = false;
        });
      }
    });

    _viewModel.followList.listen((data) {
      if (mounted) {
        print('FollowRecordFragment - Data received, records count: ${data.phoneRecordList?.length}');
        setState(() {
          if (_pageNum == 1) {
            _records = data.phoneRecordList ?? [];
          } else {
            _records.addAll(data.phoneRecordList ?? []);
          }

          // 判断是否还有更多数据
          _canLoadMore = (data.phoneRecordList?.length ?? 0) >= _pageSize;

          _isLoading = false;
        });

        // 完成刷新/加载
        if (_pageNum == 1) {
          _refreshController.refreshCompleted();
        } else {
          if (_canLoadMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        }
      }
    });
  }

  void _setupEventBus() {
    // 监听消息事件
    eventBus.on<MessageEvent>().listen((event) {
      if (mounted) {
        print('FollowRecordFragment - Received MessageEvent, refreshing data');
        _pageNum = 1;
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        if (_item != null && _item!.tradeNo != null) {
          _viewModel.getFollowList(_item!.tradeNo!, _pageNum, _pageSize);
        }
      }
    });
  }

  void _onRefresh() async {
    print('FollowRecordFragment - onRefresh called');
    _pageNum = 1;
    if (_item != null && _item!.tradeNo != null) {
      _viewModel.getFollowList(_item!.tradeNo!, _pageNum, _pageSize);
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    print('FollowRecordFragment - onLoading called, canLoadMore=$_canLoadMore');
    if (_canLoadMore) {
      _pageNum++;
      if (_item != null && _item!.tradeNo != null) {
        _viewModel.getFollowList(_item!.tradeNo!, _pageNum, _pageSize);
      } else {
        _refreshController.loadComplete();
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    _viewModel.disposeContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No follow-up records',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: _canLoadMore,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: const ClassicHeader(
        idleText: 'Pull down to refresh',
        refreshingText: 'Refreshing...',
        completeText: 'Refresh completed',
        failedText: 'Refresh failed',
      ),
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        loadingText: 'Loading more...',
        noDataText: 'No more data',
        canLoadingText: 'Pull up to load more',
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final bean = _records[index];
          return FollowRecordItem(
            bean: bean,
            onTap: () {
              print('Tap record: ${bean.name}');
            },
          );
        },
      ),
    );
  }
}

class MessageEvent {
}