import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/kuromi_accents.dart';

class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 430;

    return KuromiDecoratedContainer(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131015), Color(0xFF8F6EA8)],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      patternColor: Colors.white,
      patternOpacity: 0.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final nameSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 20 : 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

          final tagline = Text(
            'Build momentum today.',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
            ),
          );

          return Row(
            children: [
              Expanded(child: nameSection),
              const SizedBox(width: 10),
              Flexible(child: tagline),
            ],
          );
        },
      ),
    );
  }
}

class HomeOverviewSection extends StatelessWidget {
  const HomeOverviewSection({
    super.key,
    required this.taskCount,
    required this.examCount,
  });

  final int taskCount;
  final int examCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final narrow = MediaQuery.sizeOf(context).width < 390;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF48FB1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.tertiaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _HomeStatCard(
                icon: Icons.task_alt_rounded,
                label: 'Open tasks',
                count: taskCount,
                color: const Color(0xFF1B5E20),
              ),
            ),
            SizedBox(width: narrow ? 8 : 12),
            Expanded(
              child: _HomeStatCard(
                icon: Icons.school_rounded,
                label: 'Upcoming exams',
                count: examCount,
                color: const Color(0xFF8E24AA),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 390;

    return KuromiDecoratedContainer(
      borderRadius: BorderRadius.circular(18),
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Theme.of(context).dividerColor.withValues(alpha: 0.7)
              : colors.primary.withValues(alpha: 0.26),
          width: 1.25,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x22000000)
                : color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      patternColor: color,
      patternOpacity: 0.09,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: compact ? 22 : 26,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeActionsSection extends StatelessWidget {
  const HomeActionsSection({
    super.key,
    required this.onSubjectsTap,
    required this.onTasksTap,
    required this.onExamsTap,
  });

  final VoidCallback onSubjectsTap;
  final VoidCallback onTasksTap;
  final VoidCallback onExamsTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF48FB1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.tertiaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _HomeActionTile(
          icon: Icons.menu_book_rounded,
          title: 'Subjects',
          subtitle: 'Organize classes and modules',
          onTap: onSubjectsTap,
        ),
        const SizedBox(height: 10),
        _HomeActionTile(
          icon: Icons.checklist_rounded,
          title: 'Tasks',
          subtitle: 'Track assignments and progress',
          onTap: onTasksTap,
        ),
        const SizedBox(height: 10),
        _HomeActionTile(
          icon: Icons.description_rounded,
          title: 'Exams',
          subtitle: 'Plan tests and deadlines',
          onTap: onExamsTap,
        ),
      ],
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: isDark ? 1.2 : 0.6,
        shadowColor: isDark
            ? const Color(0x22000000)
            : colors.primary.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark
                ? Theme.of(context).dividerColor.withValues(alpha: 0.7)
                : colors.primary.withValues(alpha: 0.24),
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: KuromiDecoratedContainer(
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            patternColor: const Color(0xFFF48FB1),
            patternOpacity: 0.08,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(
                    0xFFF48FB1,
                  ).withValues(alpha: 0.13),
                  child: Icon(icon, color: colors.tertiaryText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
