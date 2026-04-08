import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mytestflutter/newflutter/sp_utils.dart';

import 'color_page.dart';
import 'login_view_model.dart';

// 假设的主页，请替换为您项目中的实际主页
// import 'package:your_app/pages/main_page.dart';

/// 模拟的 ViewModel，负责业务逻辑和状态通知
/*class VerifiViewModel extends ChangeNotifier {
  String? _imageUrl;
  bool _isLoggedIn = false;

  String? get imageUrl => _imageUrl;
  bool get isLoggedIn => _isLoggedIn;

  /// 初始化时加载图片（模拟 Glide 加载）
  void fetchImage() {
    // 模拟网络图片，可替换为本地资源或实际 URL
    Future.delayed(Duration.zero, () {
      _imageUrl = 'https://via.placeholder.com/50'; // 占位图，请替换为实际图片
      notifyListeners();
    });
  }

  /// 验证码登录方法
  Future<void> login2(String code) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));
    // 登录成功设置状态
    _isLoggedIn = true;
    notifyListeners();
  }
}*/

class VerifiPage extends StatefulWidget {
  const VerifiPage({Key? key}) : super(key: key);

  @override
  _VerifiPageState createState() => _VerifiPageState();
}

class _VerifiPageState extends State<VerifiPage> {
  final TextEditingController _codeController = TextEditingController();
  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  //  _viewModel.fetchImage();
    _viewModel.addListener(_onViewModelChange);
    _setupListeners();
  }

  StreamSubscription<bool>? _loginStateSubscription;

  void _setupListeners() {
    _loginStateSubscription = _viewModel.booleanMutableLiveData.listen((value) {
      if (value ) {
        Future.delayed(const Duration(seconds: 1), () {
          SpUtils().putInt('login_status',1);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ColorPage()),
                  (route) => false,
            );

        });
      }
    });
  }



  @override
  void dispose() {
    _loginStateSubscription?.cancel();
    _viewModel.removeListener(_onViewModelChange);
    _codeController.dispose();
    super.dispose();
  }

  /// 监听 ViewModel 状态变化，登录成功后跳转
  void _onViewModelChange() {
/*    if (_viewModel.isLoggedIn) {
      // 跳转到主页并移除当前页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainsPage()), // 替换为实际主页
      );
    }*/
  }

  /// 处理登录按钮点击
  void _login() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('code is not empty')),
      );
      return;
    }
   // _viewModel.login2(code);
    _viewModel.verilogin(code);
  }

  /// 处理返回按钮（跳转到登录页）
  void _onBackPressed() {
    // 根据您的路由配置调整，例如：
    // Navigator.pushReplacementNamed(context, '/login');
    // 或直接 pop 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 主要内容区域（对应原 framemain）
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                  padding: const EdgeInsets.all(16),
                  // 外层渐变边框（对应 framemain 的 foreground）
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 2,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF409EFF),
                        Color(0x20409EFF),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 图片（原 ImageView）
                      AnimatedBuilder(
                        animation: _viewModel,
                        builder: (context, child) {
                          return Image.network(
                            _viewModel.imageUrl ?? 'https://via.placeholder.com/50',
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.mail, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      // 输入框容器（对应内层 frame，也带渐变边框）
                      Container(
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 2,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF409EFF),
                              Color(0x20409EFF),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 18),
                            // 盾牌图标（原 ImageView with shield）
                            Image.asset(
                              'assets/shield.png', // 请将图片放入 assets 并配置 pubspec.yaml
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.shield, size: 24),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Verification Code',
                                  hintStyle: TextStyle(color: Color(0xFFB5B5B5)),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF262626),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 说明文字
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Enter the 6-digit code generated by the Google Authenticator app to complete the login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 底部确认按钮（原 TextView 在 RelativeLayout 底部）
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 示例主页，请替换为您项目中的实际主页
class MainsPage extends StatelessWidget {
  const MainsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}