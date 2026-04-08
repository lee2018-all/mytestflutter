import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final bool isForAll;
  final List<Color> colors;
  final List<Color> borderColors;
  final Function(int) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.isForAll,
    required this.colors,
    required this.borderColors,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isForAll ? 'Select Color Filter' : 'Select Color',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index],
                      border: Border.all(
                        color: borderColors[index],
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: index == 6
                          ? const Text('None')
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}