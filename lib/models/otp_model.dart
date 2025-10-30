import 'dart:math';

class OTP {
  int? code;

  int generateCode() {
    final random = Random();
    code = 100000 + random.nextInt(900000);
    return code!;
  }

  bool verify(String enteredCode) {
    if (code == null) return false;
    return enteredCode == code.toString();
  }
}
