import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SignWebWidget extends StatefulWidget {
  SignWebWidget({super.key, required this.url, required this.nav_title});
  String url;
  String nav_title;
  @override
  State<SignWebWidget> createState() => _SignWebWidget();

}

class _SignWebWidget extends State<SignWebWidget> {
  late InAppWebViewController webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Center(
            child: Padding(padding: EdgeInsets.only(right: 60),
              child: Text(
                widget.nav_title,
                style: TextStyle(
                    color: Color(0xff2a2a2a),
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
        ),
      ),

      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          cacheEnabled: false,
          transparentBackground: false,
          useHybridComposition: true,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
        initialUrlRequest: URLRequest(
            url: WebUri(widget.url)
        ),
        onWebViewCreated: (controller){
          webViewController = controller;
        },
        onLoadStart: (controller, url){
          EasyLoading.show();
        },

        onLoadStop: (controller, url){
          EasyLoading.dismiss();
        },
      ),

    );
  }

}