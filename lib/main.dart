/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';*/
import 'package:flutter/material.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mytestflutter/newflutter/cct/HomePage.dart';
import 'package:mytestflutter/newflutter/login.dart';
import 'package:mytestflutter/newflutter/sp_utils.dart';
import 'package:mytestflutter/common//function/common_dio_function.dart';
import 'package:mytestflutter/common/map/common_map.dart';
import 'package:mytestflutter/common/widget/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sign/widget/sign_true_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  //await initgoogleService();
  runApp(const MyApp());

  AdjustConfig adjustConfig = AdjustConfig(
    adjust_key,
    AdjustEnvironment.production,
  );
  Adjust.initSdk(adjustConfig);
  // String firebase_token = await getidToken() ?? '';
  //Adjust.setPushToken(firebase_token);
  getGoodleid();

  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.black
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.deepPurpleAccent
    ..textColor = Colors.black
    ..maskColor = Colors.black.withOpacity(0.3)
    ..maskType = EasyLoadingMaskType.custom
    ..userInteractions = false
    ..dismissOnTap = false;
}

/*Future<void> initgoogleService() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: CommonFirebase.currentPlatform
    );
  } catch (e) {
  }// await Firebase.
}

Future<String?> getidToken() async {
  String? fid = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken){
    Adjust.setPushToken(newToken);
  });
  return fid;
}*/

Future<void> getGoodleid() async {
  String adid = await Adjust.getAdid() ?? '';
  String google = await Adjust.getGoogleAdId() ?? '';
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('adid', adid);
  prefs.setString('googleAdId', google);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        appBarTheme: AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyHomePage(title: '');
          }
          return Screen();
        },
      ),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int login_status = -1;

  final http = CommonDioFunction();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () {
      getLoaginStatus();
    });
  }

  Future<void> getLoaginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    int login_st = prefs.getInt('login_status') ?? 0;
    Future.delayed(Duration(seconds: 4), () {
      adjustThirdRequest();
    });

 /*   后管测试地址http://16.163.9.142:9587/#/login
    admin  GP#jBDaA39!s6iG@Dx*/
    setState(() {
       login_status = login_st;
      new SpUtils().putString(
        "token",
        "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6Ijk1OWZmNWFkLTJmYzUtNDI0Ny05ZmZmLTFhYjI3ZjAzODg5MCJ9.KSP9Dgm3xcDAtpaQ6PQSYuAtAbTWgUDE7V3YgWiGonj5h46RWAt9uhC1zeVY1RQCGBN6W-oFD1JGZXdLhPRjKQ"
      );
      login_status = 1;
    });
  }

  void adjustThirdRequest() async {
    try {
      await http.get({}, adjustThirdUrl);
    } catch (e) {}
  }

  /*  @override
  Widget build(BuildContext context) {
    if (login_status == -1) {
      return Screen();
    }
    if (login_status == 1) {
      return Main();
    }
    if (login_status == 2) {
      return SignTrueWidget();
    }
    return Mobile();
  } */

  @override
  Widget build(BuildContext context) {
    if (login_status == -1) {
      return Screen();
    }
    if (login_status == 1) {
      return HomePage();
    }
    if (login_status == 2) {
    //  return SignTrueWidget();
      return HomePage();
    }
    return LoginPage();
  }
}
