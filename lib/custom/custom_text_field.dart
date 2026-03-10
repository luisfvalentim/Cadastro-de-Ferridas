import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onToggleObscure;
  final bool readOnly;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.inputFormatters,
    this.obscureText = false,
    this.onToggleObscure,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
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
        // se quiser um botão de mostrar/ocultar senha ou outro ícone
        suffixIcon: suffix,
      ),
    );
  }
}
