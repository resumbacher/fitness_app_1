import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      home: const StartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 24),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExercisePage()),
            );
          },
          child: const Text('START'),
        ),
      ),
    );
  }
}

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int secondsRemaining = 60;
  int currentImageIndex = 1;
  Timer? timer;
  bool isPaused = false;

  final int maxImages = 5;

  final Map<int, String> exerciseNames = {
    1: 'Liegestütz',
    2: 'Übung 2',
    3: 'Übung 3',
    4: 'Übung 4',
    5: 'Übung 5',
  };

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        if (secondsRemaining > 0) {
          setState(() {
            secondsRemaining--;
          });
        } else {
          if (currentImageIndex < maxImages) {
            setState(() {
              currentImageIndex++;
              secondsRemaining = 60;
            });
          } else {
            timer.cancel();
            Navigator.pop(context);
          }
        }
      }
    });
  }

  void pauseOrResume() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void goToPrevious() {
    if (currentImageIndex > 1) {
      setState(() {
        currentImageIndex--;
        secondsRemaining = 60;
      });
    }
  }

  void goToNext() {
    if (currentImageIndex < maxImages) {
      setState(() {
        currentImageIndex++;
        secondsRemaining = 60;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$currentImageIndex.jpg',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              exerciseNames[currentImageIndex] ?? 'Übung',
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '$secondsRemaining Sekunden',
              style: const TextStyle(fontSize: 24, color: Colors.orange),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: goToPrevious,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  iconSize: 40,
                ),
                const SizedBox(width: 30),
                IconButton(
                  onPressed: pauseOrResume,
                  icon: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                  ),
                  iconSize: 40,
                ),
                const SizedBox(width: 30),
                IconButton(
                  onPressed: goToNext,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  iconSize: 40,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}