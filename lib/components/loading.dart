import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      body: const Center(child: CircularProgressIndicator(),),
    );
  }
}