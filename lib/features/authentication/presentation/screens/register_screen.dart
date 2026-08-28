import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/auth_controller.dart'; // Add this import
import '../providers/auth_state.dart'; // Add this import

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
  final _confirmPassCtrl = TextEditingController(); // Add this controller

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose(); // Dispose the new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state to react to changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحساب بنجاح! سيتم توجيهك لتسجيل الدخول.')),
        );
        context.go(AppRoutes.login);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
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
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
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
                  controller: _confirmPassCtrl, // New field for password confirmation
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_passCtrl.text != _confirmPassCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
                            );
                            return;
                          }
                          await ref.read(authControllerProvider.notifier).register(
                                fullName: _nameCtrl.text,
                                phone: _phoneCtrl.text,
                                email: _emailCtrl.text,
                                password: _passCtrl.text,
                                confirmPassword: _confirmPassCtrl.text,
                              );
                        },
                  child: isLoading ? const CircularProgressIndicator() : const Text('تسجيل'),
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