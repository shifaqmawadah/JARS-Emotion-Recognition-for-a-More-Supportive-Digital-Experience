class DiaryEntry {
  final String date;
  final String text;
  final String emotion;
  final String emoji;

  DiaryEntry({
    required this.date,
    required this.text,
    required this.emotion,
    required this.emoji,
  });
}

List<Map<String, String>> initialEntries = [
  {
    'date': "2025-11-01",
    'text':
        "Today was amazing! I felt really happy after meeting my friends. We laughed a lot.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-01",
    'text':
        "I feel angry when things don’t go as planned.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-02",
    'text':
        "It’s been a miserable day with so many setbacks.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-03",
    'text':
        "Lately, I’ve been feeling really unhappy at work.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-04",
    'text':
        "Feeling frustrated with all these delays at work.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-04",
    'text':
        "I’m delighted to see my friends again this weekend.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-05",
    'text':
        "Had a cheerful walk in the park and loved every moment.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-05",
    'text':
        "Feeling pure joy watching my favorite show tonight.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-06",
    'text':
        "I’m worried that I won’t finish my tasks on time.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-11-07",
    'text':
        "Just had a regular day at home, nothing special.",
    'emotion': "neutral",
    'emoji': "😐",
  },
  {
    'date': "2025-11-08",
    'text':
        "I couldn’t help but cry during that sad movie scene.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-09",
    'text':
        "I couldn’t help but cry during that sad movie scene.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-09",
    'text': "I feel so happy today after completing my project!",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-09",
    'text': "Feeling **anxious** about the upcoming presentation.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-11-10",
    'text': "It’s been a miserable day with so many setbacks.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-11",
    'text': "Feeling **angry** after the argument with my friend.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-12",
    'text': "I’m delighted to see my friends again this weekend.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-13",
    'text': "Feeling **sad** because I missed my family gathering.",
    'emotion': "sad",
    'emoji': "😔",
  },
  {
    'date': "2025-11-15",
    'text': "Feeling **frustrated** with all these delays at work.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-16",
    'text': "I feel content after a relaxing day at home.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-17",
    'text': "I couldn’t help but cry during that sad movie scene.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-17",
    'text': "Feeling nervous about meeting new people today.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-11-19",
    'text': "Feeling **angry** when things don’t go as planned.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-20",
    'text': "I’m glad my hard work finally paid off.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-21",
    'text': "I’m worried that I won’t finish my tasks on time.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-11-22",
    'text': "Feeling lonely even when surrounded by people.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-24",
    'text': "It’s annoying how people ignore the rules here.",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-25",
    'text': "Feeling cheerful after a fun day out with friends.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-26",
    'text': "Been stressed out with too many deadlines lately.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-11-27",
    'text': "Feeling down after hearing some bad news.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-28",
    'text': "I’m mad that someone cut me off in traffic!",
    'emotion': "angry",
    'emoji': "😠",
  },
  {
    'date': "2025-11-29",
    'text': "Feeling delighted watching the sunset today.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-11-30",
    'text': "Feeling anxious about what the future holds.",
    'emotion': "fear",
    'emoji': "😟",
  },
  {
    'date': "2025-12-01",
    'text': "I feel sad missing my old friends.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-01",
    'text':
        "Today was amazing! I felt really happy after meeting my friends. We laughed a lot.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-12-02",
    'text':
        "Today was amazing! I felt really happy after meeting my friends. We laughed a lot.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-12-03",
    'text': "I feel content after a nice evening walk.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-12-04",
    'text': "Feeling nervous about tomorrow’s meeting.",
    'emotion': "fear",
    'emoji': "😟",
  },
  { 
    'date': "2025-12-05",
    'text':
        "Today was amazing! I felt really happy after meeting my friends. We laughed a lot.",
    'emotion': "happy",
    'emoji': "😊",
  },
  {
    'date': "2025-12-02",
    'text':
        "Feeling down today... I couldn't focus and felt really lonely for some reason.",
    'emotion': "sad",
    'emoji': "😢",
  },
  {
    'date': "2025-11-02",
    'text':
        "I'm extremely anxious about tomorrow's presentation. My mind feels stressed and overwhelmed.",
    'emotion': "fear",
    'emoji': "😟",
  },
];
