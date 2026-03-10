import 'package:flutter/material.dart';

class CustomCheckboxGrid extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Map<String, String>? labels;
  final void Function(String) onToggle;

  const CustomCheckboxGrid({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onToggle,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(surface: Colors.white),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 520 ? 3 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.4,
                children:
                    options.map((option) {
                      final selected = selectedOptions.contains(option);
                      final label = labels?[option] ?? option;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () => onToggle(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selected ? Colors.blue : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: selected ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
