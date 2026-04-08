import 'package:flutter/material.dart';

class CustomFixedColumnTable extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final List<int> columnWidths;

  const CustomFixedColumnTable({
    Key? key,
    required this.headers,
    required this.data,
    required this.columnWidths,
  }) : super(key: key);

  @override
  State<CustomFixedColumnTable> createState() => _CustomFixedColumnTableState();
}

class _CustomFixedColumnTableState extends State<CustomFixedColumnTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧固定列
        SizedBox(
          width: widget.columnWidths[0].toDouble(),
          child: Column(
            children: [
              _buildFixedHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _verticalController,
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    return _buildFixedCell(widget.data[index]);
                  },
                ),
              ),
            ],
          ),
        ),
        // 右侧可滚动区域
        Expanded(
          child: Column(
            children: [
              _buildScrollableHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ListView.builder(
                    controller: _verticalController,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.data.length,
                    itemBuilder: (context, index) {
                      return _buildScrollableRow(widget.data[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      height: 50,
      color: Colors.grey[200],
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        widget.headers[0],
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFixedCell(Map<String, dynamic> row) {
    return Container(
      height: 45,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        row[widget.headers[0]]?.toString() ?? '',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildScrollableHeader() {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.headers.length - 1, (index) {
            return Container(
              width: widget.columnWidths[index + 1].toDouble(),
              height: 50,
              color: Colors.grey[200],
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.headers[index + 1],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScrollableRow(Map<String, dynamic> row) {
    return Row(
      children: List.generate(widget.headers.length - 1, (index) {
        final header = widget.headers[index + 1];
        return Container(
          width: widget.columnWidths[index + 1].toDouble(),
          height: 45,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Text(
            row[header]?.toString() ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
    );
  }
}