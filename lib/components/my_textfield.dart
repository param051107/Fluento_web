import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Function(String)? onSubmitted;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFFFFFFFF)),
      onSubmitted: onSubmitted,

      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
          borderRadius: BorderRadius.circular(10),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF007AFF)),
          borderRadius: BorderRadius.circular(10),
        ),
        
        fillColor: const Color(0xFF1C1C1E),
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
      ),
    );
  }
}