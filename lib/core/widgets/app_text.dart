// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uz_xarid/core/theme/app_fonts.dart';

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.color, // Agar berilmasa, tema rangini oladi
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.textAlign,
    this.height,
    this.overflow,
    this.decoration,
    this.letterSpacing,
    this.style,
    this.decorationColor,
    this.onTap,
  });

  final String text;
  final Color? color;
  final double? fontSize;
  final double? height;
  final int? fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final TextStyle? style;
  final Color? decorationColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fw = AppFonts.getFontWeight(fontWeight);
    
    // Agar color berilmagan bo'lsa, tema rangini olish
    // final textColor = color ?? Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Text(    
        // context.tr(text),
        text,
        style: style ?? TextStyle(
          height: height,
          fontSize: fontSize?.sp,
          fontWeight: fw,
          color: color, // Tema rangini ishlatish
          fontFamily: AppFonts.getFontFamily(fontWeight),
          letterSpacing: letterSpacing,
          decoration: decoration ?? TextDecoration.none,
          decorationColor: decorationColor ?? color,
        ),
        maxLines: maxLines ?? 1,
        textAlign: textAlign,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}
