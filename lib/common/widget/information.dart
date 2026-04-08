import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../function/common_dio_function.dart';
import '../map/Common_dio_map.dart';
import '../map/common_map.dart';
import 'mainewidget.dart';

class Information extends StatefulWidget {
  @override
  State<Information> createState() => _Information();
}

class _Information extends State<Information> {
  String path_one = '', path_two = '';
  bool _isExpanded = true;
  bool _isExpandedsecond = false;
  bool _isExpandedThird = false;
  bool isconClick = false;
  bool isconShow = false;
  bool isfirstClick = true;
  bool iskycClick = false;
  double infoHeight = 470;
  double contHeight = 880;
  double kycHeight = 510;
  final GlobalKey _widgetKey = GlobalKey();
  final GlobalKey _widgetKeycontact = GlobalKey();
  final GlobalKey _widgetKeykyc = GlobalKey();
  ValueNotifier<bool> next_btn_status = ValueNotifier(false);

  String name_str = '';
  String city_str = '';
  String address_str = '';
  String AadhaarNumbe = '';
  String PANCardno = '';
  String Pincode = '';

  late FocusNode _focusNode_name;
  late FocusNode _focusNode_city;
  late FocusNode _focusNode_address;
  late FocusNode _focusNode_pincode;
  late FocusNode _focusNode_AadhaarNumber;
  late FocusNode _focusNode_PANCardno;
  late TextEditingController _controller_name;
  late TextEditingController _controller_city;
  late TextEditingController _controller_address;
  late TextEditingController _controller_AadhaarNumber;
  late TextEditingController _controller_PANCardno;
  late TextEditingController _controller_Pincode;
  final ValueNotifier<bool> login_btn_status = ValueNotifier(false);
  String? _selectedValue = null;
  String? _gnederselectedValue = null;

