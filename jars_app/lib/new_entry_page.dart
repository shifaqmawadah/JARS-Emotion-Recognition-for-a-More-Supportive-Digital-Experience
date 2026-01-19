import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'diary_entry.dart';
import 'theme_manager.dart';

class NewEntryPage extends StatefulWidget {
  final void Function(String text, String emotion, String emoji)? onSave;

  const NewEntryPage({super.key, this.onSave});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final TextEditingController entryCtrl = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  late ThemeManager _themeManager;
  String detectedMood = 'neutral';
  bool _isTyping = false;
  double _textFieldOpacity = 0.0;
  Box<DiaryEntry>? diaryBox;

  Timer? _debounce;
  static const Duration _debounceDuration = Duration(milliseconds: 600);

  final Map<String, Map<String, dynamic>> emotionData = {
    'happy': {'emoji': '😊', 'title': 'Feeling Happy', 'subtitle': 'Joy is the simplest form of gratitude'},
    'sad': {'emoji': '😢', 'title': 'Feeling Sad', 'subtitle': 'Tears water the seeds of future happiness'},
    'angry': {'emoji': '😠', 'title': 'Feeling Angry', 'subtitle': 'Your feelings are valid. Let\'s process them together'},
    'Fear': {'emoji': '😟', 'title': 'Feeling Anxious', 'subtitle': 'You have survived 100% of your bad days'},
    'neutral': {'emoji': '😌', 'title': 'Feeling Neutral', 'subtitle': 'Every moment is a fresh beginning'},
  };

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager.instance;
    _textFocusNode.addListener(_onFocusChange);

    // Initialize Hive
    Hive.initFlutter().then((_) async {
      Hive.registerAdapter(DiaryEntryAdapter());
      diaryBox = await Hive.openBox<DiaryEntry>('diaryBox');
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _textFieldOpacity = 1.0);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textFocusNode.removeListener(_onFocusChange);
    entryCtrl.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isTyping = _textFocusNode.hasFocus;
    });
  }

  void _analyzeTextDebounced() {
    _debounce?.cancel();

    _debounce = Timer(_debounceDuration, () async {
      final text = entryCtrl.text.trim();
      if (text.isEmpty) {
        if (mounted) {
          setState(() => detectedMood = 'neutral');
        }
        return;
      }

      final mood = await _predictEmotion(text);
      print("Detected Mood: $mood");

      if (mounted && mood != detectedMood) {
        setState(() => detectedMood = mood);
      }
    });
  }

  Future<String> _predictEmotion(String text) async {
    try {
      final uri = Uri.parse('https://nephelinitic-joetta-windedly.ngrok-free.dev/predict');

      print("📡 Sending request to API...");
      print("Text: $text");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['emotion'] ?? 'neutral';
      }
    } catch (e) {
      print("FETCH FAILED: $e");
    }

    return 'neutral';
  }

  void _showFetchError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: GoogleFonts.poppins(color: Colors.white))),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

  Color _getThemeColor(Color baseColor) => _themeManager.getThemeColor(baseColor);

  Future<void> _saveEntry() async {
    final text = entryCtrl.text.trim();
    if (text.isEmpty) {
      _showEmptyWarning();
      return;
    }

    final mood = await _predictEmotion(text);
    if (mounted) setState(() => detectedMood = mood);

    final emoji = emotionData[detectedMood]?['emoji'] ?? '😌';
    final now = DateTime.now();
    final date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final entry =
        DiaryEntry(date: date, text: text, emotion: detectedMood, emoji: emoji);
    await diaryBox?.add(entry);

    _printHiveEntries();
    widget.onSave?.call(text, detectedMood, emoji);

    _showSuccessAnimation();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _printHiveEntries() async {
    if (diaryBox != null) {
      print("=== Hive Entries ===");
      for (var entry in diaryBox!.values) {
        print(
            "Date: ${entry.date}, Text: ${entry.text}, Emotion: ${entry.emotion}, Emoji: ${entry.emoji}");
      }
      print("===================");
    }
  }

  void _showEmptyWarning() {
    final themeColor = _getThemeColor(_getMoodColor(detectedMood));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please write something before saving',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: themeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessAnimation() {
    final themeColor = _getThemeColor(_getMoodColor(detectedMood));
    final emoji = emotionData[detectedMood]?['emoji'] ?? '😌';

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: themeColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ],
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
              ),
              const SizedBox(height: 20),
              Text(
                'Entry Saved!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re feeling ${detectedMood}',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(_getMoodColor(detectedMood));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: themeColor,
            elevation: 4,
            pinned: true,
            expandedHeight: 0, 
            flexibleSpace: null, 
            title: Text(
              "New Journal Entry",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _saveEntry,
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                ),
              ),
            ],
          ),

          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Mood card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeColor.withOpacity(0.9),
                            themeColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                emotionData[detectedMood]?['emoji'] ?? '😌',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Detected Mood",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  detectedMood.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  emotionData[detectedMood]?['subtitle'] ?? 'Every moment is a fresh beginning',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.mood_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Writing area
                    AnimatedOpacity(
                      opacity: _textFieldOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note_rounded, color: themeColor, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  "Your Thoughts",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    DateFormat('MMM dd').format(DateTime.now()),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: themeColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: entryCtrl,
                              focusNode: _textFocusNode,
                              maxLines: null,
                              minLines: 10,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: "Write freely about your day, thoughts, and feelings...",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              cursorColor: themeColor,
                              onChanged: (_) => _analyzeTextDebounced(),
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: Colors.grey.shade200,
                              height: 1,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, 
                                    color: themeColor, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Your mood updates as you type. Keep writing!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          shadowColor: themeColor.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_rounded, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              "Save Journal Entry",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick prompts (only show when not typing and empty)
                    if (!_isTyping && entryCtrl.text.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: themeColor),
                                const SizedBox(width: 10),
                                Text(
                                  "Quick Prompts",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tap any prompt to start writing:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildPromptButton("Today I'm grateful for...", themeColor),
                                _buildPromptButton("Something that made me smile", themeColor),
                                _buildPromptButton("Challenges I faced today", themeColor),
                                _buildPromptButton("My biggest accomplishment", themeColor),
                                _buildPromptButton("How I'm feeling right now", themeColor),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptButton(String text, Color themeColor) {
    return GestureDetector(
      onTap: () {
        entryCtrl.text = text;
        _textFocusNode.requestFocus();
        _analyzeTextDebounced();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeColor.withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: themeColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}