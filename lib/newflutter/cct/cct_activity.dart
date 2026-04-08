import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../cct/cct_viewmodel.dart';
import '../cct/rute_bean.dart';
import '../cct/query_bean.dart';
import '../cct/cct_adapter.dart';
import '../report/report_activity.dart';

class CctActivity extends StatefulWidget {
  const CctActivity({Key? key}) : super(key: key);

  @override
  State<CctActivity> createState() => _CctActivityState();
}

class _CctActivityState extends State<CctActivity> {
  late final CctViewModel _viewModel;
  List<ChildrenDTO> _reportList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CctViewModel();
    _viewModel.setContext(context);
    _loadData();
    _setupListeners();
  }

  void _loadData() {
    _viewModel.getrute();
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

    _viewModel.rute.listen((ruteList) {
      _processRuteData(ruteList);
    });
  }

  void _processRuteData(List<RuteBean> ruteList) {
    for (RuteBean ruteBean in ruteList) {
      if (ruteBean.name == 'LoanCollection') {
        if (ruteBean.children != null && ruteBean.children!.isNotEmpty) {
          for (ChildrenDTO childrenDTO in ruteBean.children!) {
            if (childrenDTO.name == 'Reportlist') {
              if (childrenDTO.children != null && childrenDTO.children!.isNotEmpty) {
                setState(() {
                  _reportList = childrenDTO.children!;
                });
                return;
              }
            }
          }
        }
      }
    }
  }

  void _onItemClick(ChildrenDTO childrenDTO, int position) {
    String query = childrenDTO.query ?? '';
    String queryKey = '';
    
    if (query.isNotEmpty) {
      try {
        Map<String, dynamic> json = jsonDecode(query);
        QueryBean queryBean = QueryBean.fromJson(json);
        queryKey = queryBean.queryKey ?? '';
      } catch (e) {
        // Handle parsing error
      }
    }

    String title = childrenDTO.meta?.title ?? '';
    
    // Navigate to ReportActivity
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportActivity(
          query: queryKey,
          title: title,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _viewModel.disposeContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportList.isEmpty
              ? const Center(child: Text('No data available'))
              : CCtAdapter(
                  data: _reportList,
                  context: context,
                  onItemClick: _onItemClick,
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Cct_Statistics',
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
}


