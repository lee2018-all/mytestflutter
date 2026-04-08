import 'package:flutter/material.dart';

import 'FileUtil.dart';

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool showCopyIcon;
  final VoidCallback? onTap;

  const CopyableText({
    Key? key,
    required this.text,
    this.style,
    this.showCopyIcon = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              text,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (showCopyIcon) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              FileUtil.copyToClipboard(context, text);
            },
            child: const Icon(
              Icons.copy,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}