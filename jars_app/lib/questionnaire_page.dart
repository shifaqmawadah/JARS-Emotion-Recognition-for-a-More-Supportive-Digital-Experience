import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StressQuestionnairePage extends StatefulWidget {
  final String userEmail;

  const StressQuestionnairePage({super.key, required this.userEmail});

  @override
  State<StressQuestionnairePage> createState() =>
      _StressQuestionnairePageState();
}

class _StressQuestionnairePageState extends State<StressQuestionnairePage> {
  String q1 = "";
  String q2 = "";
  String q3 = "";
  String q4 = "";
  String q5 = "";
  String q6 = "";
  String q7 = "";
  String q8 = "";

  bool loading = false;

  Future<void> submitAnswers() async {
    if ([q1, q2, q3, q4, q5, q6, q7, q8].contains("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(
            "https://humancc.site/shifaqmawaddah/jars_app/save_questionnaire.php"),
        body: {
          "email": widget.userEmail,
          "q1": q1,
          "q2": q2,
          "q3": q3,
          "q4": q4,
          "q5": q5,
          "q6": q6,
          "q7": q7,
          "q8": q8,
        },
      );

      setState(() => loading = false);

      final res = jsonDecode(response.body);
      if (res["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Answers saved successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to save answers")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget buildQuestionCard(String title, List<String> options, String value,
      Function(String?) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            ...options.map((opt) {
              return RadioListTile(
                activeColor: Colors.grey.shade500,
                title: Text(opt, style: const TextStyle(fontSize: 14)),
                value: opt,
                groupValue: value,
                onChanged: onChanged,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Emotional Well-Being Questionnaire",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade500,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildQuestionCard(
              "1. How often do you reflect on your emotions?",
              ["Rarely", "Sometimes", "Often", "Every day"],
              q1,
              (v) => setState(() => q1 = v!),
            ),
            buildQuestionCard(
              "2. How do you usually respond when you feel stressed?",
              ["I avoid the situation", "I distract myself", "I talk to someone", "I try to solve the issue"],
              q2,
              (v) => setState(() => q2 = v!),
            ),
            buildQuestionCard(
              "3. When you are overwhelmed, what helps you calm down?",
              ["Breathing / Meditation", "Listening to music", "Writing or journaling", "Physical activity"],
              q3,
              (v) => setState(() => q3 = v!),
            ),
            buildQuestionCard(
              "4. How do you usually express negative emotions?",
              ["I bottle them up", "I express them indirectly", "I express them openly", "I seek support"],
              q4,
              (v) => setState(() => q4 = v!),
            ),
            buildQuestionCard(
              "5. How strong is your emotional support system?",
              ["Very weak", "Some support", "Good support", "Very strong support"],
              q5,
              (v) => setState(() => q5 = v!),
            ),
            buildQuestionCard(
              "6. How quickly do you recover from emotional setbacks?",
              ["Very slowly", "Slowly", "Moderately fast", "Very fast"],
              q6,
              (v) => setState(() => q6 = v!),
            ),
            buildQuestionCard(
              "7. When facing problems, how do you cope?",
              ["I shut down", "I wait until it passes", "I look for solutions", "I actively seek help"],
              q7,
              (v) => setState(() => q7 = v!),
            ),
            buildQuestionCard(
              "8. How well do you understand your own emotions?",
              ["Not well", "A little", "Fairly well", "Very well"],
              q8,
              (v) => setState(() => q8 = v!),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
