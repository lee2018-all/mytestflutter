import 'package:flutter/material.dart';

class OperationBottomSheet extends StatelessWidget {
  final List<String> menuItems;
  final Function(int) onItemSelected;

  const OperationBottomSheet({
    Key? key,
    required this.menuItems,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // 标题
          const Text(
            'Operation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 菜单项
          ...List.generate(menuItems.length, (index) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    menuItems[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(index);
                  },
                ),
                if (index < menuItems.length - 1)
                  const Divider(height: 1, indent: 20, endIndent: 20),
              ],
            );
          }),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}