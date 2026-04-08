import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/function/common_dio_function.dart';
import '../../common/map/Common_dio_map.dart';
import '../../common/map/common_map.dart';
import '../../main.dart';
import '../map/sign_map.dart';
import 'Policy.dart';

class Otp extends StatefulWidget {
  Otp({
    super.key,
    required this.phone_str,
    required this.login_start_time,
    required this.login_time,
    required this.phone_edit_time,
    required this.phone_edit_start_time,
    required this.phone_changeValue_num,
    required this.clip_otp_num,
    required this.clip_otp_time,
  });

  String phone_str;

  int login_start_time;
  int login_time;

  int phone_edit_time;
  int phone_edit_start_time;
  int phone_changeValue_num;

  int clip_otp_num;
  int clip_otp_time;

  @override
  State<Otp> createState() => _Otp();
}

class _Otp extends State<Otp> {
  bool show_dialog = false;

  bool agreemnet_user = true;

  List<String> code_list = List.generate(4, (_) => '');

  late Timer code_timer;
  final ValueNotifier<int> code_num = ValueNotifier(-1);

  late Timer ycode_timer;
  final ValueNotifier<int> ycode_num = ValueNotifier(-1);

  final ValueNotifier<bool> login_btn_status = ValueNotifier(false);

  final http = CommonDioFunction();

  int clip_login_from_clip_opt_timo = 0;
  int otp_edit_start_time = 0;
  int otp_changeValue_num = 0;
  int otp_edit_time = 0;
  int clip_login_num = 0;

  bool code_hasing = false;
  late FocusNode _focusNode_code_o;
  late FocusNode _focusNode_code_t;
  late FocusNode _focusNode_code_th;
  late FocusNode _focusNode_code_f;
  late TextEditingController _controller_o;
  late TextEditingController _controller_t;
  late TextEditingController _controller_th;
  late TextEditingController _controller_f;
  final ValueNotifier<int> code_focus_index = ValueNotifier(0);

