import 'package:flutter/material.dart';
import '../cct/rute_bean.dart';

class CCtAdapter extends StatelessWidget {
  final List<ChildrenDTO> data;
  final Function(ChildrenDTO, int) onItemClick;
  final BuildContext context;

  const CCtAdapter({
    Key? key,
    required this.data,
    required this.context,
    required this.onItemClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        ChildrenDTO item = data[index];
        return ListTile(
          title: Text(
            item.meta?.title ?? item.name ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF262626),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: () => onItemClick(item, index),
        );
      },
    );
  }
}
