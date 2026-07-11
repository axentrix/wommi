import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class NumberScrollPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const NumberScrollPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<NumberScrollPicker> createState() => _NumberScrollPickerState();
}

class _NumberScrollPickerState extends State<NumberScrollPicker> {
  late FixedExtentScrollController _scrollController;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialValue - widget.minValue,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator box
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: Border.all(
                color: WommiColors.cyan,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Vertical scroll wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 60,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              final newValue = widget.minValue + index;
              if (_currentValue != newValue) {
                setState(() {
                  _currentValue = newValue;
                });
                widget.onChanged(newValue);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.maxValue - widget.minValue + 1,
              builder: (context, index) {
                final value = widget.minValue + index;
                final isSelected = value == _currentValue;

                return Center(
                  child: Text(
                    '$value',
                    style: GoogleFonts.unbounded(
                      fontSize: isSelected ? 42 : 28,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? WommiColors.cyanDark
                          : WommiColors.inkDim.withOpacity(0.4),
                      height: 1.0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
