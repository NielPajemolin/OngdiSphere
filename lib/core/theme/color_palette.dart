// lib/colorpalette/app_colors.dart
import 'package:flutter/material.dart';


class AppColors extends ThemeExtension<AppColors> {
final Color primary;
final Color secondary;
final Color surface;
final Color tertiary;
final Color primaryText;
final Color secondaryText;
final Color tertiaryText;


const AppColors({
required this.primary,
required this.secondary,
required this.surface,
required this.tertiary,
required this.primaryText,
required this.secondaryText,
required this.tertiaryText,
});


@override
AppColors copyWith({
Color? primary,
Color? secondary,
Color? surface,
Color? tertiary,
Color? primaryText,
Color? secondaryText,
Color? tertiaryText,

} ) {
return AppColors(
primary: primary ?? this.primary,
secondary: secondary ?? this.secondary,
surface: surface ?? this.surface,
tertiary: tertiary ?? this.tertiary,
primaryText: primaryText ?? this.primaryText,
secondaryText: secondaryText ?? this.secondaryText,
tertiaryText: tertiaryText ?? this.tertiaryText,
);
}


@override
AppColors lerp(ThemeExtension<AppColors>? other, double t) {
if (other is! AppColors) return this;


return AppColors(
primary: Color.lerp(primary, other.primary, t)!,
secondary: Color.lerp(secondary, other.secondary, t)!,
surface: Color.lerp(surface, other.surface, t)!,
tertiary: Color.lerp(tertiary, other.tertiary, t)!,
primaryText: Color.lerp(primaryText, other.primaryText, t)!,
secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
tertiaryText: Color. lerp(tertiaryText, other.tertiaryText, t)!,
);
}
}
