import 'package:flutter/material.dart';

class CustomInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const CustomInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 100,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style:
                  labelStyle ??
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
