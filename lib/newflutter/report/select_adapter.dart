import 'package:flutter/material.dart';
import 'api_response.dart';

class SelectAdapter extends StatefulWidget {
  final List<ColumnInfo>? data;
  final BuildContext context;
  final Function(ColumnInfo, int, AdapterView)? onItemClickView;
  final Function(ColumnInfo, int)? onItemChanged; // 添加 item 变化回调
  _SelectAdapterState? _state;

  SelectAdapter(this.data, this.context, {Key? key, this.onItemClickView, this.onItemChanged}) : super(key: key);

  @override
  State<SelectAdapter> createState() {
    _state = _SelectAdapterState();
    return _state!;
  }

  void setData(List<ColumnInfo> data) {
    _state?.setData(data);
  }

  List<ColumnInfo> getData() {
    return _state?.getData() ?? [];
  }

  void notifyItemChanged(int position) {
    _state?.notifyItemChanged(position);
  }

  void notifyDataSetChanged() {
    _state?.notifyDataSetChanged();
  }

  void clear() {
    _state?.clear();
  }

  void setItemClickListener(Function(ColumnInfo, int, AdapterView) listener) {
    // Store the listener if needed
  }
}

class _SelectAdapterState extends State<SelectAdapter> {
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

  List<ColumnInfo> getData() {
    return _data;
  }

  /// 通知指定位置的 item 数据已更改
  void notifyItemChanged(int position) {
    if (position >= 0 && position < _data.length) {
      // 方式1：使用 setState 刷新整个列表
      setState(() {});

      // 方式2：如果只刷新单个 item，可以触发 widget 的 onItemChanged 回调
      if (widget.onItemChanged != null && position < _data.length) {
        widget.onItemChanged!(_data[position], position);
      }
    }
  }

  /// 通知所有数据已更改
  void notifyDataSetChanged() {
    setState(() {});
  }

  /// 清空所有选择
  void clear() {
    setState(() {
      for (var item in _data) {
        item.chooseName = null;
      }
    });
  }

  void setItemClickListener(Function(ColumnInfo, int, AdapterView) listener) {
    // Store the listener if needed
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                child: GestureDetector(
                  onTap: () {
                    if (widget.onItemClickView != null) {
                      AdapterView view = AdapterView();
                      widget.onItemClickView!(item, index, view);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.chooseName ?? item.name ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: item.chooseName == null ? Colors.grey : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
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

// Dummy View class for the callback
class AdapterView {
  // Empty class to match the Android View type
}