import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_manager.dart';

class MoodCalendarPage extends StatefulWidget {
  final List<Map<String, String>> diaryEntries;
  final String currentMood;
  final Color baseMoodColor;

  const MoodCalendarPage({
    super.key,
    required this.diaryEntries,
    required this.currentMood,
    required this.baseMoodColor,
  });

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, String>> selectedDayEntries = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int currentWeekIndex = 0;

  List<List<int>> weekRanges = [];

  final ThemeManager _themeManager = ThemeManager.instance;

  @override
  void initState() {
    super.initState();
    _generateWeekRanges();
    _themeManager.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFD166);
      case 'sad':
        return const Color(0xFF6A9AB0);
      case 'angry':
        return const Color(0xFFEF476F);
      case 'fear':
        return const Color(0xFF9C89B8);
      default:
        return const Color(0xFF6C757D);
    }
  }

  Color _getThemeColor() {
    return _themeManager.getThemeColor(widget.baseMoodColor);
  }

  void _generateWeekRanges() {
    final firstDay = DateTime(selectedYear, selectedMonth, 1);
    final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);
    weekRanges.clear();
    int start = 1;
    while (start <= lastDay.day) {
      int end = start + 6;
      if (end > lastDay.day) end = lastDay.day;
      weekRanges.add([start, end]);
      start = end + 1;
    }
  }

  List<Map<String, String>> _entriesForMonth(int month, int year) {
    return widget.diaryEntries.where((entry) {
      final date = DateTime.tryParse(entry['date'] ?? '');
      return date != null && date.year == year && date.month == month;
    }).toList();
  }

  Map<int, List<Map<String, String>>> _mapDaysToMoods(List<Map<String, String>> monthEntries) {
    final Map<int, List<Map<String, String>>> dayMap = {};
    for (var entry in monthEntries) {
      final date = DateTime.tryParse(entry['date'] ?? '');
      if (date != null) {
        if (!dayMap.containsKey(date.day)) {
          dayMap[date.day] = [];
        }
        dayMap[date.day]!.add(entry);
      }
    }
    return dayMap;
  }

  Map<String, int> _getMonthlyEmotionCount(int month, int year) {
    final entries = _entriesForMonth(month, year);
    final Map<String, int> counts = {};
    for (var entry in entries) {
      final mood = entry['emotion']?.toLowerCase() ?? 'neutral';
      counts[mood] = (counts[mood] ?? 0) + 1;
    }
    return counts;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      selectedMonth = selectedDay.month;
      selectedYear = selectedDay.year;

      final monthEntries = _entriesForMonth(selectedMonth, selectedYear);
      final dayMap = _mapDaysToMoods(monthEntries);
      selectedDayEntries = dayMap[selectedDay.day] ?? [];
    });
  }

  Widget _buildMoodInsightsCard() {
    final themeColor = _getThemeColor();
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    final monthEntries = _entriesForMonth(selectedMonth, selectedYear);
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    
    if (monthEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGradientMagic
              ? Colors.white.withOpacity(0.9)
              : themeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGradientMagic
                ? Colors.white.withOpacity(0.3)
                : themeColor.withOpacity(0.3)
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insights, 
              color: themeColor, 
              size: 28
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No entries yet",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isGradientMagic
                          ? Colors.grey.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Start tracking your moods to see insights",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isGradientMagic
                          ? themeColor.withOpacity(0.8)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final positiveMoods = ['happy', 'excited'];
    final negativeMoods = ['sad', 'angry', 'anxious', 'stressed'];
    
    final positiveCount = monthEntries.where((e) => positiveMoods.contains(e['emotion'])).length;
    final negativeCount = monthEntries.where((e) => negativeMoods.contains(e['emotion'])).length;
    final neutralCount = monthEntries.where((e) => e['emotion'] == 'neutral' || !positiveMoods.contains(e['emotion']!) && !negativeMoods.contains(e['emotion']!)).length;
    
    final String title;
    final String message;
    final IconData icon;
    final Color bgColor;
    final Color messageColor;

    if (positiveCount > negativeCount && positiveCount > neutralCount) {
      title = "🌟 Positive Vibes";
      message = "Your positive mood days are dominant this month!";
      icon = Icons.emoji_emotions;
      bgColor = isGradientMagic
          ? Colors.green.withOpacity(0.15)
          : Colors.green.withOpacity(0.1);
      messageColor = Colors.green.shade800;
    } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
      title = "💭 Reflection Time";
      message = "Consider activities that boost your mood this week";
      icon = Icons.self_improvement;
      bgColor = isGradientMagic
          ? Colors.orange.withOpacity(0.15)
          : Colors.orange.withOpacity(0.1);
      messageColor = Colors.orange.shade800;
    } else {
      title = "⚖️ Balanced Month";
      message = "You're maintaining emotional balance";
      icon = Icons.balance;
      bgColor = isGradientMagic
          ? Colors.blue.withOpacity(0.15)
          : Colors.blue.withOpacity(0.1);
      messageColor = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGradientMagic
              ? Colors.white.withOpacity(0.3)
              : messageColor.withOpacity(0.3)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: themeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Insights",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isGradientMagic
                            ? themeColor.withOpacity(0.8)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: messageColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isGradientMagic
                  ? Colors.grey.shade800
                  : Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniStat("😊", positiveCount, themeColor, isGradientMagic),
              const SizedBox(width: 12),
              _buildMiniStat("😟", negativeCount, themeColor, isGradientMagic),
              const SizedBox(width: 12),
              _buildMiniStat("😐", neutralCount, themeColor, isGradientMagic),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, int count, Color themeColor, bool isGradientMagic) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isGradientMagic
              ? Colors.white.withOpacity(0.7)
              : themeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
  final themeColor = _getThemeColor();
  final textColor = _themeManager.getContrastingTextColor(themeColor);
  final monthEntries = _entriesForMonth(selectedMonth, selectedYear);
  final monthName = DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));
  final isGradientMagic = _themeManager.selectedPaletteIndex == 7;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isGradientMagic
          ? Colors.white.withOpacity(0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: themeColor, size: 20),
            const SizedBox(width: 8),
            Text(
              "$monthName $selectedYear",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isGradientMagic
                    ? Colors.grey.shade800
                    : Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Text(
              "${monthEntries.length} entries",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isGradientMagic
                    ? themeColor.withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGradientMagic
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey.shade200
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 260,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return widget.diaryEntries.where((entry) {
                  final date = DateTime.tryParse(entry['date'] ?? '');
                  return date != null && 
                         date.year == day.year && 
                         date.month == day.month && 
                         date.day == day.day;
                }).toList();
              },
              selectedDayPredicate: (day) => _selectedDay != null && isSameDay(day, _selectedDay),
              onDaySelected: _onDaySelected,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: themeColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                weekendTextStyle: GoogleFonts.poppins(
                  color: isGradientMagic
                      ? Colors.grey.shade800
                      : Colors.grey.shade700,
                  fontSize: 14,
                ),
                defaultTextStyle: GoogleFonts.poppins(
                  color: isGradientMagic
                      ? Colors.grey.shade800
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                outsideDaysVisible: false,
                cellPadding: const EdgeInsets.all(2),
                cellMargin: EdgeInsets.zero,
                cellAlignment: Alignment.center,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  color: themeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: themeColor, size: 20),
                rightChevronIcon: Icon(Icons.chevron_right, color: themeColor, size: 20),
                headerPadding: const EdgeInsets.symmetric(vertical: 4),
                headerMargin: const EdgeInsets.only(bottom: 4),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.poppins(
                  color: isGradientMagic
                      ? themeColor.withOpacity(0.8)
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                weekendStyle: GoogleFonts.poppins(
                  color: isGradientMagic
                      ? themeColor.withOpacity(0.8)
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isGradientMagic
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade200
                    ),
                  ),
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    final mood = (events as List<Map<String, String>>)
                        .first['emotion'] ?? 'neutral';
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _getMoodColor(mood),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    alignment: Alignment.center,
                    child: Text(
                      day.day.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isGradientMagic
                            ? Colors.grey.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                  );
                },
              ),
              rowHeight: 32,
              daysOfWeekHeight: 28,
            ),
          ),
        ),
        
        // Show selected day entries directly below the calendar
        if (_selectedDay != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGradientMagic
                  ? Colors.white.withOpacity(0.7)
                  : themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isGradientMagic
                    ? Colors.white.withOpacity(0.3)
                    : themeColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedDay!.day == DateTime.now().day ? Icons.today : Icons.calendar_today,
                      color: themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ),
                    if (selectedDayEntries.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${selectedDayEntries.length} ${selectedDayEntries.length == 1 ? 'entry' : 'entries'}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (selectedDayEntries.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 36,
                            color: isGradientMagic
                                ? themeColor.withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No entries for this date",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isGradientMagic
                                  ? themeColor.withOpacity(0.8)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: selectedDayEntries.map((entry) {
                          final moodColor = _getMoodColor(entry['emotion'] ?? 'neutral');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isGradientMagic
                                  ? Colors.white
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isGradientMagic
                                    ? moodColor.withOpacity(0.3)
                                    : moodColor.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: moodColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry['emoji'] ?? '😌',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              entry['emotion']?.toUpperCase() ?? 'NEUTRAL',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: moodColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (entry['date'] != null && entry['date']!.isNotEmpty)
                                            Text(
                                              DateFormat('h:mm a').format(DateTime.parse(entry['date']!)),
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: isGradientMagic
                                                    ? themeColor.withOpacity(0.7)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (entry['text'] != null && entry['text']!.isNotEmpty)
                                        Text(
                                          entry['text']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isGradientMagic
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade800,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildWeeklyBarChart() {
  final themeColor = _getThemeColor();
  final monthEntries = _entriesForMonth(selectedMonth, selectedYear);
  final dayMoodMap = _mapDaysToMoods(monthEntries);
  final monthName = DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth));
  final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
  
  final int startDay = weekRanges.isNotEmpty ? weekRanges[currentWeekIndex][0] : 1;
  final int endDay = weekRanges.isNotEmpty ? weekRanges[currentWeekIndex][1] : 7;
  final int daysInWeek = endDay - startDay + 1;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isGradientMagic
          ? Colors.white.withOpacity(0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the title
          children: [
            Text(
              "Weekly Mood Trend",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isGradientMagic
                    ? Colors.grey.shade800
                    : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (currentWeekIndex > 0) currentWeekIndex--;
                });
              },
              icon: Icon(Icons.chevron_left, color: themeColor),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              iconSize: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isGradientMagic
                    ? Colors.white.withOpacity(0.7)
                    : themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Week ${currentWeekIndex + 1}", 
                style: GoogleFonts.poppins(
                  fontSize: 12, 
                  color: themeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (currentWeekIndex < weekRanges.length - 1) currentWeekIndex++;
                });
              },
              icon: Icon(Icons.chevron_right, color: themeColor),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              iconSize: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "$startDay-$endDay $monthName",
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isGradientMagic
                ? themeColor.withOpacity(0.8)
                : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, 
          child: Center( 
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth * 0.9; 
                final int numberOfBars = daysInWeek;
                
                final double fixedSpacing = 4.0; 
                final double totalSpacingWidth = fixedSpacing * (numberOfBars - 1);
                final double totalWidthForBars = availableWidth - totalSpacingWidth;
                final double calculatedBarWidth = totalWidthForBars / numberOfBars;
                
                final double barWidth = calculatedBarWidth.clamp(8.0, 16.0); 

                final barGroups = List.generate(numberOfBars, (index) {
                  final day = startDay + index;
                  final entries = dayMoodMap[day] ?? [];

                  if (entries.isEmpty) {
                    return BarChartGroupData(
                      x: day,
                      barsSpace: fixedSpacing,
                      barRods: [
                        BarChartRodData(
                          toY: 0.5,
                          color: isGradientMagic
                              ? Colors.grey.shade300
                              : Colors.grey.shade200,
                          width: barWidth,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Bigger radius
                        )
                      ],
                    );
                  }

                  double startY = 0;
                  final rods = entries.map((e) {
                    final rod = BarChartRodStackItem(
                      startY,
                      startY + 1,
                      _getMoodColor(e['emotion'] ?? 'neutral')
                    );
                    startY += 1;
                    return rod;
                  }).toList();

                  return BarChartGroupData(
                    x: day,
                    barsSpace: fixedSpacing,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: startY,
                        width: barWidth,
                        rodStackItems: rods,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Bigger radius
                      ),
                    ],
                  );
                });

                return Container(
                  width: availableWidth, 
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center, 
                      maxY: 4,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24, 
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final dayNumber = value.toInt();
                              if (dayNumber >= startDay && dayNumber <= endDay) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    dayNumber.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w500,
                                      color: isGradientMagic
                                          ? themeColor.withOpacity(0.8)
                                          : Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      barGroups: barGroups,
                      barTouchData: BarTouchData(enabled: false),
                    ),
                    swapAnimationDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMoodDistribution() {
    final themeColor = _getThemeColor();
    final monthlyEmotionCount = _getMonthlyEmotionCount(selectedMonth, selectedYear);
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGradientMagic
            ? Colors.white.withOpacity(0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: themeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Mood Distribution",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isGradientMagic
                      ? Colors.grey.shade800
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (monthlyEmotionCount.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline, 
                      size: 40, // Smaller icon
                      color: isGradientMagic
                          ? themeColor.withOpacity(0.3)
                          : Colors.grey.shade300
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No mood data",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isGradientMagic
                            ? themeColor.withOpacity(0.7)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else SizedBox(
            height: 180, 
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: monthlyEmotionCount.entries.map((entry) {
                        final total = monthlyEmotionCount.values.fold<int>(0, (a, b) => a + b);
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          color: _getMoodColor(entry.key),
                          title: "",
                          radius: 35, 
                          showTitle: false,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 35, 
                    ),
                  ),
                ),
                const SizedBox(width: 12), 
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: monthlyEmotionCount.entries.map((entry) {
                        final total = monthlyEmotionCount.values.fold<int>(0, (a, b) => a + b);
                        final percentage = (entry.value / total * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6), 
                          child: Row(
                            children: [
                              Container(
                                width: 10, 
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _getMoodColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6), 
                              Expanded(
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w500,
                                    color: isGradientMagic
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Text(
                                "${percentage.toStringAsFixed(0)}%",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isGradientMagic
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayEntries() {
    final themeColor = _getThemeColor();
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    
    if (_selectedDay == null) return const SizedBox();

    if (selectedDayEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGradientMagic
              ? Colors.white.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_note, 
              size: 40, 
              color: isGradientMagic
                  ? themeColor.withOpacity(0.3)
                  : Colors.grey.shade300
            ),
            const SizedBox(height: 12),
            Text(
              "No entries for ${DateFormat('MMM dd').format(_selectedDay!)}",
              style: GoogleFonts.poppins(
                fontSize: 13, 
                color: isGradientMagic
                    ? themeColor.withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6), 
            Text(
              "Tap a day with entries to see details",
              style: GoogleFonts.poppins(
                fontSize: 11, 
                color: isGradientMagic
                    ? themeColor.withOpacity(0.7)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration(
        color: isGradientMagic
            ? Colors.white.withOpacity(0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: themeColor, size: 18), 
              const SizedBox(width: 6), 
              Expanded(
                child: Text(
                  "Entries for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isGradientMagic
                        ? Colors.grey.shade800
                        : Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                "${selectedDayEntries.length} entries",
                style: GoogleFonts.poppins(
                  fontSize: 11, 
                  color: isGradientMagic
                      ? themeColor.withOpacity(0.8)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...selectedDayEntries.map((entry) {
            final moodColorEntry = _getMoodColor(entry['emotion'] ?? 'neutral');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                color: isGradientMagic
                    ? Colors.white.withOpacity(0.7)
                    : moodColorEntry.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isGradientMagic
                      ? Colors.white.withOpacity(0.3)
                      : moodColorEntry.withOpacity(0.2)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6), 
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry['emoji'] ?? '😌',
                          style: const TextStyle(fontSize: 18), 
                        ),
                      ),
                      const SizedBox(width: 10), 
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['emotion']?.toUpperCase() ?? 'NEUTRAL',
                              style: GoogleFonts.poppins(
                                fontSize: 13, 
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                            if (entry['date'] != null && entry['date']!.isNotEmpty)
                              Text(
                                DateFormat('h:mm a').format(DateTime.parse(entry['date']!)),
                                style: GoogleFonts.poppins(
                                  fontSize: 10, 
                                  color: isGradientMagic
                                      ? themeColor.withOpacity(0.7)
                                      : Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), 
                  if (entry['text'] != null && entry['text']!.isNotEmpty)
                    Text(
                      entry['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        color: isGradientMagic
                            ? Colors.grey.shade800
                            : Colors.grey.shade800,
                        height: 1.4,
                      ),
                      maxLines: 3, 
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final Gradient? themeGradient = isGradientMagic 
        ? _themeManager.getThemeGradient(widget.baseMoodColor)
        : null;

    return Scaffold(
      backgroundColor: isGradientMagic
          ? null
          : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          "Mood Calendar",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 18, 
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        toolbarHeight: 56, 
      ),
      body: SafeArea(
        child: Container(
          decoration: isGradientMagic
              ? BoxDecoration(
                  gradient: themeGradient,
                )
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isGradientMagic
                            ? Colors.white.withOpacity(0.9)
                            : themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGradientMagic
                              ? Colors.white.withOpacity(0.3)
                              : themeColor.withOpacity(0.3)
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10, 
                            height: 10,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8), 
                          Flexible(
                            child: Text(
                              "Current Mood: ${widget.currentMood}",
                              style: GoogleFonts.poppins(
                                fontSize: constraints.maxWidth > 600 ? 15 : 13, // Smaller font
                                fontWeight: FontWeight.w500,
                                color: themeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12), 

                    // Calendar Section
                    _buildCalendarSection(),
                    const SizedBox(height: 12), 

                    // Weekly Bar Chart
                    _buildWeeklyBarChart(),
                    const SizedBox(height: 12), 

                    // Mood Insights Card
                    _buildMoodInsightsCard(),
                    const SizedBox(height: 12), 

                    // Mood Distribution
                    _buildMoodDistribution(),
                    const SizedBox(height: 12), 

                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}