// base_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BasePage<VM extends BaseViewModel> extends StatelessWidget {
  const BasePage({super.key});

  VM createViewModel();

  Widget buildContentView(BuildContext context, VM viewModel);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VM>(
      init: createViewModel(),
      builder: (viewModel) {
        return buildContentView(context, viewModel);
      },
    );
  }
}



abstract class BaseViewModel extends GetxController {
  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {}
}