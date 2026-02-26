import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_text.dart';

// class WContainer extends StatelessWidget {
//   const WContainer({
//     super.key,
//     this.textColor, // Agar berilmasa, tema rangini oladi
//     this.child,
//     this.text,
//     this.width = double.infinity,
//     this.height = 48,
//     this.color, // Agar berilmasa, tema primary rangini oladi
//     this.borderColor, // Agar berilmasa, shaffof
//     this.onTap,
//     this.radius = 30,
//     this.formKey,
//     this.isValidNotifier,
//   });

//   final ValueNotifier<bool>? isValidNotifier;
//   final Widget? child;
//   final String? text;
//   final double? width;
//   final Color? color, borderColor, textColor;
//   final double? height;
//   final double? radius;
//   final VoidCallback? onTap;
//   final GlobalKey<FormState>? formKey;

//   @override
//   Widget build(BuildContext context) {
//     // final theme = Theme.of(context);
//     //
//     // // Default ranglar
//     // final defaultColor = color ?? theme.colorScheme.primary; // Primary rang (binafsharang)
//     // final defaultTextColor = textColor ?? theme.colorScheme.onPrimary; // Primary ustidagi matn (oq)
//     // final defaultBorderColor = borderColor ?? Colors.transparent;
//     // final disabledColor = theme.disabledColor; // Disabled rang
//     // final disabledTextColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface.withOpacity(0.38);

//     return ValueListenableBuilder(
//       valueListenable: isValidNotifier ?? ValueNotifier(true),
//       builder: (context, isValid, _) {
//         return GestureDetector(
//           onTap: isValid ? onTap : null,
//           child: Container(
//             width: width?.w,
//             height: height?.h,
//             decoration: BoxDecoration(
//               color: isValid ? AppColors.primary : AppColors.lightSky, // Valid bo'lsa tema rangi, yo'qsa disabled
//               borderRadius: BorderRadius.circular(radius!),
//               // border: Border.all(color: defaultBorderColor),
//             ),
//             child: child ?? Center(
//               child: AppText(
//                 text: text!,
//                 fontSize: 15,
//                 fontWeight: 500,
//                 color: isValid ?  AppColors.white : AppColors.skyDark, // Tema ranglarini ishlatish
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class ContainerW extends StatelessWidget {
  const ContainerW({
    this.textColor,
    this.boxShadow,
    this.border,
    this.borderRadius,
    super.key,
    this.child,
    this.margin,
    this.text,
    this.gradient,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.onTap,
    this.radius = 30,
    this.formKey,
  });

  final List<BoxShadow>? boxShadow;
  final Widget? child;
  final Border? border;
  final String? text;
  final double? width;
  final Color? color, borderColor, textColor;
  final BorderRadius? borderRadius;
  final double? height;
  final double? radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);

    // // Default ranglar
    // final defaultColor = color ?? theme.cardColor; // Card rangi
    // final defaultBorder = border ?? Border.all(color: theme.dividerColor); // Divider rangi
    // final defaultShadow = boxShadow ?? [
    //   BoxShadow(
    //     color: theme.shadowColor, // Tema soyasi
    //     blurRadius: 10,
    //     offset: const Offset(0, 4),
    //   ),
    // ];
    // final textColor = theme.colorScheme.onSurface; // Surface ustidagi matn

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width?.w,
        height: height?.h,
        margin: margin,
        decoration: BoxDecoration(
          color: color, // Tema rangini ishlatish
          borderRadius: borderRadius ?? BorderRadius.circular(radius!),
          border:
              border ?? Border.all(color: borderColor ?? Colors.transparent),
          boxShadow: boxShadow, // Tema soyasini ishlatish
          gradient: gradient,
        ),
        child:
            child ??
            Center(
              child: AppText(
                text: text!,
                fontSize: 15,
                fontWeight: 500,
                color: textColor, // Tema matn rangi
              ),
            ),
      ),
    );
  }
}

///old version no theme
// class ContainerW extends StatelessWidget {
//   const ContainerW({
//     this.boxShadow,
//     this.border,
//     super.key,
//     this.child,
//     this.margin,
//     this.text,
//     this.width = double.infinity,
//     this.height,
//     this.color,
//     this.borderColor,
//     this.onTap,
//     this.radius = 30,
//     this.formKey,
//     // this.isValidNotifier,
//   });
//
//   // final ValueNotifier<bool>? isValidNotifier;
//   final List<BoxShadow>? boxShadow;
//   final Widget? child;
//   final Border? border;
//   final String? text;
//   final double? width;
//   final Color? color, borderColor;
//   final double? height;
//   final double? radius;
//   final VoidCallback? onTap;
//   final EdgeInsetsGeometry? margin;
//   final GlobalKey<FormState>? formKey;
//
//   @override
//   Widget build(BuildContext context) {
//     // final bool isValid = formKey?.currentState?.validate() ?? false;
//     return GestureDetector(
//       onTap:  onTap ,
//       child: Container(
//         width: width?.w,
//         height: height?.h,
//         margin: margin,
//         decoration: BoxDecoration(
//           color: color!,
//             borderRadius: BorderRadius.circular(radius!),
//             border: border ?? Border.all(color: borderColor!),
//             boxShadow: boxShadow
//         ),
//         child:
//         child ??
//             Center(
//               child: AppText(
//                 text: text!,
//                 fontSize: 15,
//                 fontWeight: 500,
//                 color: AppColors.white,
//               ),
//             ),
//       ),
//     );
//   }
// }
