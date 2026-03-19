import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';

class SubjectFilterDropdown extends StatelessWidget {
  const SubjectFilterDropdown({
    super.key,
    required this.value,
    required this.subjects,
    required this.onChanged,
  });

  final String? value;
  final List<Subject> subjects;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, colors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Filter',
            style: TextStyle(
              color: colors.tertiaryText.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: value,
            hint: const Text('Filter by subject'),
            isExpanded: true,
            borderRadius: BorderRadius.circular(14),
            style: TextStyle(
              color: colors.tertiaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.primary,
              size: 24,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primary, width: 1.4),
              ),
              prefixIcon: Icon(
                Icons.menu_book_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All subjects'),
              ),
              ...subjects.map(
                (subject) => DropdownMenuItem<String?>(
                  value: subject.id,
                  child: Text(subject.name),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
        ),
    );
  }
}
