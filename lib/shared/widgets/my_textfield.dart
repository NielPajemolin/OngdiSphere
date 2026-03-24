import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

class MyTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labeltext;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labeltext,
    required this.obscureText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText && !_isPasswordVisible,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onEditingComplete: widget.onEditingComplete,
        style: const TextStyle(fontSize: 15.5),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF4C7DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF4C7DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
          filled: true,
          fillColor: colors.surface.withValues(alpha: 0.85),
          labelText: widget.labeltext,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.5),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: colors.primary, size: 20)
              : null,
          suffixIcon: widget.obscureText
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
