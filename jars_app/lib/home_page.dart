import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'login_page.dart';
import 'new_entry_page.dart';
import 'mood_calendar_page.dart';
import 'content_page.dart';
import 'others_page.dart';
import 'diary_data.dart';
import 'theme_manager.dart';
import 'ai_chat_page.dart';
import 'all_entries.dart';

class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Map<String, String>> diaryEntries = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String currentMood = 'neutral';
  bool _showWelcome = true;

  final ThemeManager _themeManager = ThemeManager.instance;
  String userId = '';
  @override
  void initState() {
    super.initState();
    diaryEntries = List.from(initialEntries);
    if (diaryEntries.isNotEmpty) {
      currentMood = diaryEntries.first['emotion'] ?? 'neutral';
    }
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.forward();

    _themeManager.addListener(_onThemeChanged);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {}); 
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

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
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'time': DateFormat('hh:mm a').format(DateTime.now()),
      });
      _selectedIndex = 0;
      currentMood = emotion;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(emoji),
              const SizedBox(width: 10),
              Text(
                'Entry saved! You\'re feeling $emotion',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: _themeManager.getThemeColor(_getMoodColor(emotion)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    });
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

  String _getMoodQuote(String mood) {
    final quotes = {
      'happy': "Joy is the simplest form of gratitude.",
      'sad': "Tears water the seeds of future happiness.",
      'angry': "Your feelings are valid. Let's process them together.",
      'fear': "You have survived 100% of your bad days.",
      'neutral': "Every moment is a fresh beginning.",
    };
    return quotes[mood.toLowerCase()] ?? "How are you feeling today?";
  }

  Widget _buildMoodCircle(String mood, String emoji, double size) {
    final themeColor = _themeManager.getThemeColor(_getMoodColor(mood));
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final Gradient? themeGradient = isGradientMagic 
        ? _themeManager.getThemeGradient(_getMoodColor(mood))
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isGradientMagic 
            ? themeGradient
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColor.withOpacity(0.9),
                  themeColor.withOpacity(0.6),
                ],
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  Widget _buildMoodFrequencyInsight() {
    if (diaryEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_chart_rounded, 
                    color: _themeManager.getThemeColor(_getMoodColor(currentMood))),
                const SizedBox(width: 8),
                Text(
                  "Mood Insights",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Start journaling to see your mood patterns!",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // Count mood frequencies
    final moodCounts = <String, int>{};
    for (var entry in diaryEntries) {
      final mood = entry['emotion']?.toLowerCase() ?? 'neutral';
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    // Sort moods by frequency
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get top 5 moods or all if less than 5
    final displayMoods = sortedMoods.length > 5 
        ? sortedMoods.sublist(0, 5) 
        : sortedMoods;

    final themeColor = _themeManager.getThemeColor(_getMoodColor(currentMood));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_chart_rounded, color: themeColor),
              const SizedBox(width: 8),
              Text(
                "Mood Frequency",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                "Total: ${diaryEntries.length}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Here's how often you've felt each emotion:",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mood frequency bars
          Column(
            children: displayMoods.map((moodEntry) {
              final mood = moodEntry.key;
              final count = moodEntry.value;
              final percentage = (count / diaryEntries.length) * 100;
              final moodColor = _themeManager.getThemeColor(_getMoodColor(mood));
              final moodEmoji = _getMoodEmoji(mood);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              moodEmoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mood[0].toUpperCase() + mood.substring(1),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          "$count ${count == 1 ? 'time' : 'times'}",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: moodColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 6,
                          width: MediaQuery.of(context).size.width * (percentage / 100) * 0.7,
                          decoration: BoxDecoration(
                            color: moodColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${percentage.toStringAsFixed(1)}% of entries",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        
          if (sortedMoods.length > 5)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showAllMoodsDialog(sortedMoods);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "View all ${sortedMoods.length} moods",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: themeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          // Statistics summary
          if (diaryEntries.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Most Frequent:",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        sortedMoods.first.key[0].toUpperCase() + 
                        sortedMoods.first.key.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Entries this week:",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        _getThisWeekEntries().toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return '😊';
      case 'sad': return '😢';
      case 'angry': return '😠';
      case 'excited': return '🤩';
      case 'stressed': return '🤯';
      case 'bored': return '😴';
      case 'anxious': return '😰';
      case 'grateful': return '🙏';
      case 'proud': return '💪';
      case 'neutral': return '😌';
      default: return '😐';
    }
  }

  int _getThisWeekEntries() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek.subtract(const Duration(days: 1)); // Start from Monday
    
    return diaryEntries.where((entry) {
      final dateString = entry['date'];
      if (dateString == null) return false;
      final entryDate = DateTime.tryParse(dateString);
      return entryDate != null && entryDate.isAfter(startOfWeek);
    }).length;
  }

  void _showAllMoodsDialog(List<MapEntry<String, int>> allMoods) {
    final themeColor = _themeManager.getThemeColor(_getMoodColor(currentMood));
    final textColor = _themeManager.getContrastingTextColor(themeColor);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: themeColor),
                    const SizedBox(width: 10),
                    Text(
                      "All Mood Frequencies",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Complete breakdown of your emotional patterns:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Mood list
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allMoods.length,
                    itemBuilder: (context, index) {
                      final moodEntry = allMoods[index];
                      final mood = moodEntry.key;
                      final count = moodEntry.value;
                      final percentage = (count / diaryEntries.length) * 100;
                      final moodColor = _themeManager.getThemeColor(_getMoodColor(mood));
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: moodColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _getMoodEmoji(mood),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mood[0].toUpperCase() + mood.substring(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${percentage.toStringAsFixed(1)}% of entries",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: moodColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$count ${count == 1 ? 'entry' : 'entries'}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: moodColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: GoogleFonts.poppins(
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyInsight() {
    if (diaryEntries.isEmpty) return const SizedBox();

    final recentEntries = diaryEntries.take(3).toList();
    final moodCounts = <String, int>{};
    for (var entry in recentEntries) {
      final mood = entry['emotion'] ?? 'neutral';
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    if (moodCounts.isEmpty) return const SizedBox();

    final dominantMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final themeColor = _themeManager.getThemeColor(_getMoodColor(dominantMood));

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withOpacity(0.1),
              themeColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: themeColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_rounded,
                color: themeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Mood Insight",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Recently, you've been feeling mostly $dominantMood",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalPatterns() {
    if (diaryEntries.length < 2) return const SizedBox();

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEntries = diaryEntries.where((entry) {
      final dateString = entry['date'];
      if (dateString == null) return false;
      final date = DateTime.tryParse(dateString);
      return date != null && date.isAfter(weekAgo);
    }).toList();

    if (recentEntries.isEmpty) return const SizedBox();

    final themeColor = _themeManager.getThemeColor(_getMoodColor(currentMood));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: themeColor),
              const SizedBox(width: 8),
              Text(
                "Weekly Emotional Pattern",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentEntries.length > 7 ? 7 : recentEntries.length,
              itemBuilder: (context, index) {
                final entry = recentEntries[index];
                final moodColor = _themeManager.getThemeColor(_getMoodColor(entry['emotion'] ?? 'neutral'));
                final dateString = entry['date'] ?? '';
                String dayDisplay = '';
                
                try {
                  if (dateString.isNotEmpty) {
                    final parts = dateString.split('-');
                    if (parts.length >= 3) {
                      dayDisplay = parts.last;
                    }
                  }
                } catch (e) {
                  dayDisplay = '';
                }
                
                return Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry['emoji'] ?? '😌',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayDisplay,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openAIChat() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatPage(
          userEmail: widget.userEmail,
          currentMood: currentMood,
          baseMoodColor: _getMoodColor(currentMood), // Add this line
          themeManager: _themeManager,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseMoodColor = _getMoodColor(currentMood);
    final themeColor = _themeManager.getThemeColor(baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    // Check if it's Gradient Magic theme
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final Gradient? themeGradient = isGradientMagic 
        ? _themeManager.getThemeGradient(baseMoodColor)
        : null;

    final pages = [
      // HOME
      Container(
        color: const Color(0xFFF8F9FA),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: isGradientMagic
                      ? themeGradient
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            themeColor.withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    decoration: BoxDecoration(
                      gradient: isGradientMagic
                          ? themeGradient
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                themeColor.withOpacity(0.9),
                                themeColor.withOpacity(0.7),
                                themeColor.withOpacity(0.3),
                              ],
                            ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (_showWelcome)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.waving_hand_rounded, color: textColor),
                                const SizedBox(width: 8),
                                Text(
                                  "Welcome back! Ready to check in?",
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        _buildMoodCircle(
                          currentMood,
                          diaryEntries.isNotEmpty ? (diaryEntries.first['emoji'] ?? '😌') : '😌',
                          80,
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          diaryEntries.isNotEmpty
                              ? "You're feeling ${currentMood.toLowerCase()}"
                              : "How are you feeling today?",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _getMoodQuote(currentMood),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textColor.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        
                        Container(
                          margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
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
                            icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                            label: Text(
                              "Share Your Thoughts",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isGradientMagic 
                                  ? Colors.white.withOpacity(0.2)
                                  : themeColor.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.2),
                              side: isGradientMagic
                                  ? BorderSide(color: Colors.white.withOpacity(0.3), width: 1)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: _buildMoodFrequencyInsight(),
                ),
                
                _buildDailyInsight(),
                
                _buildEmotionalPatterns(),
                
                if (diaryEntries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, color: themeColor),
                        const SizedBox(width: 10),
                        Text(
                          "Recent Reflections",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                ...diaryEntries.take(5).map((entry) {
                  final baseEntryColor = _getMoodColor(entry['emotion'] ?? '');
                  final entryThemeColor = _themeManager.getThemeColor(baseEntryColor);
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(20 * (1 - _fadeAnimation.value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: entryThemeColor.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          entryThemeColor.withOpacity(0.9),
                                          entryThemeColor.withOpacity(0.6),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry['emoji'] ?? '😌',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry['emotion'] ?? 'Neutral',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: entryThemeColor,
                                          ),
                                        ),
                                        Text(
                                          '${entry['date']} • ${entry['time'] ?? ''}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: entryThemeColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: entryThemeColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  entry['text'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                if (diaryEntries.length > 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllEntriesPage(
                              diaryEntries: diaryEntries,
                              currentMood: currentMood,
                              baseMoodColor: baseMoodColor,
                              themeManager: _themeManager,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.list_alt_rounded, color: themeColor),
                      label: Text(
                        'View All Entries',
                        style: GoogleFonts.poppins(
                          color: themeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),

      // Content Page
      ContentPage(
        mood: diaryEntries.isNotEmpty
            ? diaryEntries.first['emotion'] ?? 'neutral'
            : 'neutral',
        userId: userId,
      ),

      // Mood Calendar
      MoodCalendarPage(
        diaryEntries: diaryEntries,
        currentMood: currentMood,
        baseMoodColor: baseMoodColor,
      ),

      // Others Page
      OthersPage(
        currentMood: diaryEntries.isNotEmpty
            ? diaryEntries.first['emotion'] ?? 'neutral'
            : 'neutral',
        baseMoodColor: baseMoodColor,
        userEmail: widget.userEmail,
        diaryEntries: diaryEntries,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: isGradientMagic
                    ? themeGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeColor.withOpacity(0.9),
                          themeColor.withOpacity(0.7),
                        ],
                      ),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/logo.png',
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.psychology_alt, color: textColor, size: 20),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "J",
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  TextSpan(
                    text: "ARS",
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout_rounded, color: textColor),
            tooltip: 'Logout',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.person_rounded,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background for bottom navigation
            Container(
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
            ),
            
            // Bottom navigation bar items
            Positioned.fill(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                backgroundColor: Colors.transparent,
                selectedItemColor: textColor,
                unselectedItemColor: textColor.withOpacity(0.7),
                elevation: 0,
                onTap: (index) {
                  // Handle navigation with the AI button slot
                  if (index == 2) {
                    // This is the AI button slot, don't navigate
                    return;
                  }
                  
                  // Adjust index for the empty AI button slot
                  final adjustedIndex = index > 2 ? index - 1 : index;
                  
                  if (adjustedIndex < pages.length) {
                    setState(() => _selectedIndex = adjustedIndex);
                  }
                },
                selectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 9,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: _selectedIndex == 0
                          ? BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Icon(Icons.home_rounded, size: 22, color: textColor),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: _selectedIndex == 1
                          ? BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Icon(Icons.explore_rounded, size: 22, color: textColor),
                    ),
                    label: 'Explore',
                  ),
                  // Placeholder for AI button (index 2)
                  const BottomNavigationBarItem(
                    icon: SizedBox(width: 0, height: 0),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: _selectedIndex == 2
                          ? BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Icon(Icons.calendar_month_rounded, size: 22, color: textColor),
                    ),
                    label: 'Calendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: _selectedIndex == 3
                          ? BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Icon(Icons.more_horiz_rounded, size: 22, color: textColor),
                    ),
                    label: 'More',
                  ),
                ],
              ),
            ),
            // AI button
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 35,
              bottom: 15,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTap: _openAIChat,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: isGradientMagic
                                ? themeGradient
                                : LinearGradient(
                                    colors: [
                                      themeColor.withOpacity(0.9),
                                      themeColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: textColor.withOpacity(0.8),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.psychology_alt_rounded,
                            size: 32,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}