import 'package:flutter/material.dart';

class CustomSelect extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool enableSearch;
  final double maxPopupHeight;
  final String? hintText;
  final EdgeInsetsGeometry padding;
  final bool closeOnOutsideTap;
  final Duration animationDuration;

  const CustomSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.enableSearch = true,
    this.maxPopupHeight = 280,
    this.hintText,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    this.closeOnOutsideTap = true,
    this.animationDuration = const Duration(milliseconds: 180),
  });

  @override
  State<CustomSelect> createState() => _CustomSelectState();
}

class _CustomSelectState extends State<CustomSelect>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final TextEditingController _searchCtrl;
  late final FocusNode _searchFocus;

  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
    _filtered = widget.options;
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void didUpdateWidget(covariant CustomSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.options != widget.options) {
      _applyFilter();
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.options;
      } else {
        _filtered = widget.options
            .where((e) => e.toLowerCase().contains(q))
            .toList(growable: false);
      }
    });
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open && widget.enableSearch) {
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted) _searchFocus.requestFocus();
        });
      } else {
        _searchCtrl.clear();
      }
    });
  }

  void _close(String? v) {
    if (!_open) return;
    setState(() {
      _open = false;
      _searchCtrl.clear();
      _applyFilter();
      _searchFocus.unfocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.textTheme.labelMedium?.color?.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.value ?? (widget.hintText ?? 'Selecione'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              (widget.value == null)
                                  ? theme.hintColor
                                  : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0.0,
                      duration: widget.animationDuration,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: widget.animationDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child:
                  _open
                      ? Padding(
                        key: const ValueKey('dropdown'),
                        padding: const EdgeInsets.only(top: 8),
                        child: _DropdownPanel(
                          enableSearch: widget.enableSearch,
                          searchCtrl: _searchCtrl,
                          searchFocus: _searchFocus,
                          items: _filtered,
                          maxHeight: widget.maxPopupHeight,
                          onTapItem: (v) {
                            widget.onChanged.call(v);
                            setState(() {});
                            _close(v);
                          },
                        ),
                      )
                      : const SizedBox.shrink(key: ValueKey('closed')),
            ),
          ],
        ),

        if (_open && widget.closeOnOutsideTap)
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _close(null),
                  ),
                ),
                // A área do dropdown aqui em cima para que os eventos passem através
                Positioned(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(height: 48),
                      if (_open)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              ignoring: false,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: widget.maxPopupHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DropdownPanel extends StatelessWidget {
  final bool enableSearch;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final List<String> items;
  final double maxHeight;
  final ValueChanged<String> onTapItem;

  const _DropdownPanel({
    required this.enableSearch,
    required this.searchCtrl,
    required this.searchFocus,
    required this.items,
    required this.maxHeight,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final list = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              items.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Text(
                      'Nenhum resultado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder:
                        (_, __) =>
                            Divider(height: 1, color: theme.dividerColor),
                    itemBuilder: (context, index) {
                      final value = items[index];

                      return Container(
                        color: Colors.red,
                        child: GestureDetector(
                          key: ValueKey(value),
                          onTap: () {
                            onTapItem(value);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              value,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );

    if (!enableSearch) return list;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
          ),
          child: TextField(
            controller: searchCtrl,
            focusNode: searchFocus,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        list,
      ],
    );
  }
}
