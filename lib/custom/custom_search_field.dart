import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final String hint;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const CustomSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }
}
