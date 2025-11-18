import 'package:flutter/material.dart';
import 'login_page.dart';

class StressQuestionnairePage extends StatefulWidget {
  const StressQuestionnairePage({super.key});

  @override
  State<StressQuestionnairePage> createState() =>
      _StressQuestionnairePageState();
}

class _StressQuestionnairePageState extends State<StressQuestionnairePage> {
  // Questions state
  String stressHandling = '';
  String moodCoping = '';
  String relaxationMethod = '';
  String socialSupport = '';
  bool shareOnFeed = false;

  void _submit() {
    if (stressHandling.isEmpty ||
        moodCoping.isEmpty ||
        relaxationMethod.isEmpty ||
        socialSupport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please answer all questions before continuing.')),
      );
      return;
    }

    // Save or process answers here if needed
    print('Stress Handling: $stressHandling');
    print('Mood Coping: $moodCoping');
    print('Relaxation Method: $relaxationMethod');
    print('Social Support: $socialSupport');
    print('Share on Feed: $shareOnFeed');

    // Navigate to LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget buildQuestion(String question, List<Map<String, String>> options,
      String groupValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...options.map(
          (option) => RadioListTile(
            title: Text(option['label']!),
            value: option['value']!,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emotion & Coping Survey'),
        backgroundColor: Colors.grey.shade700,
        automaticallyImplyLeading: false, // remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildQuestion(
              '1. How do you usually handle your emotions?',
              [
                {'label': 'Talk to someone', 'value': 'talk'},
                {'label': 'Write in a journal', 'value': 'journal'},
                {'label': 'Exercise / Physical activity', 'value': 'exercise'},
                {'label': 'Meditation / Relaxation', 'value': 'meditation'},
              ],
              stressHandling,
              (val) => setState(() => stressHandling = val!),
            ),
            buildQuestion(
              '2. What do you do to cope with negative moods?',
              [
                {'label': 'Listen to music', 'value': 'music'},
                {'label': 'Watch videos / movies', 'value': 'videos'},
                {'label': 'Go for a walk', 'value': 'walk'},
                {'label': 'Other', 'value': 'other'},
              ],
              moodCoping,
              (val) => setState(() => moodCoping = val!),
            ),
            buildQuestion(
              '3. What is your preferred relaxation method?',
              [
                {'label': 'Meditation / Yoga', 'value': 'meditation'},
                {'label': 'Reading / Writing', 'value': 'reading'},
                {'label': 'Listening to music', 'value': 'music'},
                {'label': 'Exercise', 'value': 'exercise'},
              ],
              relaxationMethod,
              (val) => setState(() => relaxationMethod = val!),
            ),
            buildQuestion(
              '4. Do you talk to someone when stressed?',
              [
                {'label': 'Yes, regularly', 'value': 'yes'},
                {'label': 'Sometimes', 'value': 'sometimes'},
                {'label': 'No, I prefer to handle it alone', 'value': 'no'},
              ],
              socialSupport,
              (val) => setState(() => socialSupport = val!),
            ),
            SwitchListTile(
              title: Text(
                  shareOnFeed ? 'Yes, I like sharing' : 'No, keep it private'),
              value: shareOnFeed,
              onChanged: (val) => setState(() => shareOnFeed = val),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
