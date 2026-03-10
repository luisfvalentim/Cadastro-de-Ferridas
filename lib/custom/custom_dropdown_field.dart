import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isEnabled;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        hint: Text(hint ?? '', style: const TextStyle(color: Colors.grey)),
        items: items,
        onChanged: isEnabled ? onChanged : null,
        validator: validator,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      ),
    );
  }
}
