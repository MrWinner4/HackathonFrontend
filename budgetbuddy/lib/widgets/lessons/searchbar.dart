import 'package:flutter/material.dart';
import '../../colorscheme.dart';

class LessonSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const LessonSearchBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Search lessons and episodes...',
          hintStyle: TextStyle(
            color: AppColorScheme.secondaryVariant,
            fontSize: 16,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: AppColorScheme.secondaryVariant,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppColorScheme.onPrimary,
        ),
        cursorColor: AppColorScheme.accent,
      ),
    );
  }
}
