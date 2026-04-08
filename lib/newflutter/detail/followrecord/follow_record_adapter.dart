import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../util/FileUtil.dart';
import 'follow_record_model.dart';

class FollowRecordAdapter extends StatefulWidget {
  final List<FollowlistBean> data;
  final Function(FollowlistBean) onItemClick;

  const FollowRecordAdapter({
    Key? key,
    required this.data,
    required this.onItemClick,
  }) : super(key: key);

  @override
  State<FollowRecordAdapter> createState() => _FollowRecordAdapterState();
}

class _FollowRecordAdapterState extends State<FollowRecordAdapter> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final bean = widget.data[index];
        return FollowRecordItem(
          bean: bean,
          onTap: () => widget.onItemClick(bean),
        );
      },
    );
  }
}

class FollowRecordItem extends StatefulWidget {
  final FollowlistBean bean;
  final VoidCallback onTap;

  const FollowRecordItem({
    Key? key,
    required this.bean,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FollowRecordItem> createState() => _FollowRecordItemState();
}

class _FollowRecordItemState extends State<FollowRecordItem> {
  bool _isExpanded = false;
  bool _showDetailsButton = false;
  late ExpandableTextController _textController;

  @override
  void initState() {
    super.initState();
    _textController = ExpandableTextController();
    _checkTextLength();
  }

  void _checkTextLength() {
    // 如果文本长度超过90个字符，显示详情按钮
    final content = widget.bean.content ?? '';
    if (content.length > 90) {
      setState(() {
        _showDetailsButton = true;
      });
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    _textController.toggle();
  }

  String _formatMobile(String? mobile) {
    if (mobile == null || mobile.isEmpty) return '';
    String formatted = mobile.replaceAll('00910', '').replaceAll('+91', '');
    if (formatted.length > 9) {
      return formatted.substring(0, formatted.length - 7) +
          '****' +
          formatted.substring(formatted.length - 3);
    }
    return formatted;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 主卡片内容
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：手机号 + 日期
                Row(
                  children: [
                    // 手机号
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // 复制手机号
                          String mobile = _formatMobile(widget.bean.mobile);
                          FileUtil.copyToClipboard(context, mobile);
                          EasyLoading.showSuccess('Copied to clipboard');
                        },
                        child: Text(
                          _formatMobile(widget.bean.mobile),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF409EFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 复制按钮
                    if (widget.bean.mobile != null && widget.bean.mobile!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          String mobile = _formatMobile(widget.bean.mobile);
                          FileUtil.copyToClipboard(context, mobile);
                          EasyLoading.showSuccess('Copied to clipboard');
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    const Spacer(),
                    // 日期
                    Text(
                      widget.bean.gmtCreate ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 第二行：姓名 + 操作人
                Row(
                  children: [
                    // 姓名
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // 复制姓名
                          FileUtil.copyToClipboard(context, widget.bean.name ?? '');
                          EasyLoading.showSuccess('Copied to clipboard');
                        },
                        child: Text(
                          widget.bean.name ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF262626),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 复制按钮
                    if (widget.bean.name != null && widget.bean.name!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          FileUtil.copyToClipboard(context, widget.bean.name ?? '');
                          EasyLoading.showSuccess('Copied to clipboard');
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    const Spacer(),
                    // 操作人
                    Text(
                      widget.bean.followUp ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 通话结果（带背景）
                if (widget.bean.callingResult != null && widget.bean.callingResult!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.bean.callingResult!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // 备注内容（可展开）
                if (widget.bean.content != null && widget.bean.content!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpandableText(
                        text: widget.bean.content!,
                        controller: _textController,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      if (_showDetailsButton)
                        GestureDetector(
                          onTap: _toggleExpand,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _isExpanded ? 'Collapse' : 'Details',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0077FF),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // 右上角关系标签
          if (widget.bean.relation != null && widget.bean.relation!.isNotEmpty)
            Positioned(
              top: -8,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRelationColor(widget.bean.relation),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.bean.relation!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRelationColor(String? relation) {
    switch (relation) {
      case 'Self':
        return const Color(0xFF1E88E5);
      case 'Family':
        return Colors.green;
      case 'Friend':
        return Colors.orange;
      case 'Colleague':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// 可展开文本控制器
class ExpandableTextController {
  bool _isExpanded = false;
  final List<VoidCallback> _listeners = [];

  bool get isExpanded => _isExpanded;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void toggle() {
    _isExpanded = !_isExpanded;
    for (var listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

/// 可展开文本组件
class ExpandableText extends StatefulWidget {
  final String text;
  final ExpandableTextController controller;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.controller,
    this.maxLines = 2,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onExpandChanged);
  }

  void _onExpandChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExpandChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: widget.style,
      maxLines: widget.controller.isExpanded ? null : widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}