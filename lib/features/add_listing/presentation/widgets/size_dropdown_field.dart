import 'package:flutter/material.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';

/// O'lchamni tanlash dropdown – o'lchamlar ro'yxati va tanlangan id bilan.
class SizeDropdownField extends StatelessWidget {
  const SizeDropdownField({
    super.key,
    required this.label,
    required this.surface,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
    this.sizes,
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
  final List<SizeEntity>? sizes;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final items = sizes ?? [];
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
                      text: 'O\'lchamni tanlang',
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
                    (s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: AppText(
                        text: s.name,
                        fontSize: 14,
                        fontWeight: 500,
                        color: textColor,
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
