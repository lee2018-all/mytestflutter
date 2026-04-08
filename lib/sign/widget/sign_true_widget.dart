/*
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mytestflutter/sign/function/sign_function.dart';
import 'package:mytestflutter/sign/widget/sign_web_widget.dart';
import 'package:mytestflutter/common/function/common_dio_function.dart';
import 'package:mytestflutter/common/map/Common_dio_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import '../../../main.dart';
import '../../common/map/common_map.dart';
import '../map/sign_map.dart';

class SignTrueWidget extends StatefulWidget {
  const SignTrueWidget({super.key});

  @override
  State<SignTrueWidget> createState() => _SignTrueWidget();
}

class _SignTrueWidget extends State<SignTrueWidget>
    with WidgetsBindingObserver {
  final http = CommonDioFunction();

  String url = '';

  int file_type = 0;

  int back_num = 0;

  bool begain_upt = false;

  int back_type = 0;

  int appCount = 0;
  int callCount = 0;
  int callDay = 0;

  late InAppWebViewController webViewController;

  final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();

  int tagerKB = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration(milliseconds: 50), () {
      getHtmlUrl();
    });
  }

  void getHtmlUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String mobile = prefs.getString('mobile') ?? '';
    String usercode = prefs.getString('userCode') ?? '';

    String deviceId;
    if (kIsWeb) {
      // 运行在 Web 平台上的代码
      deviceId = "web";
    } else {
      const MethodChannel _channel = MethodChannel('AndroidId');
      deviceId = await _channel.invokeMethod('getAndroidId');
    }
    EasyLoading.show();

    try {
      PublicDioMap model = await http.get({}, configUrl);
      EasyLoading.dismiss();
      if (model.code == 0) {
        callDay = model.data['trndMuhmkHdfn'];
        callCount = model.data['xiiIliqGivjgGphfu'];
        appCount = model.data['wfsojPutrmGadg'];
        url = model.data['xigqNbtWptgiZsjUopdo'];
        tagerKB = model.data['xuvlHnooVjbyi'];
        if (url.contains('?')) {
          url =
              url +
              '&token=$token&mobile=$mobile&usercode=$usercode&appCode=$app_appCode&deviceId=$deviceId&type=flutter';
        } else {
          url =
              url +
              'getLoan?token=$token&mobile=$mobile&usercode=$usercode&appCode=$app_appCode&deviceId=$deviceId&type=flutter';
        }
        setState(() {
          url;
        });
      } else {}
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && begain_upt) {
      back_num++;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (url.length == 0) {
      return Scaffold();
    }
    return PopScope(
      child: Scaffold(
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(url, forceToStringRawValue: true),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'X-Requested-With': 'com.example.app',
            },
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            cacheEnabled: false,
            transparentBackground: false,
            useHybridComposition: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            javaScriptCanOpenWindowsAutomatically: true,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
            listenToJS();
          },
          onLoadStart: (controller, url) {
            EasyLoading.show();
          },

          onLoadStop: (controller, url) {
            EasyLoading.dismiss();
            getInfoData();
          },
        ),
      ),
      canPop: false,
      onPopInvokedWithResult: (pops, result) async {
        bool canBack = await webViewController.canGoBack();
        if (canBack) {
          webViewController.goBack();
        }
      },
    );
  }

  void getInfoData() async {
    final prefs = await SharedPreferences.getInstance();
    bool fromLogin = prefs.getBool('fromLogin') ?? false;
    if (fromLogin) {
      SignFunction().initData(appCount, callCount, callDay);
      prefs.setBool('fromLogin', false);
    }
  }

  void listenToJS() {
    webViewController.addJavaScriptHandler(
      handlerName: 'vtcMrmgoZarz',
      callback: (message) {
        file_type = 1;
        getAnyFileUrl();
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'qffGarygRuab',
      callback: (message) {
        file_type = 2;
        selectUpdatType();
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'znorgKohhe',
      callback: (message) {
        file_type = 3;
        selectUpdatType();
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'acljQjoGjn',
      callback: (message) {
        file_type = 4;
        getImagePicker(true);
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'ucvNhp',
      callback: (List<dynamic> arguments) {
        String productCode = arguments.first['productCode'];
        loanProduct(productCode);
      },
    );

    webViewController.addJavaScriptHandler(
      handlerName: 'mchdpInimMmdqa',
      callback: (message) {
        callGooglePlay();
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'hqcCta',
      callback: (message) {
        launchUrl(Uri.parse(message.first));
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'wnnTasos',
      callback: (message) {
        launchUrl(Uri.parse(message.first));
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'xrefSjgihBum',
      callback: (message) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SignWebWidget(url: message.first, nav_title: 'Pay'),
          ),
        );
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'tvrNugbKzxy',
      callback: (message) {
        back_type = message.first['type'];
        begain_upt = true;
        back_num = 0;
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'sxvaIxjmVzx',
      callback: (message) {
        begain_upt = false;
        maidian();
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'zoivuAxnMxhnb',
      callback: (message) {
        logoutAction();
      },
    );

    webViewController.addJavaScriptHandler(
      handlerName: 'jvqneMqkfmCvhf',
      callback: (message) {
        getPhoneNUmber();
      },
    );
  }

  void getPhoneNUmber() async {
    final Contact? contact = await contactPicker.selectContact();
    if (contact != null) {
      Map<String, dynamic> contact_dic = {
        'name': contact.fullName,
        'phone': contact.phoneNumbers!.first,
      };
      String JSON = jsonEncode(contact_dic);
      webViewController.evaluateJavascript(source: 'kcffTnmwi($JSON)');
    }
  }

  void logoutAction() async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('login_status', 0);
    pref.remove('token');
    pref.remove('userCode');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
      (route) => false,
    );
  }

  void getAnyFileUrl() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'txt', 'pdf'],
    );
    if (result != null) {
      File file = File(result!.files.single.path!);
      pushFile(file);
    }
  }

  void pushFile(File file) async {
    EasyLoading.show();
    try {
      PublicDioMap model = await http.uploadFile({}, fileUploadUrl, file);
      EasyLoading.dismiss();
      if (model.code == 0) {
        String file_url = model.data;
        if (file_type == 1)
          webViewController.evaluateJavascript(
            source: 'stoEiuabBvq("$file_url")',
          );
        if (file_type == 2)
          webViewController.evaluateJavascript(source: 'pnnoNgs("$file_url")');
        if (file_type == 3)
          webViewController.evaluateJavascript(source: 'ioyJfkf("$file_url")');
        if (file_type == 4)
          webViewController.evaluateJavascript(
            source: 'znitAurnuQddon("$file_url")',
          );
      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  void loanProduct(String productCode) async {
    EasyLoading.show();
    await [Permission.location].request();
    await CallLogPermission.requestCallLogPermission();
    SignFunction().initData(appCount, callCount, callDay);

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    try {
      PublicDioMap model = await http.post({
        'khhEaaXtyo': productCode,

        'iprZaoysNijy': 1,
      }, loanPaymentUrl);
      EasyLoading.dismiss();
      if (model.code == 0) {
        webViewController.evaluateJavascript(source: 'ydqnrDuawDez("ok")');
      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  void selectUpdatType() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              getImagePicker(true);
              Navigator.pop(context);
            },
            child: Text('Camera'),
          ),

          CupertinoActionSheetAction(
            onPressed: () {
              getImagePicker(false);
              Navigator.pop(context);
            },
            child: Text('Gallery'),
          ),

          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void getImagePicker(bool camera) async {
    if (camera) {
      var permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        if (permissionStatus.isDenied) {
          permissionStatus = await Permission.camera.request();
        } else {
          openAppSettings();
        }
      }
    }
    ImagePicker()
        .pickImage(
          source: camera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 90,
        )
        .then((img) {
          if (img != null) {
            compressImageToTargetSize(
              originalFile: File(img.path),
              targetKB: tagerKB,
            );
          }
        });
  }

  void compressImageToTargetSize({
    required File originalFile,
    required int targetKB,
  }) async {
    final bytes = await originalFile.readAsBytes();
    final img = Im.decodeImage(bytes)!;
    int compressionQuality = 100;
    final compressedImage = Im.copyResize(img, width: 800);
    var compressedBytes = Im.encodeJpg(compressedImage, quality: 90);
    while (compressedBytes.length > 1024 * targetKB &&
        compressionQuality > 10) {
      compressionQuality -= 10;
      compressedBytes = Im.encodeJpg(
        compressedImage,
        quality: compressionQuality,
      );
    }

    final directory = await getTemporaryDirectory();
    final targetPath =
        '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = File(targetPath);
    await imageFile.writeAsBytes(compressedBytes);
    pushFile(imageFile);
  }

  void callGooglePlay() async {
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=' + app_id,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void maidian() async {
    Map<String, dynamic> par = {'bdszRvqptJztrHhajlGqw': back_type};
    if (back_type == 1) par.addAll({'ggyqMylYsnoeRvq': back_num});
    if (back_type == 2) par.addAll({'umvwPrvqPhsFbkIoenx': back_num});
    if (back_type == 3) par.addAll({'wqokMajdJojzEclWmmbp': back_num});
    if (back_type == 4) par.addAll({'hgnmGbbFpux': back_num});

    try {
      await http.post({'zsfkcZixzVsuGstHbj': par}, pointPutUrl);
    } catch (e) {}
  }
}
*/
