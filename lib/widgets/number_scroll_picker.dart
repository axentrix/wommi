import 'package:flutter/material.dart';
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
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: WommiColors.line, width: 1.5),
                bottom: BorderSide(color: WommiColors.line, width: 1.5),
              ),
            ),
          ),
          // Number wheel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous number (dim)
              SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '${_currentValue > widget.minValue ? _currentValue - 1 : ''}',
                    style: TextStyle(
                      fontFamily: 'Unbounded',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xFFD8D2E8),
                    ),
                  ),
                ),
              ),
              // Current number (main)
              SizedBox(
                width: 90,
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 80,
                  perspective: 0.005,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _currentValue = widget.minValue + index;
                    });
                    widget.onChanged(_currentValue);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.maxValue - widget.minValue + 1,
                    builder: (context, index) {
                      final value = widget.minValue + index;
                      return Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontFamily: 'Unbounded',
                            fontWeight: FontWeight.w800,
                            fontSize: 60,
                            color: WommiColors.cyanDark,
                            height: 1.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Next number (dim)
              SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '${_currentValue < widget.maxValue ? _currentValue + 1 : ''}',
                    style: TextStyle(
                      fontFamily: 'Unbounded',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xFFD8D2E8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