  String? _relation1Value = null;
  String? _relation2Value = null;
  String? _relation3Value = null;
  String? _name1Value = null;
  String? _name2Value = null;
  String? _name3Value = null;
  String? _mobile1Value = null;
  String? _mobile2Value = null;
  String? _mobile3Value = null;
  String? selectedDate = null;
  List<String> _options = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Dadra and Nagar Haveli',
    'Daman and Diu',
    'Puducherry',
    'Telangana',
  ];

  final List<String> _genderoptions = ['Male', 'FeMale'];
  final List<String> _relationoptions = [
    'Parent',
    'Spouse',
    'Relatives',
    'Neighbors',
    'Colleagues',
    'Others',
  ];
  int serve_status = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _listScrollController.dispose();
    _listScrollController_rel.dispose();
    _controller_name.dispose();
    _controller_city.dispose();
    _controller_address.dispose();
    _controller_Pincode.dispose();
    _controller_AadhaarNumber.dispose();
  }

  @override
  void initState() {
    super.initState();
    getsta();

    _focusNode_name = FocusNode();
    _focusNode_city = FocusNode();
    _focusNode_address = FocusNode();
    _focusNode_pincode = FocusNode();
    _focusNode_AadhaarNumber = FocusNode();
    _controller_name = TextEditingController(text: name_str);
    _controller_city = TextEditingController(text: city_str);
    _controller_address = TextEditingController(text: address_str);
    _controller_Pincode = TextEditingController(text: Pincode);
    _controller_AadhaarNumber = TextEditingController(text: AadhaarNumbe);
    _focusNode_address.addListener(() {
      setState(() {});
    });
    _controller_name.addListener(() {
      setState(() {});
    });
    _controller_AadhaarNumber.addListener(() {
      setState(() {});
    });
    _controller_Pincode.addListener(() {
      setState(() {});
    });
    _controller_city.addListener(() {
      setState(() {});
    });

    _focusNode_PANCardno = FocusNode();
    _controller_PANCardno = TextEditingController(text: PANCardno);
    _controller_PANCardno.addListener(() {
      setState(() {});
    });
  }

  late GlobalKey _myKey;
  late GlobalKey _myKey2;
  late GlobalKey _myKey3;

  @override
  Widget build(BuildContext context) {
    _myKey = GlobalKey();
    _myKey2 = GlobalKey();
    _myKey3 = GlobalKey();

    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      color: main_color,

      child: Scaffold(
        backgroundColor: main_color,
        appBar: AppBar(
          backgroundColor: main_color,
          centerTitle: true,
          title: Text(
            'Your information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Image.asset('images/pre.png', width: 50, height: 50),
            ),
          ),
          leadingWidth: 55,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: main_color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isfirstClick) {
                              _isExpanded = !_isExpanded;
                              if (_isExpanded) {
                                _isExpandedsecond = false;
                                _isExpandedThird = false;
                              }
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Image.asset(
                                'images/info.png',
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 10),

                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              AnimatedRotation(
                                duration: Duration(milliseconds: 300),
                                turns: _isExpanded
                                    ? 0
                                    : isfirstClick
                                    ? 0.5
                                    : 0,
                                child: Image.asset(
                                  isfirstClick
                                      ? 'images/down.png'
                                      : 'images/down_gray.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),

                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 30, top: 8),
                            width: 2, //
                            height: _isExpanded ? infoHeight : 16,
                            decoration: BoxDecoration(
                              color: Color(0xff212f47), //
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          if (_isExpanded) inforView(),
                        ],
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isconClick) {
                              _isExpandedsecond = !_isExpandedsecond;
                              if (_isExpandedsecond) {
                                isfirstClick = false;
                                _isExpandedThird = false;
                                _isExpanded = false;
                              }
                            }

                            /* if (_isExpandedsecond)
                              contHeight = 16;
                            else
                              contHeight = _getcontactHeight();*/
                          });
                        },
                        child: Container(
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Image.asset(
                                serve_status == 2
                                    ? 'images/contact.png'
                                    : isconShow
                                    ? 'images/contact.png'
                                    : 'images/contact_gray.png',
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Contact Info',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Spacer(),
                              AnimatedRotation(
                                duration: Duration(milliseconds: 300),
                                turns: _isExpandedsecond
                                    ? 0
                                    : isconClick
                                    ? 0.5
                                    : 0,

                                child: Image.asset(
                                  isconClick
                                      ? 'images/down.png'
                                      : 'images/down_gray.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 30, top: 8),
                            width: 2, //
                            height: _isExpandedsecond ? contHeight : 16,
                            decoration: BoxDecoration(
                              color: Color(0xff212f47), //
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          if (_isExpandedsecond) ContactView(),
                        ],
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (iskycClick) {
                              _isExpandedThird = !_isExpandedThird;
                              if (_isExpandedThird) {
                                isconClick = false;
                                _isExpandedsecond = false;
                                _isExpanded = false;
                              }
                            }
                          });
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Image.asset(
                              iskycClick
                                  ? 'images/experience.png'
                                  : 'images/experience_gray.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Identify Verification',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Spacer(),
                            AnimatedRotation(
                              duration: Duration(milliseconds: 300),
                              turns: _isExpandedThird
                                  ? 0
                                  : iskycClick
                                  ? 0.5
                                  : 0,

                              child: Image.asset(
                                iskycClick
                                    ? 'images/down.png'
                                    : 'images/down_gray.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 30, top: 8),
                            width: 2, //
                            height: _isExpandedThird ? kycHeight : 0,
                            decoration: BoxDecoration(
                              color: Color(0xff212f47), //
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          if (_isExpandedThird) KycView(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),

            ValueListenableBuilder(
              valueListenable: next_btn_status,
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 20,
                    right: 20,
                    bottom: bottom + 15,
                  ),
                  child: InkWell(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: next_btn_status.value
                            ? Color(0xff856CF5)
                            : Color(0x60212F47),
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      if (next_btn_status.value) conf();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget basicInfoCellView(String title, String hix, String detail, int index) {
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        selectUpdatImageType(index);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Container(
              width: width - 60,
              height: 150,
              decoration: BoxDecoration(
                color: Color(0xff212F47),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [],
              ),
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (detail.length == 0)
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Image.asset(
                          'images/add.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.fill,
                        ),
                      ),
                    if (detail.length == 0)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '''Click''',
                                style: TextStyle(
                                  color: Color(0xff856CF5),
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ''' to upload Front of Aadhaar''',
                                style: TextStyle(
                                  color: Color(0xff727B8F),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (detail.length != 0)
                      Image.file(
                        File(detail),
                        width: width - 60,
                        height: 150,
                        fit: BoxFit.fill,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectUpdatImageType(int index) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              getImagePicker(true, index);
              Navigator.pop(context);
            },
            child: Text('Camera'),
          ),

          CupertinoActionSheetAction(
            onPressed: () {
              getImagePicker(false, index);
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

  void getImagePicker(bool camera, int index) async {
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
            if (index == 0) {
              setState(() {
                path_one = img.path;
              });
            }
            if (index == 1) {
              setState(() {
                path_two = img.path;
              });
            }
            changeBtnStatus();
          }
        });
  }

  void changeBtnStatus() {
    if (path_one.length == 0 ||
        PANCardno.length == 0 ||
        AadhaarNumbe.length == 0 ||
        selectedDate?.length == 0 ||
        _gnederselectedValue?.length == 0) {
      next_btn_status.value = false;
    } else {
      next_btn_status.value = true;
    }
  }

  Future<void> changeconStatus() async {
    if (Pincode.length == 0 ||
        _selectedValue?.length == 0 ||
        city_str.length == 0 ||
        name_str.length == 0 ||
        address_str?.length == 0) {
      isconClick = false;
    } else {
      final pref = await SharedPreferences.getInstance();
      pref.setInt('serve_status', 1);
      isconShow = true;
      isconClick = true;
      setState(() {});
    }
  }

  Future<void> changekycStatus() async {
    if (_relation1Value?.length == 0 ||
        _relation2Value?.length == 0 ||
        _relation3Value?.length == 0 ||
        _name1Value?.length == 0 ||
        _name3Value?.length == 0 ||
        _mobile1Value?.length == 0 ||
        _mobile2Value?.length == 0 ||
        _mobile3Value?.length == 0 ||
        _name2Value?.length == 0 ||
        _relation1Value == null ||
        _relation2Value == null ||
        _relation3Value == null ||
        _name1Value == null ||
        _name3Value == null ||
        _mobile1Value == null ||
        _mobile2Value == null ||
        _mobile3Value == null ||
        _name2Value == null) {
      iskycClick = false;
    } else {
      final pref = await SharedPreferences.getInstance();
      pref.setInt('serve_status', 2);
      iskycClick = true;
      setState(() {});
    }
  }

  Widget ContactView() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(left: 55, top: 18, right: 16),

      key: _widgetKeycontact,
      //
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Person 1',
            style: TextStyle(
              color: Color(0xFFffffff),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Relationship',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            key: _myKey,
            onTap: () {
              _showRelation(context, _myKey, 1);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _relation1Value ?? 'Please select',
                    style: TextStyle(
                      color: _relation1Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Full Name',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(1);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _name1Value ?? 'Please select',
                    style: TextStyle(
                      color: _name1Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Mobile',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(1);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _mobile1Value ?? 'Please select',
                    style: TextStyle(
                      color: _mobile1Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),
          Text(
            'Contact Person 2',
            style: TextStyle(
              color: Color(0xFFffffff),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Relationship',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            key: _myKey2,
            onTap: () {
              _showRelation(context, _myKey2, 2);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _relation2Value ?? 'Please select',
                    style: TextStyle(
                      color: _relation2Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Full Name',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(2);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _name2Value ?? 'Please select',
                    style: TextStyle(
                      color: _name2Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Mobile',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(2);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _mobile2Value ?? 'Please select',
                    style: TextStyle(
                      color: _mobile2Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Contact Person 3',
            style: TextStyle(
              color: Color(0xFFffffff),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Relationship',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            key: _myKey3,
            onTap: () {
              _showRelation(context, _myKey3, 3);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _relation3Value ?? 'Please select',
                    style: TextStyle(
                      color: _relation3Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Full Name',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(3);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _name3Value ?? 'Please select',
                    style: TextStyle(
                      color: _name3Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Mobile',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            onTap: () {
              getPhoneNUmber(2);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _mobile3Value ?? 'Please select',
                    style: TextStyle(
                      color: _mobile3Value == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget KycView() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(left: 55, top: 18, right: 16),

      key: _widgetKeycontact,
      //
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          basicInfoCellView('', '', path_one, 0),
          SizedBox(height: 15),

          Text(
            'Aadhaar Number',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_AadhaarNumber.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent, //
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_AadhaarNumber,
              focusNode: _focusNode_AadhaarNumber,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_AadhaarNumber.hasFocus) {
                  _focusNode_AadhaarNumber.requestFocus();
                }
                _controller_AadhaarNumber.selection = TextSelection.collapsed(
                  offset: _controller_AadhaarNumber.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
                setState(() {});
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Input Aadhaar Number',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                AadhaarNumbe = value;
                changeBtnStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Gender',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            key: _myKey,
            onTap: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              FocusScope.of(context).unfocus();
              Future.delayed(Duration.zero, () async {
                if (_myKey == null) {
                  _myKey = GlobalKey();
                  setState(() {});
                }
                bool isKeyboardVisible =
                    MediaQuery.of(context).viewInsets.bottom > 0;

                if (isKeyboardVisible)
                  await Future.delayed(Duration(milliseconds: 300));
              });

              _showGender(context, _myKey);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _gnederselectedValue ?? 'Please select',
                    style: TextStyle(
                      color: _gnederselectedValue == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Birthday',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),

          InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate ?? 'Please select',
                    style: TextStyle(
                      color: _gnederselectedValue == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'PAN Card Number',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_PANCardno.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent, //
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_PANCardno,
              focusNode: _focusNode_PANCardno,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_PANCardno.hasFocus) {
                  _focusNode_PANCardno.requestFocus();
                }
                _controller_PANCardno.selection = TextSelection.collapsed(
                  offset: _controller_PANCardno.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
                setState(() {});
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Input PAN Card Number',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                PANCardno = value;
                changeBtnStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget inforView() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(left: 55, top: 8, right: 16),

      key: _widgetKey,
      //
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full name',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_name.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_name,
              focusNode: _focusNode_name,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_name.hasFocus) {
                  _focusNode_name.requestFocus();
                }
                _controller_name.selection = TextSelection.collapsed(
                  offset: _controller_name.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please input',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                name_str = value;
                changeconStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Street address',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 98,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_address.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent, //
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_address,
              focusNode: _focusNode_address,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_address.hasFocus) {
                  _focusNode_address.requestFocus();
                }
                _controller_address.selection = TextSelection.collapsed(
                  offset: _controller_address.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please input',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                address_str = value;
                changeconStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          SizedBox(height: 16),

          Text(
            'City',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_city.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent, //
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_city,
              focusNode: _focusNode_city,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_city.hasFocus) {
                  _focusNode_city.requestFocus();
                }
                _controller_city.selection = TextSelection.collapsed(
                  offset: _controller_city.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please input',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                city_str = value;
                changeconStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          SizedBox(height: 16),

          Text(
            'State',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),
          InkWell(
            key: _myKey,
            onTap: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              FocusScope.of(context).unfocus();
              Future.delayed(Duration.zero, () async {
                if (_myKey == null) {
                  _myKey = GlobalKey();
                  setState(() {});
                }
                bool isKeyboardVisible =
                    MediaQuery.of(context).viewInsets.bottom > 0;

                if (isKeyboardVisible)
                  await Future.delayed(Duration(milliseconds: 300));
                _showState(context, _myKey);
              });
            },
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff18273F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedValue ?? 'Please select',
                    style: TextStyle(
                      color: _selectedValue == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 16),
                    child: Image.asset(
                      'images/white_down.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Pincode',
            style: TextStyle(
              color: Color(0xFF727B8F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(left: 15),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff18273F),
              border: Border.all(
                color: _focusNode_pincode.hasFocus
                    ? Color(0xff56CCE2)
                    : Colors.transparent, //
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller_Pincode,
              focusNode: _focusNode_pincode,
              inputFormatters: [],
              onTap: () {
                if (!_focusNode_pincode.hasFocus) {
                  _focusNode_pincode.requestFocus();
                }
                _controller_Pincode.selection = TextSelection.collapsed(
                  offset: _controller_Pincode.text.length,
                );
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please input',
                hintStyle: TextStyle(color: mes_color, fontSize: 14),
              ),

              style: TextStyle(color: Colors.white, fontSize: 14),

              onChanged: (value) {
                Pincode = value;
                changeconStatus();
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showState(BuildContext context, GlobalKey buttonKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        //
        final currentContext = buttonKey.currentContext;
        if (currentContext == null) {
          debugPrint('Button context is null');
          return;
        }

        final renderBox = currentContext.findRenderObject() as RenderBox?;
        if (renderBox == null) {
          debugPrint('RenderBox not found');
          return;
        }

        final offset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        final screenHeight = MediaQuery.of(context).size.height;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        double left = offset.dx;

        double top = offset.dy + size.height;
        bool showAbove = false;
        OverlayEntry? overlayEntry;

        final availableHeightBelow = screenHeight - top - bottomPadding;

        //
        if (availableHeightBelow < 70) {
          showAbove = true;
          final availableHeightAbove =
              offset.dy - MediaQuery.of(context).padding.top;
          top = offset.dy - min(400.0, availableHeightAbove); //
        }

        //
        final maxMenuHeight = showAbove
            ? min(400.0, offset.dy - MediaQuery.of(context).padding.top)
            : min(400.0, availableHeightBelow);

        overlayEntry = OverlayEntry(
          builder: (context) => Stack(
            children: [
              //
              GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: size.width,
                    constraints: BoxConstraints(maxHeight: maxMenuHeight),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF2A3952),
                      border: Border.all(color: Color(0xFF334155), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, showAbove ? -4 : 4), //
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //
                        Container(
                          height: maxMenuHeight - 2,
                          child: Scrollbar(
                            controller: _listScrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              controller: _listScrollController,

                              physics: ClampingScrollPhysics(),
                              reverse: showAbove,
                              //
                              itemCount: _options.length,
                              padding: EdgeInsets.only(top: 6, bottom: 6),
                              itemBuilder: (context, index) {
                                bool isSelected =
                                    _selectedValue == _options[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedValue = _options[index];
                                    });
                                    changeconStatus();
                                    overlayEntry?.remove();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    margin: EdgeInsets.only(
                                      left: isSelected ? 4 : 0,
                                      right: isSelected ? 4 : 0,
                                      top: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected
                                          ? Color(0xFF515B70)
                                          : Colors.transparent,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Text(
                                          _options[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
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
              ),
            ],
          ),
        );

        Overlay.of(context).insert(overlayEntry);
      });
    });
  }

  void _showGender(BuildContext context, GlobalKey buttonKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox =
          buttonKey.currentContext!.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      Size size = renderBox.size;

      final screenHeight = MediaQuery.of(context).size.height;
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      double left = offset.dx;

      double top = offset.dy + size.height;
      bool showAbove = false;
      OverlayEntry? overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            //
            GestureDetector(
              onTap: () {
                overlayEntry?.remove();
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFF2A3952),
                    border: Border.all(color: Color(0xFF334155), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    //   crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        reverse: showAbove,
                        itemCount: _genderoptions.length,
                        padding: EdgeInsets.only(top: 6, bottom: 6),
                        itemBuilder: (context, index) {
                          bool isSelected =
                              _gnederselectedValue == _genderoptions[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _gnederselectedValue = _genderoptions[index];
                              });
                              overlayEntry?.remove();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              margin: EdgeInsets.only(
                                left: isSelected ? 4 : 0,
                                right: isSelected ? 4 : 0,
                                top: 0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),

                                color: isSelected
                                    ? Color(0xFF515B70)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      _genderoptions[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry);
    });
  }

  final ScrollController _listScrollController = ScrollController();
  final ScrollController _listScrollController_rel = ScrollController();

  void _showRelation(BuildContext context, GlobalKey buttonKey, int type) {
    //
    RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    double left = offset.dx;

    double top = offset.dy + size.height;
    bool showAbove = false;
    OverlayEntry? overlayEntry;

    final availableHeightBelow = screenHeight - top - bottomPadding;

    //
    if (availableHeightBelow < 300) {
      showAbove = true;
      final availableHeightAbove =
          offset.dy - MediaQuery.of(context).padding.top;
      top = offset.dy - min(340.0, availableHeightAbove); //
    }

    //
    final maxMenuHeight = showAbove
        ? min(340.0, offset.dy - MediaQuery.of(context).padding.top)
        : min(340.0, availableHeightBelow);

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          //
          GestureDetector(
            onTap: () {
              overlayEntry?.remove();
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: size.width,
                constraints: BoxConstraints(maxHeight: maxMenuHeight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF2A3952),
                  border: Border.all(color: Color(0xFF334155), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: maxMenuHeight - 2,

                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _listScrollController_rel,
                        //    physics: NeverScrollableScrollPhysics(),
                        //
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,

                        itemCount: _relationoptions.length,
                        padding: EdgeInsets.only(top: 6, bottom: 6),

                        itemBuilder: (context, index) {
                          bool isSelected = false;
                          if (type == 1) {
                            isSelected =
                                _relation1Value == _relationoptions[index];
                          }
                          if (type == 2) {
                            isSelected =
                                _relation2Value == _relationoptions[index];
                          }
                          if (type == 3) {
                            isSelected =
                                _relation3Value == _relationoptions[index];
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                //  _selectedOption = _options[index];

                                if (type == 1) {
                                  _relation1Value = _relationoptions[index];
                                }
                                if (type == 2) {
                                  _relation2Value = _relationoptions[index];
                                }
                                if (type == 3) {
                                  _relation3Value = _relationoptions[index];
                                }

                                changekycStatus();
                              });
                              overlayEntry?.remove();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              margin: EdgeInsets.only(
                                left: isSelected ? 4 : 0,
                                right: isSelected ? 4 : 0,
                                top: 0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),

                                color: isSelected
                                    ? Color(0xFF515B70)
                                    : Colors.transparent,
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    _relationoptions[index],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
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
    );

    Overlay.of(context).insert(overlayEntry);
  }

  final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();

  void getPhoneNUmber(int type) async {
    final Contact? contact = await contactPicker.selectContact();
    if (contact != null) {
      if (type == 1) {
        _mobile1Value = contact.phoneNumbers!.first;
        _name1Value = contact.fullName;
      }
      if (type == 2) {
        _mobile2Value = contact.phoneNumbers!.first;
        _name2Value = contact.fullName;
      }
      if (type == 3) {
        _mobile3Value = contact.phoneNumbers!.first;
        _name3Value = contact.fullName;
      }

      setState(() {});
      changekycStatus();
    }
  }

  Future<void> conf() async {
    final prefs = await SharedPreferences.getInstance();
    final Random _random = Random();
    List<int> randomNumbers = List.generate(
      4,
      (_) => 301 + _random.nextInt(600),
    );

    prefs.setString("score_num", randomNumbers.toString());

    EasyLoading.show();
    try {
      final http = CommonDioFunction();

      const channel = MethodChannel('des_encryption');

      final result = await channel.invokeMethod('encryptDES', {
        'plaintext': randomNumbers.toString(),
        'key': 'DefaultKey',
      });

      String mobile = prefs.getString('mobile') ?? '';
      mobile = mobile.replaceFirst('00910', '');
      PublicDioMap model = await http.post({
        'xupWynFbpbDozt': result,
        'okmKoytFihph': mobile,
      }, scoreUrl);
      EasyLoading.dismiss();

      if (model.code == 0) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Main()),
          (root) => false,
        );
      } else {
        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, //
              onPrimary: Colors.white, //
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, //
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = formatDateToDMY(picked.toString().substring(0, 11));
      });
    }
  }

  String formatDateToDMY(String dateString) {
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        String year = parts[0];
        String month = parts[1];
        String day = parts[2];
        return '$day/$month/$year'; //
      }
    } catch (e) {}
    return dateString; //
  }

  bool get isKeyboardVisible1 {
    final mediaQuery = MediaQueryData.fromWindow(
      WidgetsBinding.instance.window,
    );
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return keyboardHeight > (screenHeight / 4);
  }

  Future<void> getsta() async {
    final prefs = await SharedPreferences.getInstance();
    serve_status = prefs.getInt('serve_status') ?? 0;
    if (serve_status == 1) {
      isfirstClick = false;
      isconClick = true;
      isconShow = true;

      _isExpanded = false;
      _isExpandedsecond = true;
      _isExpandedThird = false;
    }
    if (serve_status == 2) {
      isfirstClick = false;
      isconClick = false;
      iskycClick = true;

      _isExpanded = false;
      _isExpandedsecond = false;
      _isExpandedThird = true;
    }
    setState(() {});
  }
}
