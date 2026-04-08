import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../map/common_map.dart';

class Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: main_color,
        image: DecorationImage(
          image: AssetImage('images/screen.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(
              child: Image.asset('images/gauge.png', width: 178, height: 189),
            ),
          ),

          Positioned.fill(
            bottom: 70,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                app_appName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
