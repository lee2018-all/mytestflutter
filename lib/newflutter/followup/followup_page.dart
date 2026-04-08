import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../color/config_model.dart';
import '../color/item_model.dart';
import '../detail/util/AESUtil.dart';
import 'followup_viewmodel.dart';



class FollowupPage extends StatefulWidget {
  final ItemModel? bean;

  const FollowupPage({
    Key? key,
    this.bean,
  }) : super(key: key);

  @override
  State<FollowupPage> createState() => _FollowupPageState();
}

class _FollowupPageState extends State<FollowupPage> {
  late final FollowupViewModel _viewModel;

  // Data
  ItemModel? _item;
  List<ConfigCollectionStatusDTO> _collectionStatusList = [];
  List<ConfigRelativesDTO> _relativesList = [];

  // Selected values
  String _selectedCollectionStatus = '';
  String _selectedRelation = '';
  String _content = '';

  // Controllers
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // State
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = FollowupViewModel();
    _loadData();
    _setupListeners();
    _setupFocusListener();
  }

  void _loadData() {
    // 获取Item数据
    if (widget.bean != null) {
      _item = widget.bean;

      // 设置标题
      if (_item != null) {
        // 解密手机号
        String decryptedMobile = _decryptMobile(_item!.mobile ?? '');
        setState(() {
          _item!.mobile = decryptedMobile;
        });
      }
    }

    // 获取配置数据
    _viewModel.getConfig();
  }

  String _decryptMobile(String encrypted) {
    if (encrypted.isEmpty) return '';
    try {
      String decrypted = AESUtil.decrypt(encrypted);
      decrypted = decrypted.replaceAll('00910', '').replaceAll('+91', '');
      return decrypted;
    } catch (e) {
      return encrypted;
    }
  }

  String _formatMobile(String mobile) {
    if (mobile.length > 9) {
      return mobile.substring(0, 3) + '****' + mobile.substring(7);
    }
    return mobile;
  }

  void _setupListeners() {
    _viewModel.loading.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
      if (loading) {
        EasyLoading.show();
      } else {
        EasyLoading.dismiss();
      }
    });

    _viewModel.error.listen((error) {
      if (error.isNotEmpty) {
        EasyLoading.showError(error);
      }
    });

    _viewModel.configData.listen((config) {
      if (config != null) {
        setState(() {
          _collectionStatusList = config.collectionStatus ?? [];
          _relativesList = config.relatives ?? [];
        });
      }
    });

    _viewModel.followResult.listen((success) {
      if (success) {
        EasyLoading.showSuccess('Follow up successful');
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    });
  }

  void _setupFocusListener() {
    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        // 延迟滚动，确保键盘已经弹出
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onConfirm() {
    if (_contentController.text.trim().isEmpty) {
      EasyLoading.showError('Please input content');
      return;
    }

    if (_item == null) return;

    String mobile = _item!.mobile ?? '';

    _viewModel.follow(
      tradeNo: _item!.tradeNo ?? '',
      collectionNo: _item!.collectionNo ?? '',
      followId: _item!.followId?.toString() ?? '',
      followUp: _item!.followUp ?? '',
      mobile: mobile,
      name: _item!.name ?? '',
      collectionStatus: _selectedCollectionStatus,
      relation: _selectedRelation,
      content: _contentController.text.trim(),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Follow up',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E88E5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        children: [
          // 信息卡片
          _buildInfoCard(),
          const SizedBox(height: 16),

          // 跟进状态选项
          _buildStatusGrid(),
          const SizedBox(height: 16),

          // 关系选项
          _buildRelationGrid(),
          const SizedBox(height: 16),

          // 内容输入框
          _buildContentInput(),
          const SizedBox(height: 24),

          // 按钮
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _item?.name ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatMobile(_item?.mobile ?? ''),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    if (_collectionStatusList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Collection Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF606060),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: _collectionStatusList.length,
            itemBuilder: (context, index) {
              final item = _collectionStatusList[index];
              final isSelected = _selectedCollectionStatus == item.value;
              return _buildOptionItem(
                text: item.name ?? '',
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCollectionStatus = item.value ?? '';
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelationGrid() {
    if (_relativesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Relation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF606060),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: _relativesList.length,
            itemBuilder: (context, index) {
              final item = _relativesList[index];
              final isSelected = _selectedRelation == item.value;
              return _buildOptionItem(
                text: item.name ?? '',
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedRelation = item.value ?? '';
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFF262626),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        maxLines: 5,
        minLines: 3,
        decoration: InputDecoration(
          hintText: 'Content',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF262626),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1E88E5),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _onConfirm,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}