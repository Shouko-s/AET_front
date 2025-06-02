import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String labelText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.labelText,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          TextField(
            controller: widget.controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(
                  Radius.circular(screenWidth * 0.025),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF00AEF7)),
                borderRadius: BorderRadius.all(
                  Radius.circular(screenWidth * 0.025),
                ),
              ),
              fillColor: Colors.grey.shade100,
              filled: true,
              hintText: widget.hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              suffixIcon:
                  widget.obscureText
                      ? IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      )
                      : null,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.038,
            ),
          ),
        ],
      ),
    );
  }
}
