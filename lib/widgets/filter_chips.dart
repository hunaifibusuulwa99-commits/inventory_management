import 'package:flutter/material.dart';

import '../theme.dart';

/// Horizontal row of filter chips (All / Low stock / ...).
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: option == selected ? AppColors.green2 : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: option == selected ? const Color(0xFFC9E5D4) : AppColors.line,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: option == selected ? AppColors.green : const Color(0xFF657168),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
