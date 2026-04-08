import 'package:flutter/material.dart';

class HeadAdapter extends StatefulWidget {
  final List<String> headers;
  final BuildContext context;
  final List<int>? lengthlist;
  final ScrollController? scrollController;

  const HeadAdapter(
      this.headers,
      this.context, {
        Key? key,
        this.lengthlist,
        this.scrollController,
      }) : super(key: key);

  @override
  State<HeadAdapter> createState() => _HeadAdapterState();
}

class _HeadAdapterState extends State<HeadAdapter> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.headers.length, (index) {
          double width = 100;
          if (widget.lengthlist != null && index < widget.lengthlist!.length) {
            width = widget.lengthlist![index].toDouble();
          }
          return Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              widget.headers[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ),
    );
  }
}