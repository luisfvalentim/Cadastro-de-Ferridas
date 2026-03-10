import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CustomMultiSelectField<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final List<T> initialValues;
  final List<MultiSelectItem<T>> items;
  final void Function(List<T>) onConfirm;
  final String? Function(List<T>?)? validator;
  final bool isEnabled;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    this.hint,
    required this.initialValues,
    required this.items,
    required this.onConfirm,
    this.validator,
    this.isEnabled = true,
  });

  @override
  State<CustomMultiSelectField<T>> createState() =>
      _CustomMultiSelectFieldState<T>();
}

class _CustomMultiSelectFieldState<T> extends State<CustomMultiSelectField<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialValues);
  }

  Future<void> _openDialog() async {
    final results = await showDialog<List<T>>(
      context: context,
      builder:
          (context) => MultiSelectDialog<T>(
            items: widget.items,
            initialValue: _selected,
            searchable: true,
            title: Text(widget.label),
          ),
    );

    if (results != null) {
      setState(() => _selected = results);
      widget.onConfirm(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? _openDialog : null,
      child: AbsorbPointer(
        child: TextFormField(
          enabled: widget.isEnabled,
          readOnly: true,
          validator: (_) => widget.validator?.call(_selected),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Selecione...',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: const TextStyle(color: Colors.blue),
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ),
          controller: TextEditingController(
            text:
                _selected.isEmpty
                    ? ''
                    : _selected.map((e) => e.toString()).join(', '),
          ),
        ),
      ),
    );
  }
}
