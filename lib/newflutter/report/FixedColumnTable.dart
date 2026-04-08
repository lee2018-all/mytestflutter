import 'package:flutter/material.dart';

class FixedColumnTable extends StatelessWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final List<int>? columnWidths;
  final int fixedColumnCount;
  final double rowHeight;

  const FixedColumnTable({
    Key? key,
    required this.headers,
    required this.data,
    this.columnWidths,
    this.fixedColumnCount = 1,
    this.rowHeight = 45.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final fixedHeaders = headers.take(fixedColumnCount).toList();
    final scrollableHeaders = headers.skip(fixedColumnCount).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧固定列
            _buildFixedColumn(fixedHeaders),

            // 右侧可滚动区域
            Expanded(
              child: _buildScrollableArea(scrollableHeaders),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFixedColumn(List<String> fixedHeaders) {
    return SizedBox(
      width: _calculateFixedWidth(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 固定列表头
          _buildHeaderRow(fixedHeaders, isFixed: true),

          // 固定列数据 - 使用 ListView.builder 优化性能
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _buildDataRow(fixedHeaders, data[index], isFixed: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableArea(List<String> scrollableHeaders) {
    // 使用 ValueNotifier 来同步滚动位置
    final scrollController = ScrollController();

    return Column(
      children: [
        // 可滚动表头
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: _buildHeaderRow(scrollableHeaders, isFixed: false),
        ),

        // 可滚动数据 - 使用 ListView.builder 优化性能
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Column(
              children: List.generate(data.length, (index) {
                return _buildDataRow(scrollableHeaders, data[index], isFixed: false);
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(List<String> headers, {required bool isFixed}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          right: isFixed ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
        ),
      ),
      child: Row(
        children: List.generate(headers.length, (index) {
          final width = _getColumnWidth(index, isFixed);
          return SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                headers[index],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDataRow(List<String> headers, Map<String, dynamic> row, {required bool isFixed}) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          right: isFixed ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
        ),
      ),
      child: Row(
        children: List.generate(headers.length, (index) {
          final key = headers[index];
          final value = row[key]?.toString() ?? '';
          final width = _getColumnWidth(index, isFixed);
          return SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ),
    );
  }

  double _getColumnWidth(int index, bool isFixed) {
    int globalIndex = index;
    if (!isFixed) {
      globalIndex = fixedColumnCount + index;
    }

    if (columnWidths != null && globalIndex < columnWidths!.length) {
      return columnWidths![globalIndex].toDouble();
    }
    return 120.0;
  }

  double _calculateFixedWidth() {
    double total = 0;
    for (int i = 0; i < fixedColumnCount; i++) {
      if (columnWidths != null && i < columnWidths!.length) {
        total += columnWidths![i];
      } else {
        total += 120;
      }
    }
    return total;
  }
}