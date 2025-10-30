import 'package:flutter/material.dart';

class OTPField extends StatelessWidget {
  final bool enabled;
  final List<TextEditingController> controllers;

  const OTPField({
    super.key,
    required this.enabled,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 35,
            child: TextField(
              controller: controllers[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Color(0xFF178C45)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
