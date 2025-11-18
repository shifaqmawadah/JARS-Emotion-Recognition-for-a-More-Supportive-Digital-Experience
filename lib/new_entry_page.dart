import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewEntryPage extends StatefulWidget {
  final void Function(String text, String emotion, String emoji) onSave;

  const NewEntryPage({
    super.key,
    required this.onSave,
  });

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final TextEditingController entryCtrl = TextEditingController();

  final Map<String, String> emotionEmojiMap = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'excited': '🤩',
    'anxious': '😟',
    'neutral': '😐',
  };

  void analyzeAndSave() {
    final text = entryCtrl.text.trim();
    if (text.isEmpty) return;

    final emotion = mockEmotionDetection(text);
    final emoji = emotionEmojiMap[emotion] ?? '🤔';

    widget.onSave(text, emotion, emoji);
    entryCtrl.clear();

    Navigator.pop(context);
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
      case 'anxious':
        return Colors.teal.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = entryCtrl.text.isNotEmpty
        ? mockEmotionDetection(entryCtrl.text)
        : 'neutral';
    final moodColor = _getMoodColor(currentMood);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Diary Entry"),
        backgroundColor: moodColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.blueGrey,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emoji + mood indicator
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: moodColor.withOpacity(0.2),
              child: Text(
                emotionEmojiMap[currentMood] ?? '😐',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "How are you feeling today?",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Diary text input
          TextField(
            controller: entryCtrl,
            maxLines: 8,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Write your thoughts here...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) {
              setState(() {}); // update emoji dynamically
            },
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: analyzeAndSave,
              icon: const Icon(Icons.save),
              label: const Text("Submit Entry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: moodColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ⚡ Mock emotion detection with keywords
  String mockEmotionDetection(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("happy") ||
        lower.contains("joy") ||
        lower.contains("excited") ||
        lower.contains("glad") ||
        lower.contains("cheerful") ||
        lower.contains("content") ||
        lower.contains("delighted")) return "happy";

    if (lower.contains("sad") ||
        lower.contains("cry") ||
        lower.contains("unhappy") ||
        lower.contains("depressed") ||
        lower.contains("miserable") ||
        lower.contains("down") ||
        lower.contains("lonely")) return "sad";

    if (lower.contains("angry") ||
        lower.contains("mad") ||
        lower.contains("frustrated") ||
        lower.contains("annoyed")) return "angry";

    if (lower.contains("excited") ||
        lower.contains("thrilled") ||
        lower.contains("eager") ||
        lower.contains("enthusiastic")) return "excited";

    if (lower.contains("anxious") ||
        lower.contains("nervous") ||
        lower.contains("worried") ||
        lower.contains("stressed")) return "anxious";

    return "neutral";
  }
}
