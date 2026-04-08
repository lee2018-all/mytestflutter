import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/utr/utr_viewmodel.dart';
import '../detail/util/NumberFormatter.dart';
import '../utr/utr_model.dart';

class DeductionPage extends StatefulWidget {
  final String? loanId;

  const DeductionPage({Key? key, this.loanId}) : super(key: key);

  @override
  State<DeductionPage> createState() => _DeductionPageState();
}

class _DeductionPageState extends State<DeductionPage> {
  late final UtrViewModel _viewModel;

  // 扣款类型: 0: -30%, 1: -50%, 2: -100%
  int _selectedDeductionType = 0;
  bool _isLoading = false;

  // 数据
  Duceinfo? _duceinfo;

  @override
  void initState() {
    super.initState();
    _viewModel = UtrViewModel();
    _viewModel.setContext(context);
    _loadData();
    _setupListeners();
  }

  void _loadData() {
    if (widget.loanId != null) {
      _viewModel.getDeductionInfo(widget.loanId!);
    }
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
      if (error.isNotEmpty && mounted) {
        EasyLoading.showError(error);
      }
    });

    _viewModel.duceInfo.listen((data) {
      if (mounted) {
        setState(() {
          _duceinfo = data;
        });
      }
    });

    _viewModel.result.listen((success) {
      if (success && mounted) {
        EasyLoading.showSuccess('Deduction successful');
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    });
  }

  void _onConfirm() {
    if (_duceinfo == null) {
      EasyLoading.showError('No deduction info');
      return;
    }

    // 扣款类型映射：0: 30%, 1: 50%, 2: 100%
    int deductionValue = _selectedDeductionType + 1;

    _viewModel.submitDeduction(
      _duceinfo!.repaymentInfo?.billNo ?? '',
      widget.loanId ?? '',
      deductionValue.toString()
    );
  }

  void _selectDeductionType(int type) {
    setState(() {
      _selectedDeductionType = type;
    });
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '0.00';
    try {
      double value = double.parse(amount);
      return NumberFormatter.formatWithCommaTwoDecimal(value);
    } catch (e) {
      return amount;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _viewModel.disposeContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _duceinfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: _duceinfo == null
          ? const Center(child: Text('No data available'))
          : SingleChildScrollView(
        child: Column(
          children: [
            // 贷款信息卡片
            _buildLoanInfoCard(),
            const SizedBox(height: 16),
            // 扣款类型卡片
            _buildDeductionTypeCard(),
            const SizedBox(height: 16),
            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Deduction',
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

  Widget _buildLoanInfoCard() {
    final repaymentInfo = _duceinfo?.repaymentInfo;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Loan ID
          _buildInfoRowWithCopy(
            label: 'LoanID',
            value: repaymentInfo?.orderNo ?? '',
            valueColor: const Color(0xFF409EFF),
          ),
          const Divider(height: 16),
          // Repayment Amount
          _buildInfoRow(
            label: 'Repayment Amount',
            value: _formatAmount(repaymentInfo?.repaymentCapital),
          ),
          const Divider(height: 16),
          // Loan Amount
          _buildInfoRow(
            label: 'Loan Amount',
            value: _formatAmount(repaymentInfo?.borrowCapital),
          ),
          const Divider(height: 16),
          // Deductible Amount
          _buildInfoRow(
            label: 'Deductible Amount',
            value: _formatAmount(repaymentInfo?.discountCapital),
          ),
          const Divider(height: 16),
          // Tenure
          _buildInfoRow(
            label: 'Tenure',
            value: '${repaymentInfo?.periodLength ?? 0} days',
          ),
          const Divider(height: 16),
          // Overdue Days
          _buildInfoRow(
            label: 'Overdue Days',
            value: '${repaymentInfo?.overdueDays ?? 0} days',
          ),
          const Divider(height: 16),
          // Interest
          _buildInfoRow(
            label: 'Interest',
            value: _formatAmount(repaymentInfo?.interest),
          ),
          const Divider(height: 16),
          // Processing Fee
          _buildInfoRow(
            label: 'Processing Fee',
            value: _formatAmount(repaymentInfo?.serviceFee),
          ),
          const Divider(height: 16),
          // Overdue Service Fee
          _buildInfoRow(
            label: 'Overdue Service Fee',
            value: _formatAmount(repaymentInfo?.overdueServiceFee),
          ),
          const Divider(height: 16),
          // Total Penalty
          _buildInfoRow(
            label: 'Total Penalty',
            value: _formatAmount(repaymentInfo?.overdueFee),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionTypeCard() {
    final repaymentInfo = _duceinfo?.repaymentInfo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 剩余还款金额
          const Text(
            'Remaining Repayment Amount',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF606060),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '₹ ${_formatAmount(repaymentInfo?.remainCapital)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4040),
            ),
          ),
          const Divider(height: 24),
          // 扣款类型标题
          const Text(
            'Deduct Type / Penalty',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF606060),
            ),
          ),
          const SizedBox(height: 12),
          // 扣款选项
          Row(
            children: [
              _buildDeductionOption(
                value: 0,
                label: '-30%',
                icon: _selectedDeductionType == 0
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                isSelected: _selectedDeductionType == 0,
              ),
              _buildDeductionOption(
                value: 1,
                label: '-50%',
                icon: _selectedDeductionType == 1
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                isSelected: _selectedDeductionType == 1,
              ),
              _buildDeductionOption(
                value: 2,
                label: '-100%',
                icon: _selectedDeductionType == 2
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                isSelected: _selectedDeductionType == 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionOption({
    required int value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDeductionType(value),
        child: Row(
          mainAxisAlignment: value == 0
              ? MainAxisAlignment.start
              : value == 1
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? const Color(0xFF409EFF) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF409EFF) : const Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF606060),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF262626),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithCopy({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF606060),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? const Color(0xFF262626),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
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
      ),
    );
  }
}