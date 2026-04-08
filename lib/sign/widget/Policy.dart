import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/function/common_dio_function.dart';
import '../../common/map/common_map.dart';
import '../../main.dart';
import '../map/sign_map.dart';

class Policy extends StatefulWidget {
  @override
  State<Policy> createState() => _Policy();
}

class _Policy extends State<Policy> {
  late InAppWebViewController webViewController;
  late dynamic html_str;
  bool has_init = false;
  final http = CommonDioFunction();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      showPermissionDialogRequest();
    });
  }

  void showPermissionDialogRequest() async {
    EasyLoading.show();
    try {
      dynamic jsonString = await http.getHtml({}, showDialogUrl);
      html_str = jsonString;
      has_init = true;
      if (jsonString is Map) {
        has_init = false;
      }
      setState(() {
        html_str;
        has_init;
      });
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  var top;
  bool agreemnet_user = true;

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    top = MediaQuery.of(context).padding.top;
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff112038),

      body: Padding(
        padding: EdgeInsets.only(
          top: top + 15,
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Row(
              children: [
                SizedBox(width: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: ''),
                      ),
                      (rount) => false,
                    );
                  },
                  child: Image.asset("images/pre.png", width: 42, height: 42),
                ),

                Spacer(), //
                Text(
                  'Permission Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Opacity(
                  opacity: 0, //
                  child: Image.asset("images/pre.png", width: 42, height: 42),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: w - 30,
              padding: EdgeInsets.only(left: 24,right: 24,top: 12,bottom: 12),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/pobg.png'), //
                  fit: BoxFit.fill, //
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RupeeGauge Permissions Notice',
                    style: TextStyle(
                      color: Color(0xff112038),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'In accordance with applicable Indian data protection laws and regulatory guidelines, including principles of data minimization, purpose limitation, and user consent, RupeeGauge requests only strictly necessary permissions to enable secure authentication and personalized loan tracking services.',
                    style: TextStyle(
                      color: Color(0xff112038),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            Expanded(
              child: has_init
                  ? Container(
                      child: InAppWebView(
                        initialData: InAppWebViewInitialData(
                          data: html_str,
                          mimeType: "text/html",
                          encoding: "utf-8",
                        ),

                        initialSettings: InAppWebViewSettings(
                          supportZoom: false,
                          disableContextMenu: true,
                          cacheEnabled: false,
                          useWideViewPort: true,
                          transparentBackground: true,
                          // mediaPlaybackRequiresUserGesture: true
                        ),
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {},

                        onLoadStop: (controller, url) async {},
                      ),
                    )
                  : Container(),
            ),

            Container(
              margin: EdgeInsets.only(top: 5),

              child: Padding(
                padding: EdgeInsets.only(
                  top: 15,
                  bottom: bottom + 18,
                  left: 16,
                  right: 16,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 70,

                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '''
By tapping “Allow”  you confirm that you have read and agree to our ''',
                                      style: TextStyle(
                                        color: Color(0xff969995),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xff56CCE2),
                                        fontSize: 12,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showggUrl(privacyPolicyUrl);
                                        },
                                    ),

                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        color: Color(0xff969995),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'User Registration Agreement',
                                      style: TextStyle(
                                        color: Color(0xff56CCE2),
                                        fontSize: 12,
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
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  allPremissonsAction();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Color(0xff856CF5),
                                  ),
                                  height: 42,

                                  child: Center(
                                    child: Text(
                                      'Allow',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showggUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
    }
  }

  void allPremissonsAction() async {
    await [Permission.camera, Permission.location].request();
    await CallLogPermission.requestCallLogPermission();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
      (rount) => false,
    );
  }
}
