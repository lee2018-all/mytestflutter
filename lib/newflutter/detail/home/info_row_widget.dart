import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopyable;
  final Color? valueColor;
  final VoidCallback? onCopy;
  final VoidCallback? onTap;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.isCopyable = false,
    this.valueColor,
    this.onCopy,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: valueColor ?? const Color(0xFF262626),
                      fontWeight: valueColor != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onCopy,
                    child: const Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}