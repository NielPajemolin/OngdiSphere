import 'package:flutter/material.dart';
import 'package:ongdisphere/colorpalette/color_palette.dart';

class MyTextfield extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        style: const TextStyle(fontSize: 15.5),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7E4FA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7E4FA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
          filled: true,
          fillColor: Colors.white,
          labelText: labeltext,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.5),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: colors.primary, size: 20)
              : null,
        ),
      ),
    );
  }
}
