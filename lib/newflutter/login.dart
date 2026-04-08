import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mytestflutter/newflutter/sp_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'VerifiPage.dart';
import 'base_page.dart';
import 'location_helper.dart';
import 'location_info.dart';
import 'login_view_model.dart';

class LoginPage extends BasePage<LoginViewModel> {
  const LoginPage({super.key});

  @override
  LoginViewModel createViewModel() => LoginViewModel();

  @override
  Widget buildContentView(BuildContext context, LoginViewModel viewModel) {
    return LoginContent(viewModel);
  }
}

class LoginContent extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginContent(this.viewModel, {super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  // Controllers and Focus Nodes
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // UI State
  bool _isPasswordVisible = false;
  bool _isOpen = true;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isFromMockProvider = false;

  // Timers
  Timer? _locationTimer;
  Timer? _timeoutTimer;

  // Stream Subscriptions
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<Position>? _systemPositionSubscription;
  StreamSubscription<bool>? _loginStateSubscription;

  // Widget lifecycle flag
  bool _mounted = true;

  // Helpers
  final LocationHelper _locationHelper = LocationHelper();
  final SpUtils _spUtils = SpUtils();

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _initData();
    _setupListeners();
  }

  void _initData() async {
    if (!_mounted) return;

    _isOpen = !(await _spUtils.getBool('allowUnauthorizedLogin', false));
    _isOpen=false;
    if (_isOpen && _mounted) {
      _showPermissionDialog();
    }
  }

  void _setupListeners() {
    _loginStateSubscription = widget.viewModel.booleanMutableLiveData.listen((value) {
      if (value && _mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (_mounted) {
            // 取消所有位置订阅
            _cancelAllSubscriptions();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => VerifiPage()),
                  (route) => false,
            );
          }
        });
      }
    });
  }

  void _cancelAllSubscriptions() {
    _positionSubscription?.cancel();
    _systemPositionSubscription?.cancel();
    _locationTimer?.cancel();
    _timeoutTimer?.cancel();

    _positionSubscription = null;
    _systemPositionSubscription = null;
    _locationTimer = null;
    _timeoutTimer = null;
  }

  void _updateLoginButton() {
    if (_mounted) {
      setState(() {});
    }
  }

  bool _isLoginEnabled() {
    return _phoneController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  void _login() async {
   // if (!_mounted) return;

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account cannot be empty')),
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('password cannot be empty')),
      );
      return;
    }

    String phone = _phoneController.text;
    String pwd = _passwordController.text;

    widget.viewModel.login(phone, pwd, _latitude, _longitude, _isFromMockProvider);
  }

  Future<void> _checkAndLogin() async {
    if (!_mounted) return;

    if (_isOpen) {
      await Permission.location.request();
      await Permission.contacts.request();

      if (Platform.isAndroid) {
        await Permission.phone.request();
      }

      if (!await Permission.location.isGranted) {
        if (_mounted) {
          _showPermissionDialog();
        }
      } else {
        try {
          _login();
        } catch (e) {
          debugPrint('Login error: $e');
        }
      }
    } else {
      _login();
    }
  }

  void _showProgressDialog() {
    if (!_mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _showPermissionDialog() async {
    if (!_mounted) return;

    List<String> missingPermissions = [];
    bool isGranted = await Permission.location.isGranted;
    bool isGrantedContacts = await Permission.contacts.isGranted;
    bool isGrantedPhone = await Permission.phone.isGranted;

    if (!isGranted) {
      missingPermissions.add('location');
    }
    if (!isGrantedContacts) {
      missingPermissions.add('contacts');
    }
    if (Platform.isAndroid && !isGrantedPhone) {
      missingPermissions.add('phone');
    }

    if (missingPermissions.isEmpty) {
      if (_mounted) {
        _locationHelper.checkAndEnableLocation(context, _startLocationUpdates);
      }
      return;
    }

    if (!_mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (missingPermissions.contains('location'))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red[300]),
                        const SizedBox(width: 8),
                        const Text('Location permission required'),
                      ],
                    ),
                  ),
                if (missingPermissions.contains('contacts'))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.contacts, color: Colors.red[300]),
                        const SizedBox(width: 8),
                        const Text('Contacts permission required'),
                      ],
                    ),
                  ),
                if (missingPermissions.contains('phone'))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: Colors.red[300]),
                        const SizedBox(width: 8),
                        const Text('Phone permission required'),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startLocationUpdates() async {
    if (!_mounted) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // 获取最后已知位置
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null && _mounted) {
      _timeoutTimer?.cancel();
      _processLocation(lastPosition);
    } else {
      debugPrint('getLastLocation 无缓存，等待实时回调...');
    }

    // 请求实时位置
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    _timeoutTimer = Timer(const Duration(seconds: 12), () {
      debugPrint('⚠️ 位置更新超时，尝试其他方法');
      if (_mounted) {
        _trySystemLocation();
      }
    });

    // 取消之前的订阅
    _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        _timeoutTimer?.cancel();
        _locationTimer?.cancel();
        if (_mounted) {
          _processLocation(position);
        }
      },
      onError: (error) {
        debugPrint('❌ 位置更新请求失败: $error');
        _timeoutTimer?.cancel();
        if (_mounted) {
          _trySystemLocation();
        }
      },
    );
  }

  void _processLocation(Position position) {
    // 关键修复：检查 mounted 状态
    if (!_mounted) return;

    // 使用 addPostFrameCallback 确保在正确的时机更新 UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isFromMockProvider = position.isMocked;
        });
      }
    });

    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    if (!_mounted) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && _mounted) {
        Placemark place = placemarks[0];
        LocationInfo locationInfo = LocationInfo(
          address: '${place.street}, ${place.locality}, ${place.country}',
          longitude: position.longitude,
          latitude: position.latitude,
          countries: place.country,
          provinces: place.administrativeArea,
          city: place.locality,
          county: place.subAdministrativeArea,
          street: place.street,
          isFromMockProvider: position.isMocked,
        );

        await _spUtils.putString('loca', locationInfo.toJsonString());
        debugPrint('位置信息保存成功: $locationInfo');
      }
    } catch (e) {
      debugPrint('地理编码失败: $e');
    }
  }

  Future<void> _trySystemLocation() async {
    if (!_mounted) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return;
    }

    debugPrint('尝试系统原生定位');

    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null && _mounted) {
      debugPrint('✅ 从系统获取到网络最后位置');
      _processLocation(lastPosition);
      return;
    }

    // 如果没有最后位置，请求实时更新
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    // 取消之前的订阅
    _systemPositionSubscription?.cancel();

    _systemPositionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        if (!_mounted) {
          _systemPositionSubscription?.cancel();
          return;
        }
        debugPrint('✅ 系统定位回调成功');
        _processLocation(position);
        _systemPositionSubscription?.cancel();
      },
    );

    Timer(const Duration(seconds: 30), () {
      if (_mounted) {
        _systemPositionSubscription?.cancel();
        debugPrint('⚠️ 系统定位超时');
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;

    // 取消所有订阅
    _loginStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _systemPositionSubscription?.cancel();
    _locationTimer?.cancel();
    _timeoutTimer?.cancel();

    // 释放控制器和焦点节点
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              // Phone Input
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) => _updateLoginButton(),
              ),
              const SizedBox(height: 20),
              // Password Input
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      if (_mounted) {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) => _updateLoginButton(),
              ),
              const SizedBox(height: 10),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoginEnabled() ? _checkAndLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign up
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}