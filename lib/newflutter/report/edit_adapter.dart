import 'package:flutter/material.dart';
import 'api_response.dart';

class EditAdapter extends StatefulWidget {
  final List<ColumnInfo>? data;
  final BuildContext context;
  _EditAdapterState? _state;

  EditAdapter(this.data, this.context, {Key? key}) : super(key: key);

  @override
  State<EditAdapter> createState() {
    _state = _EditAdapterState();
    return _state!;
  }

  void setData(List<ColumnInfo> data) {
    _state?.setData(data);
  }

  void clear() {
    _state?.clear();
  }

  List<ColumnInfo> getData() {
    return _state?.getData() ?? [];
  }
}

class _EditAdapterState extends State<EditAdapter> {
  List<ColumnInfo> _data = [];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _data = List.from(widget.data!);
    }
  }

  void setData(List<ColumnInfo> data) {
    setState(() {
      _data = data;
    });
  }

  void clear() {
    setState(() {
      _data.clear();
    });
  }

  List<ColumnInfo> getData() {
    return _data;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
        ColumnInfo item = _data[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  item.name ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) {
                    item.chooseName = value;
                  },
                  decoration: InputDecoration(
                    hintText: item.name ?? '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
