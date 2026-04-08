import 'package:flutter/material.dart';

class HorizontalTableAdapter extends StatefulWidget {
  final BuildContext context;
  final List<String>? headers;
  final List<Map<String, dynamic>>? data;
  final List<int>? lengthlist;
  final ScrollController? scrollController;

  const HorizontalTableAdapter(
      this.context, {
        Key? key,
        this.headers,
        this.data,
        this.lengthlist,
        this.scrollController,
      }) : super(key: key);

  @override
  State<HorizontalTableAdapter> createState() => _HorizontalTableAdapterState();
}

class _HorizontalTableAdapterState extends State<HorizontalTableAdapter> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || widget.data!.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.data!.length, (rowIndex) {
            final row = widget.data![rowIndex];
            return Row(
              children: List.generate(widget.headers?.length ?? row.length, (colIndex) {
                final key = widget.headers != null && colIndex < widget.headers!.length
                    ? widget.headers![colIndex]
                    : 'col$colIndex';
                final value = row[key]?.toString() ?? '';

                double width = 100;
                if (widget.lengthlist != null && colIndex < widget.lengthlist!.length) {
                  width = widget.lengthlist![colIndex].toDouble();
                }

                return Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}