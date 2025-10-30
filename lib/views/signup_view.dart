import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AuthController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 230,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF178C45), Color(0xFF38C172)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Image.asset('assets/takkeh_logo.png', width: 52, height: 52),
                    const SizedBox(height: 10),
                    const Text("مرحباً بك",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("أنشئ حسابك الآن",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),

            // Form
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Center(
                        child: Text("إنشاء حساب",
                            style: TextStyle(
                                color: Color(0xFF178C45),
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 25),

                      _buildField("اسم المستخدم", _controller.usernameCtrl, "الرجاء إدخال اسم المستخدم"),
                      const SizedBox(height: 15),

                      _buildField("رقم الهاتف المحمول", _controller.phoneCtrl, "رقم الهاتف مطلوب",
                          keyboard: TextInputType.phone),
                      const SizedBox(height: 15),

                      _buildField(
                        "كلمة المرور",
                        _controller.passCtrl,
                        "كلمة المرور مطلوبة",
                        obscure: true,
                        hint: "يجب أن تحتوي على 8 رموز على الأقل، رقم، حرف كبير، ورمز خاص (!@#\$%)",
                        customValidator: _controller.validatePassword,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        "تأكيد كلمة المرور",
                        _controller.confirmCtrl,
                        "أعد كتابة كلمة المرور",
                        obscure: true,
                        customValidator: (val) {
                          if (val == null || val.isEmpty) return "أعد كتابة كلمة المرور";
                          if (val != _controller.passCtrl.text) return "كلمتا المرور غير متطابقتين";
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      _buildButton("إرسال الكود", () {
                        _controller.sendOTP(context, _formKey, () => setState(() {}));
                      }, const Color(0xFF178C45)),

                      const SizedBox(height: 25),
                      if (_controller.otpEnabled)
                        OTPField(enabled: _controller.otpEnabled, controllers: _controller.otpControllers),

                      const SizedBox(height: 30),
                      _buildButton("إنشاء حساب", () => _controller.verifyOTP(context), const Color(0xFF38C172)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String validatorMsg,
      {bool obscure = false,
      String? hint,
      TextInputType keyboard = TextInputType.text,
      String? Function(String?)? customValidator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint ?? label,
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF178C45)),
        filled: true,
        fillColor: const Color(0xFFE5F3EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: customValidator ?? (value) => value == null || value.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
