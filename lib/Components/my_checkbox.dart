import 'package:flutter/material.dart';

class MyCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const MyCheckbox({Key? key, required this.value, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2, // Увеличение размера чекбокса на 20%
            child: Checkbox(
              value: value,
              activeColor: const Color(0xFF4280EF),
              onChanged: onChanged,
            ),
          ),

          Expanded(
            child: Text(
              'Agree the terms of use and privacy policy',
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
