import 'package:flutter/material.dart';
import '../theme.dart';

class ChipButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ChipButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? WommiColors.roseSoft : Colors.white,
          border: Border.all(
            color: isSelected ? WommiColors.rose : WommiColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? WommiColors.ink : WommiColors.inkDim,
          ),
        ),
      ),
    );
  }
}
