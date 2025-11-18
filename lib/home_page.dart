import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';
import 'new_entry_page.dart';
import 'mood_calendar_page.dart';
import 'content_page.dart';
import 'others_page.dart';

class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, String>> diaryEntries = [];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _addNewEntry(String text, String emotion, String emoji) {
    setState(() {
      diaryEntries.insert(0, {
        'text': text,
        'emotion': emotion,
        'emoji': emoji,
        'date': DateTime.now().toString().split(' ')[0],
      });
      _selectedIndex = 0;
    });
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
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestEntry = diaryEntries.isNotEmpty ? diaryEntries.first : null;
    final moodColor = latestEntry != null
        ? _getMoodColor(latestEntry['emotion'] ?? 'neutral')
        : Colors.blueGrey;

    final pages = [
      // 🏠 HOME / Feed
      Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            // Top header image
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  child: Image.asset(
                    'assets/write.png', // Your header image
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // Emoji + Welcome card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: moodColor.withOpacity(0.8),
                          child: Text(
                            latestEntry != null
                                ? latestEntry['emoji'] ?? '😌'
                                : '😌',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            latestEntry != null
                                ? "You're feeling ${latestEntry['emotion']}"
                                : "Welcome back!",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 28),
                          color: moodColor,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewEntryPage(
                                  onSave: (text, emotion, emoji) {
                                    _addNewEntry(text, emotion, emoji);
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Quick Add Entry Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewEntryPage(
                          onSave: (text, emotion, emoji) {
                            _addNewEntry(text, emotion, emoji);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Share what's on your mind"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: moodColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Diary Feed
            if (diaryEntries.isNotEmpty)
              ...diaryEntries.map((entry) {
                final entryMoodColor = _getMoodColor(entry['emotion'] ?? '');
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: entryMoodColor.withOpacity(0.8),
                              child: Text(
                                entry['emoji'] ?? '😌',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              entry['emotion'] ?? 'Neutral',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: entryMoodColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              entry['date'] ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black54),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entry['text'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),

      // 📺 Content Page
      ContentPage(
        mood:
            latestEntry != null ? latestEntry['emotion'] ?? 'neutral' : 'neutral',
      ),

      // 🗓️ Mood Calendar
      MoodCalendarPage(diaryEntries: diaryEntries),

      // ⚙️ Others Page
      const OthersPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: moodColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Your logo here
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              "JARS",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: moodColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.recommend), label: 'Content'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Others'),
        ],
      ),
    );
  }
}
