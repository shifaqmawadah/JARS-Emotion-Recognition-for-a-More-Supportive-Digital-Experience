import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class MoodCalendarPage extends StatefulWidget {
  final List<Map<String, String>> diaryEntries;


  const MoodCalendarPage({
    super.key,
    required this.diaryEntries,
  });


  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}


class _MoodCalendarPageState extends State<MoodCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, String>> selectedDayEntries = [];


  Map<DateTime, List<Map<String, String>>> _generateEvents() {
    Map<DateTime, List<Map<String, String>>> events = {};
    for (var entry in widget.diaryEntries) {
      final date = DateTime.parse(entry['date']!);
      final key = DateTime(date.year, date.month, date.day);
      if (!events.containsKey(key)) {
        events[key] = [];
      }
      events[key]!.add(entry);
    }
    return events;
  }


  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.yellow.shade700;
      case 'sad':
        return Colors.blue.shade600;
      case 'angry':
        return Colors.red.shade600;
      case 'excited':
        return Colors.orange.shade600;
      case 'stressed':
        return Colors.green.shade600;
      case 'bored':
        return Colors.grey.shade600;
      case 'anxious':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade500;
    }
  }


  void _onDaySelected(
    DateTime selectedDay,
    DateTime focusedDay,
    Map<DateTime, List<Map<String, String>>> events,
  ) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      final key = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      selectedDayEntries = events[key] ?? [];
    });
  }


  @override
  Widget build(BuildContext context) {
    final events = _generateEvents();


    // Determine mood color for header based on first entry of selected day or today
    final headerMoodColor = selectedDayEntries.isNotEmpty
        ? _getMoodColor(selectedDayEntries.first['emotion'] ?? 'neutral')
        : _getMoodColor('neutral');


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Mood Calendar",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: headerMoodColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) =>
                events[DateTime(day.year, day.month, day.day)] ?? [],
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) =>
                _onDaySelected(selectedDay, focusedDay, events),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade500,
                    Colors.grey.shade700,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: headerMoodColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              defaultTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              outsideTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black38,
              ),
              weekendTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.redAccent,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, entries) {
                if (entries.isNotEmpty) {
                  final moodEmoji = (entries.first as Map<String, String>)['emoji'] ?? '';
                  return Align(
                    alignment: Alignment.center,
                    child: Text(
                      moodEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedDayEntries.isEmpty
                ? Center(
                    child: Text(
                      "No entries for selected day.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      final moodColor = _getMoodColor(entry['emotion'] ?? 'neutral');


                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: moodColor.withOpacity(0.8),
                                child: Text(
                                  entry['emoji'] ?? '😌',
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry['emotion']?.toUpperCase() ?? 'NEUTRAL',
                                      style: TextStyle(
                                        color: moodColor,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry['text'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry['date'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



