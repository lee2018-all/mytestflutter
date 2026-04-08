import 'package:flutter/material.dart';
import 'package:mytestflutter/newflutter/cct/cct_activity.dart';
import 'package:mytestflutter/newflutter/report/report_activity.dart';

import '../color_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apps, size: 100, color: Color(0xFF1E88E5)),
            const SizedBox(height: 20),
            const Text(
              '功能导航',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左下角按钮
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ColorPage()),
                );
              },
              child: const Icon(Icons.color_lens),
              backgroundColor: Colors.purple,
              heroTag: 'colorBtn',
            ),
          ),
          // 右下角按钮
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CctActivity()),
                );
              },
              child: const Icon(Icons.assessment),
              backgroundColor: Colors.orange,
              heroTag: 'cctBtn',
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
