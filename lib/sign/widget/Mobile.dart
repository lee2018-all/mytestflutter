import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mytestflutter/common/function/common_dio_function.dart';
import 'package:mytestflutter/common/map/Common_dio_map.dart';

import '../../common/map/common_map.dart';
import 'Otp.dart';

class Mobile extends StatefulWidget {
  const Mobile({super.key});

  @override
  State<Mobile> createState() => _Mobile();
}

class _Mobile extends State<Mobile> {
  bool agreemnet_user = true;

  String phone_str = '';

  final ValueNotifier<bool> login_btn_status = ValueNotifier(false);

  final http = CommonDioFunction();

  int login_start_time = 0;
  int login_time = 0;
  int phone_edit_time = 0;
  int phone_edit_start_time = 0;
  int phone_changeValue_num = 0;
  int clip_otp_num = 0;
  int clip_otp_time = 0;
  int clip_login_from_clip_opt_timo = 0;
  int otp_edit_start_time = 0;
  int otp_changeValue_num = 0;
  int otp_edit_time = 0;
  int clip_login_num = 0;

  late FocusNode _focusNode_phone;
  late TextEditingController _controller_phone;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLoaginStatus();
  }

  Future<void> getLoaginStatus() async {
    _focusNode_phone = FocusNode();
    _focusNode_phone.addListener(() {
      if (_focusNode_phone.hasFocus) {
        phone_changeValue_num++;
        DateTime curr = DateTime.now();
        phone_edit_start_time = curr.millisecondsSinceEpoch;
      } else {
        DateTime curr = DateTime.now();
        if (phone_edit_start_time != 0) {
          phone_edit_time = curr.millisecondsSinceEpoch - phone_edit_start_time;
          phone_edit_start_time = 0;
        }
      }
    });
    _controller_phone = TextEditingController(text: phone_str);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode_phone.canRequestFocus = true;
    });

    DateTime curr = DateTime.now();
    login_start_time = curr.millisecondsSinceEpoch;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode_phone);
    });
  }

  void dispose() {
    _focusNode_phone.dispose();
    _controller_phone.dispose();

    super.dispose();
  }

  var width;

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: main_color),
        child: Padding(
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100, right: 20, left: 20),
                    child: loginPhoneOTPView(),
                  ),
                ),
              ),
              loginFooterView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginPhoneOTPView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Sign in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Your real-time credit score and insights are ready',
            style: TextStyle(
              color: Color(0xff727B8F),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 44),
          child: Image.asset(
            'images/illustration.png',
            width: 132,
            height: 120,
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(height: 32),

        Container(
          height: 48,
          padding: EdgeInsetsGeometry.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Color(0xff212F47),
            border: Border.all(
              color: _focusNode_phone.hasFocus
                  ? Color(0xff56CCE2)
                  : Colors.transparent, //
              width: 1, //
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Image.asset('images/mobile.png', width: 24, height: 24),
                        SizedBox(width: 8),
                        Text(
                          '+91',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '|',
                          style: TextStyle(
                            color: mes_color,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 1),
              Expanded(
                child: Container(
                  height: 46,

                  child: Padding(
                    padding: EdgeInsets.only(left: 8, right: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller_phone,
                            focusNode: _focusNode_phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onTap: () {
                              if (!_focusNode_phone.hasFocus) {
                                _focusNode_phone.requestFocus();
                              }
                              _controller_phone.selection =
                                  TextSelection.collapsed(
                                    offset: _controller_phone.text.length,
                                  );
                              SystemChannels.textInput.invokeMethod(
                                'TextInput.show',
                              );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Your phone number',
                              hintStyle: TextStyle(
                                color: mes_color,
                                fontSize: 14,
                              ),
                            ),

                            keyboardType: TextInputType.number,

                            style: TextStyle(color: Colors.white, fontSize: 14),

                            onChanged: (value) {
                              phone_str = value;
                              if (phone_str.length != 10 || !agreemnet_user) {
                                login_btn_status.value = false;
                              } else {
                                login_btn_status.value = true;
                              }
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),

        ValueListenableBuilder(
          valueListenable: login_btn_status,
          builder: (context, value, child) {
            return Padding(
              padding: EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: () {
                  if (login_btn_status.value) codeBtnAction();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),

                    border: Border.all(
                      color: Color(0xff2A3952), //
                      width: 1, //
                    ),
                  ),

                  height: 48,

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: login_btn_status.value
                          ? text_color
                          : Colors.transparent,

                      //   color: login_btn_status.value ? main_color : mes_color,
                    ),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: login_btn_status.value
                              ? Colors.white
                              : Color(0xffa9a9a9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget loginFooterView() {
    return LayoutBuilder(
      builder: (context, contra) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 16),
            InkWell(
              onTap: () {
                agreemnet_user = !agreemnet_user;
                if (phone_str.length != 10 || !agreemnet_user) {
                  login_btn_status.value = false;
                } else {
                  login_btn_status.value = true;
                }
                setState(() {
                  agreemnet_user;
                });
              },
              child: Image.asset(
                agreemnet_user
                    ? 'images/checked_circle.png'
                    : 'images/unchecked_circle.png',
                width: 19,
                height: 19,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 7, right: 7),
              child: Container(
                width: width - 50,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '''By continue you confirm that you have read and agree to our ''',
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xff56CCE2),
                          fontSize: 12,
                          decorationColor: text_color,
                          decorationThickness: 1.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showggUrl(privacyPolicyUrl);
                          },
                      ),

                      TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: 'User Registration Agreement',
                        style: TextStyle(
                          color: Color(0xff56CCE2),
                          fontSize: 12,
                          decorationColor: text_color,
                          decorationThickness: 1.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showggUrl(termsConditionsUrl);
                          },
                      ),

                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Color(0xff969995),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showggUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
    }
  }

  void codeBtnAction() async {
    FocusScope.of(context).unfocus();
    DateTime curr = DateTime.now();
    clip_otp_time = curr.millisecondsSinceEpoch;
    clip_otp_num++;

    EasyLoading.show();
    try {
      PublicDioMap model = await http.post({
        'qboelVkxTukClu': 1,
        'ytofyTeqmnUbpzb': phone_str,
      }, smsSendUrl);
      EasyLoading.dismiss();

      if (model.code == 0) {
        puhsLoginCodeFunction();
      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }

  void puhsLoginCodeFunction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Otp(
          phone_str: phone_str,
          login_start_time: login_start_time,
          login_time: login_time,
          phone_edit_time: phone_edit_time,
          phone_edit_start_time: phone_edit_start_time,
          phone_changeValue_num: phone_changeValue_num,
          clip_otp_num: clip_otp_num,
          clip_otp_time: clip_otp_time,
        ),
      ),
    );
  }
}
