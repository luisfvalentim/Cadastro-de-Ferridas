import 'package:flutter/material.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.obscureText,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.blue),
        hintStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.blue,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}