  bool _isprocessing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HardwareKeyboard.instance.addHandler(changeTECSS);
    getLoaginStatus();
  }

  Future<void> getLoaginStatus() async {
    _focusNode_code_o = FocusNode();
    getFocusNode(_focusNode_code_o);
    _controller_o = TextEditingController(text: code_list[0]);

    _focusNode_code_t = FocusNode();
    getFocusNode(_focusNode_code_t);
    _controller_t = TextEditingController(text: code_list[1]);

    _focusNode_code_th = FocusNode();
    getFocusNode(_focusNode_code_th);
    _controller_th = TextEditingController(text: code_list[2]);

    _focusNode_code_f = FocusNode();
    getFocusNode(_focusNode_code_f);
    _controller_f = TextEditingController(text: code_list[3]);

    Future.delayed(Duration.zero, () {
      code_num.value = 60;
      code_timer = Timer.periodic(Duration(milliseconds: 1000), (ycode_timer) {
        code_num.value--;
        if (code_num.value == 0) {
          code_timer.cancel();
        }
      });
    });

    final prefs = await SharedPreferences.getInstance();
    show_dialog = prefs.getBool('show_dialog') ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      code_focus_index.value = 1;
      FocusScope.of(context).requestFocus(_focusNode_code_o);
    });
  }

  bool changeTECSS(KeyEvent event) {
    if (_isprocessing) return false;
    if (event is KeyDownEvent) {
      _isprocessing = true;
      Future.microtask(() {
        _isprocessing = false;
      });
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (code_focus_index.value > 1) {
          code_list[code_focus_index.value - 2] = '';
          changeFocus(code_focus_index.value - 1, 0);
        }
      }
    }

    return false;
  }

  void getFocusNode(FocusNode focus) {
    focus.addListener(() {
      if (focus.hasFocus) {
        if (code_focus_index.value == 1) {
          code_hasing = true;
          otp_changeValue_num++;
          DateTime curr = DateTime.now();
          otp_edit_start_time = curr.millisecondsSinceEpoch;
        }
      } else {
        if (code_focus_index.value == 4) {
          code_hasing = false;
          DateTime curr = DateTime.now();
          if (otp_edit_start_time != 0) {
            otp_edit_time = curr.millisecondsSinceEpoch - otp_edit_start_time;
            otp_edit_start_time = 0;
          }
        }
      }
    });
  }

  void dispose() {
    _focusNode_code_o.dispose();
    _focusNode_code_t.dispose();
    _focusNode_code_th.dispose();
    _focusNode_code_f.dispose();
    _controller_o.dispose();
    _controller_t.dispose();
    _controller_th.dispose();
    _controller_f.dispose();
    HardwareKeyboard.instance.removeHandler(changeTECSS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(color: main_color),

        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100, right: 20, left: 20),
                        child: loginPhoneOTPView(),
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: ValueListenableBuilder(
                    valueListenable: ycode_num,
                    builder: (context, value, chuld) {
                      String code_num_value_str = ycode_num.value.toString();
                      code_num_value_str = code_num_value_str.length != 2
                          ? '0$code_num_value_str'
                          : code_num_value_str;

                      String code_btn_str = ycode_num.value == -1
                          ? 'Get Voice OTP'
                          : ycode_num.value == 0
                          ? 'ReCall'
                          : '$code_num_value_str' + 's';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              if (ycode_num.value > 0)
                                TextSpan(
                                  text: code_btn_str,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                              if (ycode_num.value <= 0)
                                TextSpan(
                                  text: code_btn_str,
                                  style: TextStyle(
                                    color: Color(0xff56CCE2),
                                    fontSize: 14,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ycodeBtnAction();
                                    },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
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
        Text(
          'Verification code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            'Your real-time credit score and insights are ready.',
            style: TextStyle(color: Color(0xff727B8F), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 34),
          child: Image.asset('images/verfication.png', width: 132, height: 120),
        ),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: ValueListenableBuilder(
            valueListenable: code_focus_index,
            builder: (context, value, clide) {
              return codeUI();
            },
          ),
        ),

        ValueListenableBuilder(
          valueListenable: login_btn_status,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 25, bottom: 15),
                child: InkWell(
                  onTap: () {
                    if (login_btn_status.value) loginBtnAction();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: login_btn_status.value
                          ? Color(0xff856CF5)
                          : Colors.transparent,
                      border: Border.all(
                        color: Color(0xff2A3952), //
                        width: login_btn_status.value ? 0 : 1, //
                      ),
                    ),
                    height: 48,
                    child: Center(
                      child: Text(
                        'Register & Sign in',
                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: code_num,
          builder: (context, value, child) {
            String code_num_value_str = code_num.value.toString();
            code_num_value_str = code_num_value_str.length != 2
                ? '0$code_num_value_str'
                : code_num_value_str;

            String code_btn_str = code_num.value == -1
                ? 'Send OTP'
                : code_num.value == 0
                ? 'Resend'
                : '$code_num_value_str' + 's';

            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      if (code_num.value == 0)
                        TextSpan(
                          text: '''Not Received? ''',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),

                      if (code_num.value > 0)
                        TextSpan(
                          text: code_btn_str,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      if (code_num.value <= 0)
                        TextSpan(
                          text: code_btn_str,
                          style: TextStyle(
                            color: Color(0xff56CCE2),
                            fontSize: 14,

                            decorationColor: text_color,
                            decorationThickness: 1.0,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              codeBtnAction();
                            },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget codeUI() {
    _controller_o.text = code_list[0];
    _controller_t.text = code_list[1];
    _controller_th.text = code_list[2];
    _controller_f.text = code_list[3];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        codeTextView(0, _focusNode_code_o, _controller_o),
        SizedBox(width: 12),
        codeTextView(1, _focusNode_code_t, _controller_t),
        SizedBox(width: 12),

        codeTextView(2, _focusNode_code_th, _controller_th),
        SizedBox(width: 12),

        codeTextView(3, _focusNode_code_f, _controller_f),
      ],
    );
  }

  Widget codeTextView(
    int index,
    FocusNode focus,
    TextEditingController controller,
  ) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: focus.hasFocus ? Colors.transparent : Color(0xFF18273F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focus.hasFocus ? Color(0xFF56CCE2) : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Container(
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focus,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Future.delayed(Duration.zero, () {
                  code_focus_index.value = 1;
                  setState(() {
                    code_list = ['', '', '', ''];
                    login_btn_status.value = false;
                  });
                  FocusScope.of(context).requestFocus(_focusNode_code_o);
                });
                controller.selection = TextSelection.collapsed(
                  offset: controller.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.white, //
                fontSize: 20, //
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto', //
              ),
              textAlign: TextAlign.center,
              onChanged: (value) {
                int text_type = 2;
                if (value.length == 0) {
                  if (index != 0) {
                    code_list[index - 1] = '';
                    text_type = 0;
                  } else {
                    text_type = 1;
                  }
                } else {
                  code_list[index] = value;
                }
                changeFocus(index, text_type);
              },
              cursorColor: Color(0xFF06D6A0),
              //
              cursorWidth: 2,
              cursorHeight: 24,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> changeFocus(int index, int text_type) async {
    if (text_type == 2) {
      if (index == 0) {
        code_focus_index.value = 2;
        FocusScope.of(context).requestFocus(_focusNode_code_t);
      }
      if (index == 1) {
        code_focus_index.value = 3;
        FocusScope.of(context).requestFocus(_focusNode_code_th);
      }
      if (index == 2) {
        code_focus_index.value = 4;
        FocusScope.of(context).requestFocus(_focusNode_code_f);
      }
      if (index == 3) {
        code_focus_index.value = 0;
        FocusScope.of(context).requestFocus(FocusNode());
        loginBtnAction();
      }
    } else if (text_type == 0) {
      if (index == 1) {
        code_focus_index.value = 1;
        FocusScope.of(context).requestFocus(_focusNode_code_o);
      }
      if (index == 2) {
        code_focus_index.value = 2;
        FocusScope.of(context).requestFocus(_focusNode_code_t);
      }
      if (index == 3) {
        code_focus_index.value = 3;
        FocusScope.of(context).requestFocus(_focusNode_code_th);
      }
    }

    if (getCodeStatus()) {
      login_btn_status.value = true;
    } else {
      login_btn_status.value = false;
    }
  }

  bool getCodeStatus() {
    for (int i = 0; i < code_list.length; i++) {
      if (code_list[i] == '') return false;
    }
    return true;
  }

  void showggUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
    }
  }

  void ycodeBtnAction() async {
    FocusScope.of(context).requestFocus(FocusNode());

    final call_status = await NativePermission.isCallLogGranted();

    if (call_status == 2) {
      EasyLoading.show();
      try {
        PublicDioMap model = await http.post({
          'okmKoytFihph': widget.phone_str,
        }, saveCallInfoUrl);
        EasyLoading.dismiss();
        if (model.code == 0) {
          ycode_num.value = 60;
          ycode_timer = Timer.periodic(Duration(milliseconds: 1000), (
            code_timer,
          ) {
            ycode_num.value--;
            if (ycode_num.value == 0) {
              ycode_timer.cancel();
            }
          });
        } else {
          EasyLoading.showError(model.msg);
        }
      } catch (e) {
        EasyLoading.dismiss();
      }
    } else {
      showPermissionCallLogDialog(call_status as int);
    }
  }

  void showPermissionCallLogDialog(int call_status) {
    var width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            Center(
              child: Container(
                width: width - 40,
                decoration: BoxDecoration(
                  color: Color(0xff112038),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 15,
                          left: 12,
                          right: 12,
                          top: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                '''Call Log Access Permission''',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 8),

                            Image.asset(
                              'images/call.png',
                              width: 120,
                              height: 110,
                            ),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                  top: 12,
                                ),
                                child: Text(
                                  '''We request access to your call logs only to automatically detect and verify your voice call OTP during login.''',
                                  style: TextStyle(
                                    color: Color(0xff727B8F),
                                    fontSize: 14,
                                  ),
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
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 2,
                                      left: 0,
                                      right: 0,
                                    ),
                                    child: InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 2,
                                          left: 45,
                                          right: 45,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          border: Border.all(
                                            color: Color(0xff2A3952),
                                            width: 1,
                                          ),
                                        ),
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            'Deny',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 2,
                                      left: 0,
                                      right: 0,
                                    ),
                                    child: InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 2,
                                          left: 45,
                                          right: 45,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          color: text_color,
                                        ),
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            'Allow',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (call_status == 3) {
                                          openAppSettings();
                                        } else {
                                          premissonslogAction();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  void premissonslogAction() async {
    bool hasPermisson = await CallLogPermission.requestCallLogPermission();
    if (hasPermisson) {
      EasyLoading.show();
      try {
        PublicDioMap model = await http.post({
          'okmKoytFihph': widget.phone_str,
        }, saveCallInfoUrl);
        EasyLoading.dismiss();
        if (model.code == 0) {
          ycode_num.value = 60;
          ycode_timer = Timer.periodic(Duration(milliseconds: 1000), (
            code_timer,
          ) {
            ycode_num.value--;
            if (ycode_num.value == 0) {
              ycode_timer.cancel();
            }
          });
        } else {
          EasyLoading.showError(model.msg);
        }
      } catch (e) {
        EasyLoading.dismiss();
      }
    }
  }

  void codeBtnAction() async {
    FocusScope.of(context).unfocus();
    DateTime curr = DateTime.now();
    widget.clip_otp_time = curr.millisecondsSinceEpoch;
    widget.clip_otp_num++;

    EasyLoading.show();
    try {
      PublicDioMap model = await http.post({
        'qboelVkxTukClu': 1,
        'ytofyTeqmnUbpzb': widget.phone_str,
      }, smsSendUrl);
      EasyLoading.dismiss();
      if (model.code == 0) {
        code_num.value = 60;
        code_timer = Timer.periodic(Duration(milliseconds: 1000), (
          ycode_timer,
        ) {
          code_num.value--;
          if (code_num.value == 0) {
            code_timer.cancel();
          }
        });
      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }

  void loginBtnAction() async {
    clip_login_num++;
    FocusScope.of(context).unfocus();
    DateTime curr = DateTime.now();

    if (otp_edit_start_time != 0) {
      otp_edit_time = curr.millisecondsSinceEpoch - otp_edit_start_time;
      otp_edit_start_time = 0;
    }
    if (widget.clip_otp_time != 0) {
      clip_login_from_clip_opt_timo =
          curr.millisecondsSinceEpoch - widget.clip_otp_time;
    }
    widget.login_time = curr.millisecondsSinceEpoch - widget.login_start_time;
    EasyLoading.show();
    String code_str = '';
    for (int i = 0; i < code_list.length; i++) {
      code_str = code_str + code_list[i];
    }
    try {
      PublicDioMap model = await http.post({
        'rlkaMebilNqbx': code_str,
        'okmKoytFihph': widget.phone_str,
      }, verifycodeUrl);

      if (model.code == 0) {
        if (ycode_num.value != 0 && ycode_num.value != -1) {
          ycode_num.value = 0;
          ycode_timer.cancel();
        }
        if (code_num.value != 0 && code_num.value != -1) {
          code_num.value = 0;
          code_timer.cancel();
        }
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', model.data['fxmdiKpjsDnof']);
        prefs.setString('userCode', model.data['xkxniInuqDvbbdMmuadFts']);
        prefs.setString('mobile', model.data['xkmmpMjfaVbpl']);
        if (model.data['hwjniLnjNic'] != null) {
          const channels = MethodChannel('des_encryption');
          final results = await channels.invokeMethod('decryptDES', {
            'plaintext': model.data['hwjniLnjNic'].toString(),
            'key': 'DefaultKey',
          });

          prefs.setString("score_num", results);
        }

        showViewClass();
        maidian();
        Future.delayed(Duration(seconds: 0), () {
          adjustThirdRequest();
        });
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        "Network is busy. Please try again in a few moments.",
      );
    }
  }

  void maidian() async {
    try {
      await http.post({
        'zsfkcZixzVsuGstHbj': {
          'bdszRvqptJztrHhajlGqw': 0,
          'gcnqQlwYztst': (widget.login_time / 1000).toInt(),

          'btzXmroRcp': widget.phone_changeValue_num,
          'lhjwbXfwhlNsw': (widget.phone_edit_time / 1000).toInt(),

          'cdpTtjpeGyxEaq': widget.clip_otp_num,
          'biqBiadbUwzpwTzw': (clip_login_from_clip_opt_timo / 1000).toInt(),
          'yhcgCohQwhbkWxre': otp_changeValue_num,
          'jesaKbxhUtyyjFojpKfvlu': (otp_edit_time / 1000).toInt(),
          'nvqwXtgxAvriGhzio': clip_login_num,
        },
      }, pointPutUrl);

      maidianFive();
    } catch (e) {}
  }

  void maidianFive() async {
    try {
      await http.post({
        'zsfkcZixzVsuGstHbj': {
          'bdszRvqptJztrHhajlGqw': 5,
          'btzXmroRcp': widget.phone_changeValue_num,
          'lhjwbXfwhlNsw': (widget.phone_edit_time / 1000).toInt(),
        },
      }, pointPutUrl);
    } catch (e) {}
  }

  void showViewClass() async {
    try {
      PublicDioMap model = await http.post({}, GetABUrl);
      EasyLoading.dismiss();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('show_dialog', false);
      prefs.setBool('fromLogin', true);
      if (model.code == 0 && model.data) {
        prefs.setInt('login_status', 2);
      } else {
        prefs.setInt('login_status', 1);
      }
      if (show_dialog) {
        showPermissionDialog();
      } else {
        changeLoginStatus();
      }
    } catch (e) {
      EasyLoading.dismiss();
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('login_status', 1);
      prefs.setBool('show_dialog', false);
      if (show_dialog) {
        showPermissionDialog();
      } else {
        changeLoginStatus();
      }
    }
  }

  void changeLoginStatus() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
      (rount) => false,
    );
  }

  void showPermissionDialog() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Policy()),
      (rount) => false,
    );
  }

  void adjustThirdRequest() async {
    try {
      await http.get({}, adjustThirdUrl);
    } catch (e) {}
  }
}
