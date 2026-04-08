import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/detail/util/AESUtil.dart';
import 'dart:math';

import '../../color/item_model.dart';
import '../../followup/followup_page.dart';
import 'contact_info_model.dart';
import 'contact_viewmodel.dart';

class ContactFragment extends StatefulWidget {
  final Map<String, dynamic> args;

  const ContactFragment({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<ContactFragment> createState() => _ContactFragmentState();
}

class _ContactFragmentState extends State<ContactFragment> with TickerProviderStateMixin {
  late final ContactViewModel _viewModel;

  // Data
  ItemModel? _item;
  ContactInfoModel? _contactInfo;
  ContactInfoModel? _contactInfoZi;

  // State
  bool _isLoading = true;
  bool _isExpand = false;
  bool _isGetChild = false;

  // Animation
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = ContactViewModel();

    // 初始化动画
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setContext(context);
    });
    _loadData();
    _setupListeners();
  }

  void _loadData() {
    // 从参数获取 Item
    if (widget.args['bean'] != null) {
      _item = widget.args['bean'] as ItemModel;
    }

    // 获取联系信息
    if (_item != null && _item!.tradeNo != null && _item!.tradeNo!.isNotEmpty) {
      _viewModel.getContactsList(_item!.tradeNo!);
    }
  }

  void _setupListeners() {
    _viewModel.loading.listen((loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
        });
      }
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

    _viewModel.contactInfo.listen((data) {
      if (mounted) {
        setState(() {
          _contactInfo = data;
          _isLoading = false;
        });
      }
    });

    _viewModel.contactInfoZi.listen((data) {
      if (mounted) {
        setState(() {
          _contactInfoZi = data;
          _isGetChild = true;
        });
      }
    });
  }

  void _flipArrow() {
    if (_isExpand) {
      _arrowController.reverse();
    } else {
      _arrowController.forward();
    }
    setState(() {
      _isExpand = !_isExpand;
    });
  }

  void _onContactTap(ContactDTO contact) {
    if (_item == null) return;

    // 更新Item信息
    _item!.name = contact.name;
    _item!.mobile = contact.mobile;
    _item!.relation = contact.relation;

    // 跳转到跟进页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FollowupPage(bean: _item)),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 联系信息标题
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Contact Info',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
            ),
          ),

          // 主要联系人列表
          _buildContactList(_contactInfo?.contacts, isChild: false),

          // 联系人标题（可展开）
          _buildExpandableHeader(),

          // 展开的联系人列表
          if (_isExpand)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildContactList(_contactInfoZi?.list, isChild: true),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableHeader() {
    return GestureDetector(
      onTap: () {
        if (!_isExpand && !_isGetChild && _item != null) {
          _viewModel.getContactsListZi(_item!.tradeNo ?? '');
        }
        _flipArrow();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Text(
              'Contacts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _arrowAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _arrowAnimation.value,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(List<ContactDTO>? contacts, {bool isChild = false}) {
    if (contacts == null || contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          isChild ? 'No sub contacts found' : 'No contacts found',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactItem(
          contact: contact,
          isChild: isChild,
          onFollowUp: () {
            _onContactTap(contact);
          },
        );
      },
    );
  }
}

/// 联系人列表项
class ContactItem extends StatelessWidget {
  final ContactDTO contact;
  final VoidCallback onFollowUp;
  final bool isChild;

  const ContactItem({
    Key? key,
    required this.contact,
    required this.onFollowUp,
    this.isChild = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 解密并格式化手机号
    String mobileNumber = _decryptMobile(contact.mobile);
    String formattedMobile = _formatMobile(mobileNumber);

    // 格式化订单号/姓名
    String orderNo = _formatOrderNo(contact.name);

    // 格式化最后通话时间
    String lastTime = _formatLastCallTime(contact.lastCallTime);

    // 格式化通话时长
    String callTime = _formatDuration(contact.duration);

    // 通话次数
    String callNum = contact.count.toString();

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
                // 第一行：手机号 + 复制按钮 + 日期（子联系人时显示）
                Row(
                  children: [
                    // 手机号
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, mobileNumber),
                      child: Text(
                        formattedMobile,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF409EFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 复制按钮
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, mobileNumber),
                      child: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    // 日期（如果是子联系人且没有显示）
                    if (isChild && lastTime.isNotEmpty)
                      Text(
                        lastTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // 第二行：订单号/姓名 + 复制按钮 + 跟进按钮（最右侧10px）
                Row(
                  children: [
                    // 左侧内容占用剩余空间
                    Expanded(
                      child: Row(
                        children: [
                          // 订单号/姓名
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                if (orderNo.isNotEmpty) {
                                  _copyToClipboard(context, orderNo);
                                }
                              },
                              child: Text(
                                orderNo,
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
                          if (orderNo.isNotEmpty)
                            GestureDetector(
                              onTap: () => _copyToClipboard(context, orderNo),
                              child: const Icon(
                                Icons.copy,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 跟进按钮 - 自动靠右
                    GestureDetector(
                      onTap: onFollowUp,
                      child: const Text(
                        'Follow up',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF409EFF),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF409EFF),
                        ),
                      ),
                    ),
                  ],
                ),

                // 如果是子联系人，显示通话记录信息
                if (isChild) ...[
                  const Divider(height: 24),
                  // 第三行：通话次数、通话时长、最后通话时间
                  Row(
                    children: [
                      // 通话次数
                      SizedBox(
                        width: 70,
                        child: Text(
                          callNum,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // 通话时长
                      SizedBox(
                        width: 120,
                        child: Text(
                          callTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // 最后通话时间
                      Expanded(
                        child: Text(
                          lastTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 右上角关系标签
          if (contact.relation.isNotEmpty)
            Positioned(
              top: -8,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRelationColor(contact.relation),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRelationText(contact.relation),
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

  /// 解密手机号
  String _decryptMobile(String mobile) {
    if (mobile.isEmpty) return '';
    try {
      String decrypted = AESUtil.decrypt(mobile);
      return decrypted.replaceAll('00910', '').replaceAll('+91', '');
    } catch (e) {
      return mobile;
    }
  }

  /// 格式化手机号
  String _formatMobile(String mobile) {
    if (mobile.isEmpty) return '';
    if (mobile.length > 9) {
      return mobile.substring(0, mobile.length - 7) +
          '****' +
          mobile.substring(mobile.length - 3);
    }
    return mobile;
  }

  /// 格式化订单号/姓名
  String _formatOrderNo(String name) {
    if (name.isEmpty) return '';
    if (name.contains('/')) {
      return name.split('/')[0];
    }
    return name;
  }

  /// 格式化最后通话时间
  String _formatLastCallTime(dynamic lastCallTime) {
    if (lastCallTime == null) return '';

    String timeStr = lastCallTime.toString();

    if (timeStr.contains('seconds')) {
      try {
        String substring = timeStr.substring(0, 19);
        List<String> parts = substring.split('-');
        if (parts.length >= 3) {
          String datePart = parts[2].substring(0, 2);
          return '$datePart/${parts[1]}/${parts[0]}${parts[2].substring(2)}';
        }
      } catch (e) {
        return timeStr;
      }
    }

    return _convertTimestamp(timeStr);
  }

  /// 转换时间戳
  String _convertTimestamp(String timestampStr) {
    try {
      List<String> parts = timestampStr.split('-');
      if (parts.length != 2) {
        return timestampStr;
      }

      int timestamp = int.tryParse(parts[0]) ?? 0;
      int timezoneOffset = int.tryParse(parts[1]) ?? 0;

      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      date = date.add(Duration(hours: timezoneOffset));

      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestampStr;
    }
  }

  /// 格式化通话时长
  String _formatDuration(String duration) {
    if (duration.isEmpty) return '0s';

    if (duration.contains('seconds')) {
      return duration.replaceAll('seconds', 's');
    }

    try {
      int seconds = int.tryParse(duration) ?? 0;
      return _formatTime(seconds);
    } catch (e) {
      return duration;
    }
  }

  /// 格式化时间
  String _formatTime(int seconds) {
    if (seconds < 0) return '0s';
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '${minutes}minutes${remainingSeconds}s';
    } else if (seconds < 86400) {
      int hours = seconds ~/ 3600;
      int remainingAfterHours = seconds % 3600;
      int minutes = remainingAfterHours ~/ 60;
      int remainingSeconds = remainingAfterHours % 60;
      return '${hours}h${minutes}minutes${remainingSeconds}s';
    } else {
      int days = seconds ~/ 86400;
      int remainingAfterDays = seconds % 86400;
      int hours = remainingAfterDays ~/ 3600;
      int remainingAfterHours = remainingAfterDays % 3600;
      int minutes = remainingAfterHours ~/ 60;
      int remainingSeconds = remainingAfterHours % 60;
      return '${days}d${hours}h${minutes}minutes${remainingSeconds}s';
    }
  }

  /// 复制到剪贴板
  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 获取关系标签颜色
  Color _getRelationColor(String relation) {
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

  /// 获取关系标签文本
  String _getRelationText(String relation) {
    return relation;
  }
}