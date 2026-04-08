import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../main.dart';
import '../map/common_map.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _Setting();
}

class _Setting extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height - 49 - bottom,
      decoration: BoxDecoration(color: main_color),
      child: Padding(
        padding: EdgeInsets.only(top: top),

        child: Padding(
          padding: EdgeInsets.only(top: 45, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headerItem(),
              settingInfoCellView(1, 'Contact us', 'images/email.png'),

              settingInfoCellView(0, 'About us', 'images/bout.png'),

              settingInfoCellView(
                3,
                'User Registration Agreement',
                'images/service.png',
              ),

              settingInfoCellView(2, 'Privacy & Policy', 'images/pri.png'),

              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: InkWell(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 40),
                    width: 171,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Color(0xff2A3952), //
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () {
                    logoutAction();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 25,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset('images/avata.png', width: 64, height: 64),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app_appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 66,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xff212F47),
                      border: Border.all(
                        color: Color(0xff212F47), //
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'V1.0.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget settingInfoCellView(int index, String name, String image_path) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          nextAction(index);
        },
        child: Container(
          height: 50,
          width: width - 40,

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Image.asset(image_path, width: 26, height: 26),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      name,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),

              if (index == 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Text(
                          app_emial,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Image.asset(
                          'images/copy.png',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void nextAction(int index) async {
    if (index == 0) {
      launchUrlString(aboutUsUrl);
    }
    if (index == 1) {
      await Clipboard.setData(ClipboardData(text: app_emial));
      EasyLoading.showSuccess('Content copied to clipboard.');
    }
    if (index == 2) {
      launchUrlString(privacyPolicyUrl);
    }
    if (index == 3) {
      launchUrlString(termsConditionsUrl);
    }
    if (index == 4) {
      logoutAction();
    }
  }

  void launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
    }
  }

  void logoutAction() async {
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Container(
                        width: width - 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: main_color,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text(
                                    'Are you sure you want to log out of your RupeeGauge account?\nAll unsaved data and temporary session details will be cleared from this device for your security.\nYou’ll need to log in again using your registered mobile number or OTP.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    left: 10,
                                    bottom: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Color(0xff2A3952),
                                              width: 1,
                                            ),
                                          ),
                                          height: 40,
                                          width: width / 2 - 60,
                                          child: Center(
                                            child: Text(
                                              'Sign out',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          logoutTrueAction();
                                        },
                                      ),

                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Color(0xff856CF5),
                                          ),
                                          height: 40,
                                          width: width / 2 - 60,
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void logoutTrueAction() async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('login_status', 0);
    pref.remove('token');
    pref.remove('userCode');
    pref.remove('score_num');
    pref.remove('serve_status');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
      (route) => false,
    );
  }
}
