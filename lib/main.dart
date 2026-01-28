import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  bool quizStarted = false;
  bool quizFinished = false;
  bool answered = false;

  int questionIndex = 0;
  int score = 0;
  int timeLeft = 15;
  int? selectedAnswer;

  Timer? timer;

  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  final List<Map<String, dynamic>> questions = [
    {
      'q':
          'If all bicycles have wheels and a mountain bike is a bicycle, what can we conclude?',
      'a': [
        'Mountain bikes have engines',
        'Mountain bikes have wheels',
        'All wheels are bicycles',
        'Bicycles are mountains'
      ],
      'c': 1
    },
    {
      'q': 'Which number comes next: 2, 4, 8, 16, ?',
      'a': ['18', '24', '30', '32'],
      'c': 3
    },
    {
      'q': 'Rearrange the letters "CIFAIPC"',
      'a': ['PACIFIC', 'OFFICIA', 'TRAFFIC', 'SPECIFIC'],
      'c': 0
    },
    {
      'q':
          'A farmer has 17 sheep. All but 9 run away. How many sheep are left?',
      'a': ['8', '9', '17', '0'],
      'c': 1
    },
    {
      'q': 'Which one is the odd one out?',
      'a': ['Triangle', 'Square', 'Circle', 'Cube'],
      'c': 3
    },
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    fadeAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);
  }

  void startQuiz() {
    setState(() {
      quizStarted = true;
      quizFinished = false;
      questionIndex = 0;
      score = 0;
      answered = false;
      selectedAnswer = null;
    });
    startTimer();
    animationController.forward(from: 0);
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        setState(() => answered = true);
      }
    });
  }

  void selectAnswer(int index) {
    if (answered) return;

    timer?.cancel();
    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == questions[questionIndex]['c']) score++;
    });
  }

  void nextQuestion() {
    timer?.cancel();

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        answered = false;
        selectedAnswer = null;
      });
      animationController.forward(from: 0);
      startTimer();
    } else {
      setState(() {
        quizStarted = false;
        quizFinished = true;
      });
    }
  }

  void restartQuiz() {
    setState(() {
      quizStarted = false;
      quizFinished = false;
      questionIndex = 0;
      score = 0;
      answered = false;
      selectedAnswer = null;
    });
  }

  Color optionTextColor(Color bg) {
    if (bg == Colors.green || bg == Colors.redAccent) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF4FACFE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: quizStarted
            ? buildQuiz()
            : quizFinished
                ? buildEndView()
                : buildStartView(),
      ),
    );
  }

  Widget buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz',
            style: TextStyle(fontSize: 34, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: startQuiz,
            child: const Text('Start Quiz 🚀'),
          ),
        ],
      ),
    );
  }

  Widget buildEndView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉 Quiz Completed!',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Score: $score / ${questions.length}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: restartQuiz,
            child: const Text('Restart Quiz 🔄'),
          ),
        ],
      ),
    );
  }

  Widget buildQuiz() {
    final q = questions[questionIndex];

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (questionIndex + 1) / questions.length,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
            const SizedBox(height: 20),
            Text(
              '⏱ $timeLeft s',
              style: TextStyle(
                color: timeLeft <= 5 ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              q['q'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ...List.generate(4, (i) {
              Color bg = Colors.white24;
              if (answered) {
                if (i == q['c']) bg = Colors.green;
                else if (i == selectedAnswer) bg = Colors.redAccent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg,
                      foregroundColor: optionTextColor(bg),
                    ),
                    onPressed: answered ? null : () => selectAnswer(i),
                    child: Text(
                      q['a'][i],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
            if (answered)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text(
                  questionIndex < questions.length - 1
                      ? 'Next ➜'
                      : 'Finish 🎉',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
