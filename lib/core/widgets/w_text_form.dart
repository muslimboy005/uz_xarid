import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        // label: AppText(text: "name").paddingOnly(top: 20),
        // labelStyle: TextStyle(
        //   color: Colors.grey[600],
        //   fontSize: 16,
        //   fontWeight: FontWeight.w400,
        // ),
        // floatingLabelStyle: TextStyle(
        //   color: Colors.purple,
        //   fontSize: 14,
        //   fontWeight: FontWeight.w500,
        // ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: AppColors.black50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // contentPadding:
        //     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.black100, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.black100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.blue500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            // width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            // width: 2,
          ),
        ),
      ),
    );
  }
}

class WTextField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final String? title;
  final String? prefixIconOnePath;
  final String? prefixIconTwoPath;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool isObscureText;
  final bool autoFocus;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool hasClearButton;
  final bool hasError;
  final Color? fillColor;
  final Color? borderColor;
  final Color? cursorColor;
  final Color? borderNoFocusColor;
  final double borderRadius;
  final Widget? prefixIcon;
  final bool suffixIcon;
  final EdgeInsets? contentPadding;
  final TextAlign textAlign;
  final Alignment hintTextAlign;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool autoPrefix998;
  final Widget? suffixIconWidget;
  final String? text;
  final String? suffixImage;
  final bool richText;
  final String? prefixImage;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final VoidCallback? suffixImageTap;
  final Function(String)? onChanged;
  final VoidCallback? onClearTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final double? height; // Yangi parametr

  const WTextField({
    this.errorText,
    super.key,
    this.hintText,
    this.title,
    this.prefixImage,
    this.text,
    this.suffixImage,
    this.autoPrefix998 = false,
    this.prefixIconOnePath,
    this.prefixIconTwoPath,
    this.controller,
    this.borderNoFocusColor,
    this.suffixIconWidget,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.isObscureText = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.richText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.hasClearButton = false,
    this.hasError = false,
    this.fillColor,
    this.borderColor,
    this.cursorColor,
    this.borderRadius = 8,
    this.prefixIcon,
    this.suffixIcon = false,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.hintTextAlign = Alignment.centerLeft,
    this.textStyle,
    this.hintStyle,
    this.validator,
    this.onTap,
    this.suffixImageTap,
    this.onChanged,
    this.onClearTap,
    this.inputFormatters,
    this.focusNode,
    this.height, // Yangi parametr
  });

  @override
  State<WTextField> createState() => _WTextFieldState();
}

class _WTextFieldState extends State<WTextField> {
  late final FocusNode _focusNode;
  final bool _obscureText = true;
  bool _hasUserStartedTyping = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });

    if (widget.autoPrefix998) {
      widget.controller?.addListener(_handleTextChange);
    }
    final controller = widget.controller;
    if (controller != null) {
      controller.text = widget.text ?? '';
      if (widget.autoPrefix998) {
        controller.addListener(_handleTextChange);
      }
    }
  }

  void _handleTextChange() {
    if (!widget.autoPrefix998) return;

    final text = widget.controller?.text;
    if (text == null) return;

    if (!_hasUserStartedTyping && text.isNotEmpty && !text.startsWith('+998')) {
      bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(text);

      if (isNumeric) {
        _hasUserStartedTyping = true;
        final newText = '+998$text';
        widget.controller?.text = newText;
        widget.controller?.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        return;
      }
    }

    if (text.isEmpty) {
      _hasUserStartedTyping = false;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;
    final focusBorderColor = Theme.of(context).colorScheme.primary;

    final borderColor = widget.hasError
        ? AppColors.red
        : isFocused
        ? (widget.borderColor ?? focusBorderColor)
        : widget.borderNoFocusColor ?? context.borderColor;

    final effectiveFillColor = widget.fillColor ?? context.surfaceContainer;

    // TextFormField widgetini yaratish
    final textField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: widget.title ?? "",
          color: textColor,
          fontSize: 14,
          fontWeight: 700,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.suffixIcon ? _obscureText : false,
          autofocus: widget.autoFocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.isObscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          cursorColor: widget.cursorColor ?? focusBorderColor,
          textAlign: widget.textAlign,
          style:
              widget.textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return widget.errorText;
                }
                return null;
              },
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: widget.contentPadding ?? _calculateContentPadding(),

            hintText: widget.hintText,

            hintStyle:
                widget.hintStyle ??
                TextStyle(
                  color: hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),

            label: widget.richText && widget.hintText != null
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.hintText,
                          style: TextStyle(
                            color: hintColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : null,

            prefixIcon: widget.prefixImage != null
                ? Center(
                    // Center bilan o'rab qo'yamiz
                    child: AppImage(
                      size: 20,
                      path: widget.prefixImage!,
                      onTap: () {},
                    ),
                  )
                : null,
            prefixIconConstraints: widget.prefixImage != null
                ? BoxConstraints(
                    minWidth: 48, // Kenglikni bir oz oshiramiz
                    maxWidth: 48,
                  )
                : null,

            suffixIcon: widget.suffixIconWidget != null
                ? Center(child: widget.suffixIconWidget!)
                : (widget.suffixImage != null
                      ? Center(
                          child: AppImage(
                            path: widget.suffixImage!,
                            onTap: widget.suffixImageTap,
                          ),
                        )
                      : null),
            suffixIconConstraints:
                (widget.suffixIconWidget != null || widget.suffixImage != null)
                ? const BoxConstraints(minWidth: 48, maxWidth: 48)
                : null,

            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.red, width: 2),
            ),
          ),
        ),
      ],
    );

    // Agar height berilgan bo'lsa, ConstrainedBox bilan o'rash
    if (widget.height != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.height!,
          maxHeight: widget.height!,
        ),
        child: textField,
      );
    }

    return textField;
  }

  // Content padding ni hisoblash uchun helper method
  EdgeInsets _calculateContentPadding() {
    if (widget.height == null) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    }

    // Height berilgan bo'lsa, minimal paddingni ishlatamiz
    // TextField o'zi textni vertikal o'rtaga qo'yadi
    final verticalPadding = ((widget.height! - 24) / 2).clamp(10.0, 18.0);

    return EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding);
  }
}
