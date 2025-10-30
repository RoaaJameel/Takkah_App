import 'dart:math';
import 'package:flutter/material.dart';

class AuthController {
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  bool otpEnabled = false;
  int? generatedCode;

  void dispose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
  }

  int _generateCode() {
    final random = Random();
    return 100000 + random.nextInt(900000);
  }

  bool _isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{8,}$');
    return regex.hasMatch(password);
  }

  void sendOTP(BuildContext context, GlobalKey<FormState> formKey, VoidCallback onOtpEnabled) {
    if (formKey.currentState!.validate()) {
      generatedCode = _generateCode();
      otpEnabled = true;
      debugPrint("OTP Code (debug): $generatedCode");

      onOtpEnabled();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("كود التحقق (تجريبي)"),
          content: Text("تم توليد الكود: $generatedCode\n(يظهر أيضاً في الـ console)"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("حسناً"),
            ),
          ],
        ),
      );
    }
  }

  void verifyOTP(BuildContext context) {
    if (!otpEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ أرسل الكود أولاً")),
      );
      return;
    }

    String enteredCode = otpControllers.map((c) => c.text).join();

    if (enteredCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ أدخل الكود كاملاً")),
      );
      return;
    }

    if (enteredCode == generatedCode.toString()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 تم إنشاء الحساب بنجاح (محاكاة)")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ الكود خاطئ، حاول مجدداً")),
      );
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "كلمة المرور مطلوبة";
    if (!_isStrongPassword(value)) return "كلمة المرور ضعيفة، استخدم رموزاً قوية";
    return null;
  }

  // ✅ أضفنا دالة تسجيل الدخول هنا
  bool login(String username, String password) {
    // تحقق تجريبي فقط
    if ((username == "takkeh" || username == "0590000000") && password == "12345") {
      debugPrint("✅ تسجيل دخول ناجح");
      return true;
    } else {
      debugPrint("❌ فشل تسجيل الدخول");
      return false;
    }
  }
}
