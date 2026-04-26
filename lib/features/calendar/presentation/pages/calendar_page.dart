import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/subject/subject.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';

enum _DeadlineType { task, exam }

enum _AgendaFilter { all, tasks, exams }

class _DeadlineEntry {
  const _DeadlineEntry({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.dateTime,
    required this.type,
    this.task,
    this.exam,
  });

  final String id;
  final String title;
  final String subjectName;
  final DateTime dateTime;
  final _DeadlineType type;
  final Task? task;
  final Exam? exam;
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  _AgendaFilter _agendaFilter = _AgendaFilter.all;

  Widget? _buildMarker({
    required DateTime day,
    required List<_DeadlineEntry> events,
    required Color accent,
    required Color textColor,
    required Color taskColor,
    required Color examColor,
    required double selectedChipHeight,
    required double selectedChipFontSize,
  }) {
    if (events.isEmpty) {
      return null;
    }

    final visibleEvents = events.take(isSameDay(day, _selectedDay) ? 2 : 1);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in visibleEvents)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Container(
                  height: selectedChipHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color:
                        (entry.type == _DeadlineType.exam
                                ? examColor
                                : taskColor)
                            .withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                        fontSize: selectedChipFontSize,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;

    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
    }
  }

  List<_DeadlineEntry> _entriesForDay({
    required DateTime day,
    required List<Task> tasks,
    required List<Exam> exams,
  }) {
    final taskEntries = tasks
        .where((task) => !task.done && isSameDay(task.dateTime.toLocal(), day))
        .map(
          (task) => _DeadlineEntry(
            id: task.id,
            title: task.title,
            subjectName: task.subjectName,
            dateTime: task.dateTime.toLocal(),
            type: _DeadlineType.task,
            task: task,
          ),
        );

    final examEntries = exams
        .where((exam) => !exam.done && isSameDay(exam.dateTime.toLocal(), day))
        .map(
          (exam) => _DeadlineEntry(
            id: exam.id,
            title: exam.title,
            subjectName: exam.subjectName,
            dateTime: exam.dateTime.toLocal(),
            type: _DeadlineType.exam,
            exam: exam,
          ),
        );

    final merged = [...taskEntries, ...examEntries]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return merged;
  }

  Future<void> _openAddMenu(List<Subject> subjects) async {
    if (subjects.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a subject first')));
      return;
    }

    final chosenType = await showModalBottomSheet<_DeadlineType>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.task_alt_rounded),
                title: const Text('Add Task Deadline'),
                onTap: () => Navigator.pop(context, _DeadlineType.task),
              ),
              ListTile(
                leading: const Icon(Icons.event_note_rounded),
                title: const Text('Add Exam Deadline'),
                onTap: () => Navigator.pop(context, _DeadlineType.exam),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || chosenType == null) return;

    final seedDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    if (chosenType == _DeadlineType.task) {
      final result = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (_) =>
            AddTaskDialog(subjects: subjects, initialDateTime: seedDateTime),
      );

      if (!mounted || result == null) return;

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }

      final Task newTask = result['task'];
      final Subject selectedSubject = result['subject'];
      final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
      if (userId.isEmpty) return;

      context.read<TaskBloc>().add(
        CreateTaskEvent(
          newTask.title,
          selectedSubject.id,
          selectedSubject.name,
          newTask.dateTime,
          newTask.reminderMinutes ?? 10,
          userId,
        ),
      );
      return;
    }

    final result = await showAddExamDialog(
      context: context,
      subjects: subjects,
      initialDateTime: seedDateTime,
    );

    if (!mounted || result == null || result['error'] != null) {
      return;
    }

    final Exam newExam = result['exam'];
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isEmpty) return;

    context.read<ExamBloc>().add(
      CreateExamEvent(
        newExam.title,
        newExam.subjectId,
        newExam.subjectName,
        newExam.dateTime,
        newExam.reminderMinutes ?? 10,
        userId,
      ),
    );
  }

  Future<void> _editEntry({
    required _DeadlineEntry entry,
    required List<Subject> subjects,
  }) async {
    if (subjects.isEmpty) return;

    if (entry.type == _DeadlineType.task && entry.task != null) {
      final result = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (_) => AddTaskDialog(subjects: subjects, task: entry.task),
      );

      if (!mounted || result == null || result.containsKey('error')) return;

      final Task updatedTask = result['task'];
      final Subject selectedSubject = result['subject'];
      final originalTask = entry.task!;

      context.read<TaskBloc>().add(
        UpdateTaskEvent(
          Task(
            id: originalTask.id,
            title: updatedTask.title,
            subjectId: selectedSubject.id,
            subjectName: selectedSubject.name,
            dateTime: updatedTask.dateTime,
            reminderMinutes: updatedTask.reminderMinutes,
            done: originalTask.done,
          ),
        ),
      );
      return;
    }

    if (entry.type == _DeadlineType.exam && entry.exam != null) {
      final result = await showAddExamDialog(
        context: context,
        subjects: subjects,
        exam: entry.exam,
      );

      if (!mounted || result == null || result['error'] != null) return;

      final Exam updatedExam = result['exam'];
      final originalExam = entry.exam!;

      context.read<ExamBloc>().add(
        UpdateExamEvent(
          Exam(
            id: originalExam.id,
            title: updatedExam.title,
            subjectId: updatedExam.subjectId,
            subjectName: updatedExam.subjectName,
            dateTime: updatedExam.dateTime,
            reminderMinutes: updatedExam.reminderMinutes,
            done: originalExam.done,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final isCompact = screenWidth < 380;
    final isTablet = screenWidth >= 768;

    final horizontalPadding = isTablet ? 20.0 : (isCompact ? 10.0 : 14.0);
    final topPadding = isTablet ? 12.0 : 8.0;
    final bottomPadding = isTablet ? 140.0 : 120.0;
    final sectionGap = isTablet ? 16.0 : 12.0;
    final outerRadius = isTablet ? 20.0 : 16.0;
    final calendarRowHeight = isTablet ? 88.0 : (isCompact ? 64.0 : 74.0);
    final daysOfWeekHeight = isTablet ? 48.0 : (isCompact ? 38.0 : 42.0);
    final dayNumberFontSize = isTablet ? 16.0 : (isCompact ? 12.5 : 14.0);
    final monthTitleFontSize = isTablet ? 34.0 : (isCompact ? 24.0 : 30.0);
    final weekLabelFontSize = isTablet ? 17.0 : (isCompact ? 13.0 : 16.0);
    final weekPillH = isTablet ? 18.0 : (isCompact ? 10.0 : 16.0);
    final weekPillV = isTablet ? 6.0 : (isCompact ? 4.0 : 5.0);
    final selectedChipHeight = isTablet ? 20.0 : (isCompact ? 16.0 : 18.0);
    final selectedChipFontSize = isTablet ? 11.0 : (isCompact ? 9.0 : 10.0);
    final agendaHeaderFontSize = isTablet ? 22.0 : (isCompact ? 18.0 : 20.0);
    final addButtonHeight = isTablet ? 42.0 : 38.0;
    final itemTitleFontSize = isTablet ? 19.0 : (isCompact ? 16.0 : 18.0);
    final itemMetaFontSize = isTablet ? 14.0 : (isCompact ? 12.0 : 13.0);
    final itemSubFontSize = isTablet ? 15.0 : (isCompact ? 13.0 : 14.0);

    final accent = Color.lerp(
      colors.secondary,
      colors.tertiary,
      isDark ? 0.7 : 0.5,
    )!;
    final secondaryAccent = colors.secondary;
    final accentSoft = accent.withValues(alpha: isDark ? 0.3 : 0.2);
    final borderColor = accent.withValues(alpha: isDark ? 0.62 : 0.58);
    final selectedDayFill = accent.withValues(alpha: isDark ? 0.3 : 0.2);
    final selectedDayText = colors.tertiaryText;
    final boardBackground = isDark
        ? Theme.of(context).cardColor.withValues(alpha: 0.9)
        : const Color(0xFFFFFBFD);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Calendar',
          style: TextStyle(
            color: colors.tertiaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: KuromiPageBackground(
        topColor: colors.surface,
        bottomColor: isDark
            ? const Color(0xFF1A1420)
            : Color.lerp(colors.surface, colors.secondary, 0.14)!,
        preset: KuromiBackgroundPreset.orchid,
        child: BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, subjectState) {
            final subjects = subjectState is SubjectLoaded
                ? subjectState.subjects
                : const <Subject>[];

            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                final tasks = taskState is TaskLoaded
                    ? taskState.tasks
                    : const <Task>[];

                return BlocBuilder<ExamBloc, ExamState>(
                  builder: (context, examState) {
                    final exams = examState is ExamLoaded
                        ? examState.exams
                        : const <Exam>[];

                    final selectedEntries = _entriesForDay(
                      day: _selectedDay,
                      tasks: tasks,
                      exams: exams,
                    );

                    final filteredEntries = selectedEntries.where((entry) {
                      if (_agendaFilter == _AgendaFilter.tasks) {
                        return entry.type == _DeadlineType.task;
                      }
                      if (_agendaFilter == _AgendaFilter.exams) {
                        return entry.type == _DeadlineType.exam;
                      }
                      return true;
                    }).toList();

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        topPadding,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: boardBackground,
                            borderRadius: BorderRadius.circular(outerRadius),
                            border: Border.all(color: borderColor, width: 1.4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(outerRadius - 1),
                            child: TableCalendar<_DeadlineEntry>(
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2100),
                            focusedDay: _focusedDay,
                            currentDay: DateTime.now(),
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            daysOfWeekVisible: true,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            eventLoader: (day) => _entriesForDay(
                              day: day,
                              tasks: tasks,
                              exams: exams,
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              setState(() {
                                _focusedDay = focusedDay;
                              });
                            },
                            rowHeight: calendarRowHeight,
                            daysOfWeekHeight: daysOfWeekHeight,
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: true,
                              cellMargin: EdgeInsets.zero,
                              cellAlignment: Alignment.topLeft,
                              tableBorder: TableBorder(
                                horizontalInside: BorderSide(
                                  color: borderColor.withValues(alpha: 0.9),
                                  width: 1.1,
                                ),
                                verticalInside: BorderSide(
                                  color: borderColor.withValues(alpha: 0.9),
                                  width: 1.1,
                                ),
                                top: BorderSide(
                                  color: borderColor.withValues(alpha: 0.55),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: borderColor.withValues(alpha: 0.55),
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: borderColor.withValues(alpha: 0.55),
                                  width: 1,
                                ),
                                right: BorderSide(
                                  color: borderColor.withValues(alpha: 0.55),
                                  width: 1,
                                ),
                              ),
                              selectedDecoration: BoxDecoration(
                                color: selectedDayFill,
                                shape: BoxShape.rectangle,
                              ),
                              selectedTextStyle: TextStyle(
                                color: selectedDayText,
                                fontWeight: FontWeight.w700,
                                fontSize: dayNumberFontSize,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                              ),
                              todayTextStyle: TextStyle(
                                color: secondaryAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: dayNumberFontSize,
                              ),
                              defaultTextStyle: TextStyle(
                                color: colors.tertiaryText,
                                fontWeight: FontWeight.w600,
                                fontSize: dayNumberFontSize,
                              ),
                              weekendTextStyle: TextStyle(
                                color: colors.tertiaryText,
                                fontWeight: FontWeight.w600,
                                fontSize: dayNumberFontSize,
                              ),
                              outsideTextStyle: TextStyle(
                                color: colors.tertiaryText.withValues(
                                  alpha: 0.4,
                                ),
                                fontWeight: FontWeight.w500,
                                fontSize: dayNumberFontSize,
                              ),
                              markerDecoration: BoxDecoration(
                                color: secondaryAccent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              markersMaxCount: 3,
                              markerMargin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              leftChevronVisible: true,
                              rightChevronVisible: true,
                              titleTextFormatter: (date, locale) =>
                                  DateFormat('MMMM yyyy').format(date),
                              titleTextStyle: TextStyle(
                                color: accent,
                                fontSize: monthTitleFontSize,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left_rounded,
                                color: accent,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right_rounded,
                                color: accent,
                              ),
                              headerPadding: const EdgeInsets.fromLTRB(
                                6,
                                10,
                                6,
                                10,
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: borderColor,
                                    width: 1.2,
                                  ),
                                  bottom: BorderSide(
                                    color: borderColor,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              weekdayStyle: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                fontSize: weekLabelFontSize,
                              ),
                              weekendStyle: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                fontSize: weekLabelFontSize,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              dowBuilder: (context, day) {
                                final label = DateFormat('EEE').format(day);
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: weekPillH,
                                      vertical: weekPillV,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1.4,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: weekLabelFontSize,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              markerBuilder: (context, day, events) {
                                return _buildMarker(
                                  day: day,
                                  events: events,
                                  accent: accent,
                                  textColor: colors.tertiaryText,
                                  taskColor: secondaryAccent,
                                  examColor: colors.tertiary,
                                  selectedChipHeight: selectedChipHeight,
                                  selectedChipFontSize: selectedChipFontSize,
                                );
                              },
                            ),
                          ),
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ActionChip(
                            avatar: Icon(
                              Icons.today_rounded,
                              size: 16,
                              color: accent,
                            ),
                            label: const Text('Today'),
                            labelStyle: TextStyle(
                              color: colors.tertiaryText,
                              fontWeight: FontWeight.w700,
                            ),
                            backgroundColor: colors.surface.withValues(
                              alpha: isDark ? 0.5 : 0.85,
                            ),
                            side: BorderSide(color: borderColor),
                            onPressed: () {
                              final today = DateTime.now();
                              setState(() {
                                _selectedDay = DateTime(
                                  today.year,
                                  today.month,
                                  today.day,
                                );
                                _focusedDay = _selectedDay;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.86)
                                : colors.surface.withValues(alpha: 0.86),
                            borderRadius: BorderRadius.circular(outerRadius),
                            border: Border.all(color: accentSoft),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            isTablet ? 18 : 14,
                            isTablet ? 16 : 14,
                            isTablet ? 18 : 14,
                            isTablet ? 18 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat(
                                        'EEE, MMM d',
                                      ).format(_selectedDay),
                                      style: TextStyle(
                                        color: colors.tertiaryText,
                                        fontWeight: FontWeight.w800,
                                        fontSize: agendaHeaderFontSize,
                                      ),
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () => _openAddMenu(subjects),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('Add'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size(0, addButtonHeight),
                                      backgroundColor: secondaryAccent,
                                      foregroundColor: colors.secondaryText,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ChoiceChip(
                                      label: const Text('All'),
                                      selected:
                                          _agendaFilter == _AgendaFilter.all,
                                      onSelected: (_) => setState(
                                        () => _agendaFilter = _AgendaFilter.all,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text('Tasks'),
                                      selected:
                                          _agendaFilter == _AgendaFilter.tasks,
                                      onSelected: (_) => setState(
                                        () =>
                                            _agendaFilter = _AgendaFilter.tasks,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text('Exams'),
                                      selected:
                                          _agendaFilter == _AgendaFilter.exams,
                                      onSelected: (_) => setState(
                                        () =>
                                            _agendaFilter = _AgendaFilter.exams,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (filteredEntries.isEmpty)
                                Text(
                                  _agendaFilter == _AgendaFilter.all
                                      ? 'No task or exam deadlines on this day.'
                                      : _agendaFilter == _AgendaFilter.tasks
                                      ? 'No tasks on this day.'
                                      : 'No exams on this day.',
                                  style: TextStyle(
                                    color: colors.tertiaryText.withValues(
                                      alpha: 0.72,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                ...filteredEntries.asMap().entries.map((e) {
                                  final index = e.key;
                                  final entry = e.value;
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey(
                                      'agenda-${_agendaFilter.name}-${entry.id}',
                                    ),
                                    tween: Tween(begin: 0, end: 1),
                                    duration: Duration(
                                      milliseconds: 180 + (index * 40),
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, t, child) {
                                      return Transform.translate(
                                        offset: Offset(0, (1 - t) * 10),
                                        child: Opacity(
                                          opacity: t,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () => _editEntry(
                                          entry: entry,
                                          subjects: subjects,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.06,
                                                  )
                                                : Colors.white.withValues(
                                                    alpha: 0.55,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: accentSoft,
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            10,
                                            12,
                                            10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: accentSoft,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      DateFormat(
                                                        'hh:mm a',
                                                      ).format(entry.dateTime),
                                                      style: TextStyle(
                                                        color:
                                                            colors.tertiaryText,
                                                        fontSize:
                                                            itemMetaFontSize,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          entry.type ==
                                                              _DeadlineType.exam
                                                          ? colors.tertiary
                                                          : secondaryAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    entry.type ==
                                                            _DeadlineType.exam
                                                        ? 'Exam'
                                                        : 'Task',
                                                    style: TextStyle(
                                                      color: colors.tertiaryText
                                                          .withValues(
                                                            alpha: 0.78,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          itemMetaFontSize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                entry.title,
                                                style: TextStyle(
                                                  color: colors.tertiaryText,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: itemTitleFontSize,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                entry.subjectName,
                                                style: TextStyle(
                                                  color: colors.tertiaryText
                                                      .withValues(alpha: 0.7),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: itemSubFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

