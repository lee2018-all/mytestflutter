import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import '../report/report_viewmodel.dart';
import '../report/api_response.dart';
import '../report/edit_adapter.dart';
import '../report/select_adapter.dart';
import 'dart:ui' as ui;

class ReportActivity extends StatefulWidget {
  final String query;
  final String title;

  const ReportActivity({Key? key, required this.query, required this.title})
    : super(key: key);

  @override
  State<ReportActivity> createState() => _ReportActivityState();
}

class _ReportActivityState extends State<ReportActivity>
    with WidgetsBindingObserver {
  late final ReportViewModel _viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Data
  List<ColumnInfo> _editList = [];
  List<ColumnInfo> _selectList = [];
  EditAdapter? _editAdapter;
  SelectAdapter? _selectAdapter;
  String? _dateName;
  bool _isDeal = false;
  bool isshowstart = false;
  int _pageNum = 1;
  int _pageSize = 100;
  Map<String, dynamic> _mapData = {};
  List<Map<String, dynamic>>? _queryList;
  Pages? _pages;
  List<Map<String, dynamic>>? _newList;
  List<String>? _newStringList;
  String? _start;
  String? _end;

  // 列宽存储（基于内容真实计算）
  List<double> _adjustedColumnWidths = [];

  // 屏幕方向相关
  Orientation? _currentOrientation;
  bool _isLandscape = false;
  double _screenWidth = 0;

  // Controllers
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _pageNumberController = TextEditingController();

  // 滚动控制器
  final ScrollController _leftVerticalScrollController = ScrollController();
  final ScrollController _rightVerticalScrollController = ScrollController();
  final ScrollController _rightHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = ReportViewModel();
    _viewModel.setContext(context);
    _setupListeners();
    _getData();
    _setupVerticalScrollSync();
    _updateScreenInfo();
  }

  @override
  void didChangeMetrics() {
    _updateScreenInfo();
    _recalculateColumnWidths();
    if (mounted) setState(() {});
  }

  void _updateScreenInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final mediaQuery = MediaQuery.of(context);
        setState(() {
          _currentOrientation = mediaQuery.orientation;
          _isLandscape = _currentOrientation == Orientation.landscape;
          _screenWidth = mediaQuery.size.width;
        });
      }
    });
  }

  Future<void> _lockOrientation(Orientation orientation) async {
    if (orientation == Orientation.portrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _unlockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _setupVerticalScrollSync() {
    _leftVerticalScrollController.addListener(() {
      if (_leftVerticalScrollController.hasClients &&
          _rightVerticalScrollController.hasClients &&
          (_leftVerticalScrollController.offset -
                      _rightVerticalScrollController.offset)
                  .abs() >
              1.0) {
        _rightVerticalScrollController.jumpTo(
          _leftVerticalScrollController.offset,
        );
      }
    });

    _rightVerticalScrollController.addListener(() {
      if (_rightVerticalScrollController.hasClients &&
          _leftVerticalScrollController.hasClients &&
          (_rightVerticalScrollController.offset -
                      _leftVerticalScrollController.offset)
                  .abs() >
              1.0) {
        _leftVerticalScrollController.jumpTo(
          _rightVerticalScrollController.offset,
        );
      }
    });
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

    _viewModel.res.listen((response) {
      if (response != null) {
        if (response.keyList != null && !_isDeal) {
          _deal(response.keyList!);
        }
      }
    });

    _viewModel.stringMutableLiveData.listen((response) {
      _parseJsonResponse(response);
    });

    _viewModel.refreshStream.listen((refresh) {
      if (refresh) {
        _pageNum = 1;
        _getData();
      }
    });
  }

  void _parseJsonResponse(String response) {
    try {
      Map<String, dynamic> maps = jsonDecode(response);

      if (maps.containsKey('keyList')) {
        List<dynamic> keyListObj = maps['keyList'];
        List<ColumnInfo> columnInfos = keyListObj
            .map((e) => ColumnInfo.fromJson(e))
            .toList();
        _deal(columnInfos);
      }

      if (maps.containsKey('pages')) {
        _dealPages(maps['pages']);
      }

      if (maps.containsKey('columns') && maps.containsKey(widget.query)) {
        List<dynamic> columns = maps['columns'];
        List<String> header = columns.map((e) => e.toString()).toList();
        List<dynamic> reportData = maps[widget.query];
        _processTableData(header, reportData);
      }

      setState(() {});
    } catch (e) {
      print('Error parsing response: $e');
    }
  }

  void _processTableData(List<String> header, List<dynamic> reportData) {
    _queryList = reportData.map((e) => e as Map<String, dynamic>).toList();

    if (_queryList != null && _queryList!.isNotEmpty) {
      _newList = [];
      for (Map<String, dynamic> originalMap in _queryList!) {
        Map<String, dynamic> copiedMap = Map.from(originalMap);
        _newList!.add(copiedMap);
      }
    }

    if (header.isNotEmpty) {
      _newStringList = List.from(header);
      _recalculateColumnWidths();
    }
  }

  // ==================== 核心列宽计算：严格基于内容长度 ====================
  void _recalculateColumnWidths() {
    if (_newStringList == null || _newStringList!.isEmpty) return;
    if (_newList == null) return;

    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // 动态宽度限制
    double maxColumnWidth = isLandscape ? 350 : 1280;
    double minColumnWidth = 80;
    double firstColMax = isLandscape ? 400 : 1280;

    List<double> colWidths = [];

    for (int i = 0; i < _newStringList!.length; i++) {
      String columnName = _newStringList![i];
      double maxContentWidth = 0.0;

      // 1. 计算表头宽度（加粗 14sp + padding 32）
      double headerWidth =
          _calculateTextWidth(columnName, 14, FontWeight.bold) + 32;
      maxContentWidth = headerWidth;

      // 2. 计算该列所有数据的最大宽度
      for (var row in _newList!) {
        String? cellValue = row[columnName]?.toString();
        if (cellValue != null && cellValue.isNotEmpty) {
          double cellWidth =
              _calculateTextWidth(cellValue, 12, FontWeight.normal) + 32;
          if (cellWidth > maxContentWidth) {
            maxContentWidth = cellWidth;
          }
        }
      }

      // 3. 应用最小/最大限制
      if (maxContentWidth < minColumnWidth) maxContentWidth = minColumnWidth;
      if (maxContentWidth > maxColumnWidth) maxContentWidth = maxColumnWidth;

      colWidths.add(maxContentWidth);
    }

    // 4. 特殊处理第一列（固定列）可稍宽
    if (colWidths.isNotEmpty && colWidths[0] > firstColMax) {
      colWidths[0] = firstColMax;
    }

    _adjustedColumnWidths = colWidths;
  }

  double _calculateTextWidth(
    String text,
    double fontSize,
    FontWeight fontWeight,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
      textDirection: ui.TextDirection.ltr,
      textScaleFactor: 1.0, // 固定缩放因子，避免系统字体影响
    )..layout();
    return textPainter.width;
  }

  void _deal(List<ColumnInfo> keyList) {
    if (_isDeal) return;


    _editAdapter = EditAdapter(_editList, context);

    _selectAdapter = SelectAdapter(
      _selectList,
      context,
      onItemClickView: (columnInfo, position, view) {
        // anchorView 参数不需要，直接传空容器
        _showDropdownPopup(
            columnInfo.option?.map((e) => e.value ?? '').toList() ?? [],
            position
        );
      },
    );

    for (ColumnInfo columnInfo in keyList) {
      if (columnInfo.type == 'input') {
        _editList.add(columnInfo);
      } else if (columnInfo.type == 'select' ||
          columnInfo.type == 'select2' ||
          columnInfo.type == 'select3') {
        _selectList.add(columnInfo);
      } else if (columnInfo.type == 'date') {
        if (columnInfo.name != 'startDate' && columnInfo.name != 'endDate') {
          _dateName = columnInfo.name;
        }else{
          isshowstart=true;
        }
      }
    }

    _editAdapter!.setData(_editList);
    _selectAdapter!.setData(_selectList);
    _isDeal = true;
    setState(() {});
  }

  void _getData() {
    _mapData = {};

    if (_start != null &&
        _start!.isNotEmpty &&
        _end != null &&
        _end!.isNotEmpty) {
      _mapData['startDate'] = _start;
      _mapData['endDate'] = _end;
    }

    if (_dateController.text.isNotEmpty && _dateName != null) {
      _mapData[_dateName!] = _dateController.text;
    }

    if (_selectAdapter != null) {
      for (ColumnInfo columnInfo in _selectAdapter!.getData()) {
        if (columnInfo.chooseName != null &&
            columnInfo.chooseName!.isNotEmpty) {
          for (DataOption data in columnInfo.option ?? []) {
            if (data.value == columnInfo.chooseName) {
              _mapData[columnInfo.name!] = data.key;
            }
          }
        }
      }
    }

    if (_editAdapter != null) {
      for (ColumnInfo columnInfo in _editAdapter!.getData()) {
        if (columnInfo.chooseName != null &&
            columnInfo.chooseName!.isNotEmpty) {
          _mapData[columnInfo.name!] = columnInfo.chooseName;
        }
      }
    }

    _mapData['currentPage'] = _pageNum;
    _mapData['pageSize'] = _pageSize;
    _mapData['queryKey'] = widget.query;

    _viewModel.queryPythonv2(_mapData, _pageNum);
  }

  void _dealPages(dynamic pages) {
    try {
      if (pages is Map<String, dynamic>) {
        _pages = Pages.fromJson(pages);
        if (_pages != null && mounted) {
          setState(() {
            _pageNumberController.text = _pages!.currentPage.toString();
          });
        }
      }
    } catch (e) {
      print('Error dealing with pages: $e');
    }
  }

  void _showDropdownPopup(List<String> stringList, int pos) {
    if (!mounted) return;

    if (stringList.isEmpty) {
      EasyLoading.showInfo('暂无选项');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: const Text(
                  '请选择',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: stringList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(stringList[index]),
                      onTap: () {
                        if (_selectAdapter != null && pos < _selectAdapter!.getData().length) {
                          setState(() {
                            _selectAdapter!.getData()[pos].chooseName = stringList[index];
                          });
                          _selectAdapter!.notifyItemChanged(pos);
                        }
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDatePicker(
    TextEditingController controller,
    Function(String) onSelected,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(pickedDate);
      controller.text = formattedDate;
      onSelected(formattedDate);
    }
  }

  void _resetFilters() {
    setState(() {
      _startController.clear();
      _endController.clear();
      _dateController.clear();
      _start = '';
      _end = '';

      if (_selectAdapter != null) {
        for (ColumnInfo columnInfo in _selectAdapter!.getData()) {
          columnInfo.chooseName = '';
        }
        _selectAdapter!.notifyDataSetChanged();
      }
      if (_editAdapter != null) {
        _editAdapter!.clear();
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _pageNum = 1;
    });
    _getData();
    Navigator.pop(context);
  }

  void _goToPreviousPage() {
    if (_pageNum > 1) {
      setState(() {
        _pageNum--;
      });
      _getData();
    }
  }

  void _goToNextPage() {
    if (_pages != null) {
      int maxPage = (_pages!.totalCount! / _pageSize).ceil();
      if (_pageNum < maxPage) {
        setState(() {
          _pageNum++;
        });
        _getData();
      }
    }
  }

  void _goToPage() {
    if (_pageNumberController.text.isNotEmpty) {
      int page = int.tryParse(_pageNumberController.text) ?? 1;
      if (page > 0 && _pages != null) {
        int maxPage = (_pages!.totalCount! / _pageSize).ceil();
        if (page <= maxPage) {
          setState(() {
            _pageNum = page;
          });
          _getData();
        } else {
          EasyLoading.showInfo('Page not found');
        }
      }
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _viewModel.disposeContext();
    _startController.dispose();
    _endController.dispose();
    _dateController.dispose();
    _pageNumberController.dispose();
    _leftVerticalScrollController.dispose();
    _rightVerticalScrollController.dispose();
    _rightHorizontalScrollController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _unlockOrientation();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final screenWidth = mediaQuery.size.width;
    final isLandscape = orientation == Orientation.landscape;

    if (_isLandscape != isLandscape) {
      _isLandscape = isLandscape;
      _recalculateColumnWidths();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: Icon(
              isLandscape ? Icons.screen_rotation : Icons.screen_rotation_alt,
              color: Colors.white,
            ),
            onPressed: () {
              if (isLandscape) {
                _lockOrientation(Orientation.portrait);
              } else {
                _lockOrientation(Orientation.landscape);
              }
            },
            tooltip: isLandscape ? '切换到竖屏' : '切换到横屏',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPaginationControls(),
          const SizedBox(height: 8),
          Expanded(
            child:
                _newList != null &&
                    _newList!.isNotEmpty &&
                    _newStringList != null &&
                    _newStringList!.isNotEmpty &&
                    _adjustedColumnWidths.isNotEmpty
                ? _buildFixedColumnTable(isLandscape, screenWidth)
                : const Center(child: Text('No data available')),
          ),
        ],
      ),
      endDrawer: _buildFilterDrawer(),
    );
  }

  // ==================== 固定第一列表格 ====================
  Widget _buildFixedColumnTable(bool isLandscape, double screenWidth) {
    if (_newList == null ||
        _newList!.isEmpty ||
        _newStringList == null ||
        _newStringList!.isEmpty ||
        _adjustedColumnWidths.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final firstColumn = _newStringList![0];
    final otherColumns = _newStringList!.skip(1).toList();

    double firstWidth = _adjustedColumnWidths[0];
    List<double> otherWidths = [];
    if (_adjustedColumnWidths.length > 1) {
      otherWidths = _adjustedColumnWidths.sublist(1);
    }

    double rightTotalWidth = otherWidths.fold(0.0, (sum, width) => sum + width);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧固定列
        Container(
          width: firstWidth,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                color: Colors.grey[200],
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  firstColumn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _leftVerticalScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _leftVerticalScrollController,
                    shrinkWrap: true,
                    itemCount: _newList!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 45,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          _newList![index][firstColumn]?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // 右侧可滚动区域
        Expanded(
          child: Scrollbar(
            controller: _rightHorizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _rightHorizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: rightTotalWidth > 0 ? rightTotalWidth : screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      color: Colors.grey[200],
                      child: Row(
                        children: List.generate(otherColumns.length, (index) {
                          double width = index < otherWidths.length
                              ? otherWidths[index]
                              : 100.0;
                          return Container(
                            width: width,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              otherColumns[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 15 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        controller: _rightVerticalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _rightVerticalScrollController,
                          child: Column(
                            children: _newList!.map((row) {
                              return Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: List.generate(otherColumns.length, (
                                    index,
                                  ) {
                                    double width = index < otherWidths.length
                                        ? otherWidths[index]
                                        : 100.0;
                                    final key = otherColumns[index];
                                    return Container(
                                      width: width,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        row[key]?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: isLandscape ? 13 : 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 分页控件 ====================
  Widget _buildPaginationControls() {
    int maxPage = _pages != null ? (_pages!.totalCount! / _pageSize).ceil() : 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: Colors.grey[50],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _pageNum > 1 ? Colors.blue : Colors.grey,
            ),
            onPressed: _pageNum > 1 ? _goToPreviousPage : null,
            constraints: const BoxConstraints(minWidth: 40),
            padding: EdgeInsets.zero,
          ),
          Container(
            width: 60,
            height: 32,
            child: TextField(
              controller: _pageNumberController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Page',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                isDense: true,
              ),
              onSubmitted: (value) => _goToPage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(' / $maxPage'),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _pageNum < maxPage ? Colors.blue : Colors.grey,
            ),
            onPressed: _pageNum < maxPage ? _goToNextPage : null,
            constraints: const BoxConstraints(minWidth: 40),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _goToPage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(50, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Go', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== 筛选抽屉 ====================
  Widget _buildFilterDrawer() {
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isshowstart) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startController,
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              readOnly: true,
                              onTap: () =>
                                  _showDatePicker(_startController, (value) {
                                    _start = value;
                                  }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _endController,
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              readOnly: true,
                              onTap: () =>
                                  _showDatePicker(_endController, (value) {
                                    _end = value;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_dateName != null) ...[
                      TextField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: _dateName,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        readOnly: true,
                        onTap: () =>
                            _showDatePicker(_dateController, (value) {}),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // editAdapter 上下无间隙
                    if (_editAdapter != null)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 10),
                        child: _editAdapter,
                      ),

                    // selectAdapter 与上面的 editAdapter 之间无间隙，但与其他有间隙
                    if (_selectAdapter != null) ...[
                      if (_editAdapter != null)
                        const SizedBox(height: 0), // 紧贴，无间隙
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: _selectAdapter,
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetFilters,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
