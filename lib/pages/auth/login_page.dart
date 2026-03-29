import 'package:flutter/material.dart';
import 'package:hussam_clinc/data/TimetableWidgt.dart';
import 'package:hussam_clinc/utils/responsive.dart';
import '../../services/AuthService.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال اسم المستخدم وكلمة المرور')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await AuthService().login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TimetableWidgt(title: 'الرئيسية')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في اسم المستخدم أو كلمة المرور'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isMobile 
        ? SingleChildScrollView(
            child: Column(
              children: [
                _buildBrandingSection(isMobile: true),
                _buildLoginFormSection(isMobile: true),
              ],
            ),
          )
        : Row(
            children: [
              Expanded(child: _buildBrandingSection(isMobile: false)),
              Expanded(child: _buildLoginFormSection(isMobile: false)),
            ],
          ),
    );
  }

  Widget _buildBrandingSection({required bool isMobile}) {
    return Container(
      width: double.infinity,
      height: isMobile ? 300 : double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D9D99), Color(0xFF167774)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital, size: isMobile ? 60 : 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            "نظام إدارة عيادة حسام",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo', // Use Cairo for Arabic
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "حلول ذكية لإدارة عيادتك بكفاءة",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormSection({required bool isMobile}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 100,
          vertical: isMobile ? 40 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "تسجيل الدخول",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D9D99),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "أهلاً بك مجدداً، يرجى إدخال بياناتك للمتابعة",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            _buildTextField(
              controller: _usernameController,
              label: "اسم المستخدم",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _passwordController,
              label: "كلمة المرور",
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D9D99),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "دخول",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1D9D99)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D9D99), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
