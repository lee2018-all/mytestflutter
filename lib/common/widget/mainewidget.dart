import 'package:flutter/material.dart';
import 'package:mytestflutter/common/map/common_map.dart';
import 'package:mytestflutter/common/widget/home.dart';
import 'package:mytestflutter/common/widget/setting.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> {
  int current_index = 0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
    /*    Container(
          width: width,
          height: height - 55 - bottom,
          child: current_index == 0 ? HomeWidget() : Setting(),
        ),*/
        IndexedStack(
          index: current_index,
          children: [
            HomeWidget(),
            Setting(),
          ],
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 55 + bottom,
            decoration: BoxDecoration(color: main_color),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    color: Colors.white.withAlpha(50),
                  ),
                  footerView(),
                ],
              ),
              // child: footerView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget footerView() {
    final width = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              current_index = 0;
            });
          },
          child: Container(
            width: width / 2,
            height: 54,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 5,right: 40),
                child: Column(
                  children: [
                    Image.asset(
                      current_index == 0
                          ? 'images/main_yes.png'
                          : 'images/main_no.png', width: 25,height: 25,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: current_index == 0
                            ? Color(0xff856CF5)
                            : Color(0xff515b70),
                      ),

                      textAlign: TextAlign.center,

                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        InkWell(
          onTap: () {
            setState(() {
              current_index = 1;
            });
          },
          child: Container(
            width: width / 2,
            height: 54,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 5,left: 40),
                child: Column(
                  children: [
                    Image.asset(
                      current_index == 1
                          ? 'images/set_yes.png'
                          : 'images/set_no.png', width: 25,height: 25,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: current_index == 1
                            ? Color(0xff856CF5)
                            : Color(0xff515b70),
                      ),

                      textAlign: TextAlign.center,

                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
