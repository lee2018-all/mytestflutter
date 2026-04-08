import 'package:flutter/material.dart';

class FilterGridView extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int crossAxisCount;

  const FilterGridView({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 2.5, // 调整高度比例
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    );
  }

  Widget _buildGridItem(int index) {
    bool isSelected = index == selectedIndex;
    String itemText = items[index];

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            itemText,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}