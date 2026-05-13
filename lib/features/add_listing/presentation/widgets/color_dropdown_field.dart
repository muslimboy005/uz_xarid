import 'package:flutter/material.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/features/add_listing/domain/entities/color_entity.dart';

/// Rangni tanlash dropdown – ranglar ro'yxati va tanlangan id bilan.
class ColorDropdownField extends StatelessWidget {
  const ColorDropdownField({
    super.key,
    required this.label,
    required this.surface,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
    this.colors,
    this.value,
    this.onChanged,
    this.isLoading = false,
    this.errorMessage,
  });

  final String label;
  final Color surface;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;
  final List<ColorEntity>? colors;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool isLoading;
  final String? errorMessage;

  static Color _parseHex(String hex) {
    final c = hex.replaceFirst(RegExp(r'^#+'), '#');
    if (c.length == 7 && c.startsWith('#')) {
      return Color(int.parse(c.substring(1), radix: 16) + 0xFF000000);
    }
    return const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final items = colors ?? [];
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: label, fontSize: 14, fontWeight: 600, color: textColor),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : borderColor,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: isLoading
                  ? Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppText(
                          text: 'Yuklanmoqda...',
                          fontSize: 14,
                          fontWeight: 400,
                          color: textSecondary,
                        ),
                      ],
                    )
                  : AppText(
                      text: 'Rang tanlang',
                      fontSize: 14,
                      fontWeight: 400,
                      color: textSecondary,
                    ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textSecondary,
              ),
              items: items
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _parseHex(c.hex),
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppText(
                              text: c.name,
                              fontSize: 14,
                              fontWeight: 500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          AppText(
            text: errorMessage!,
            fontSize: 12,
            fontWeight: 400,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ],
    );
  }
}
