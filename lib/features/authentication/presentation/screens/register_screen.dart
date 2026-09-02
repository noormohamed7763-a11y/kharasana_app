import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// نصّ الحقل الاختياري، أو `null` إن كان فارغاً.
  ///
  /// كانت الحقول تُرسَل بنصّها الخام: تركُ البريد فارغاً يُرسل `""` لا
  /// `null`، والخادم يرفض السلسلة الفارغة كبريد غير صالح — فيُمنع التسجيل
  /// بحقل لم يطلبه أصلاً. والدالة تشذّب المسافات أيضاً.
  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _register() async {
    final fullName = _nameCtrl.text.trim();
    final email = _optional(_emailCtrl);
    final phone = _optional(_phoneCtrl);

    if (fullName.isEmpty) {
      _showMessage('يرجى إدخال الاسم الكامل');
      return;
    }
    // الخادم يحتاج معرّفاً واحداً على الأقل لتسجيل الدخول لاحقاً.
    if (email == null && phone == null) {
      _showMessage('يرجى إدخال رقم الهاتف أو البريد الإلكتروني');
      return;
    }
    if (_passCtrl.text.isEmpty) {
      _showMessage('يرجى إدخال كلمة المرور');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      _showMessage('كلمتا المرور غير متطابقتين');
      return;
    }

    await ref.read(authControllerProvider.notifier).register(
          fullName: fullName,
          phone: phone,
          email: email,
          password: _passCtrl.text,
          confirmPassword: _confirmPassCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthRegistered) {
        _showMessage('تم إنشاء الحساب بنجاح! سيتم توجيهك لتسجيل الدخول.');
        context.go(AppRoutes.login);
      } else if (next is AuthError) {
        _showMessage(next.message);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '967XXXXXXXXX',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني (اختياري)',
                    hintText: 'example@mail.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPassCtrl,
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('تسجيل'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('لديك حساب؟ تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}