import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      home: const SelectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfigPage(mode: 'workout'),
                  ),
                );
              },
              child: const Text('Workout'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfigPage(mode: 'hantel'),
                  ),
                );
              },
              child: const Text('Hantel'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigPage extends StatefulWidget {
  final String mode;
  const ConfigPage({super.key, required this.mode});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final TextEditingController secondsController = TextEditingController(text: '60');
  final TextEditingController exercisesController = TextEditingController(text: '7');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zurück zum Menü'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SelectionPage()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: secondsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Sekunden pro Übung',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: exercisesController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Anzahl Übungen',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                int seconds = int.tryParse(secondsController.text) ?? 60;
                int count = int.tryParse(exercisesController.text) ?? 7;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExercisePage(
                      durationPerExercise: seconds,
                      numberOfExercises: count,
                      mode: widget.mode,
                    ),
                  ),
                );
              },
              child: const Text('START'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExercisePage extends StatefulWidget {
  final int durationPerExercise;
  final int numberOfExercises;
  final String mode;

  const ExercisePage({
    super.key,
    required this.durationPerExercise,
    required this.numberOfExercises,
    required this.mode,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late int secondsRemaining;
  int currentImageIndex = 1;
  Timer? timer;
  bool isPaused = false;
  final player = AudioPlayer();

  final Map<int, String> workoutNames = {
    1: 'Liegestütz',
    2: 'Planken',
    3: 'Lunge&Kick',
    4: 'Diamond Push-up',
    5: 'Bicycle crunch',
    6: 'Übung 6',
    7: 'Übung 7',
  };

  final Map<int, String> dumbbellNames = {
    1: 'Goblet Squat',
    2: 'Scaption',
    3: 'Arnold Press',
    4: 'Bent Over Lateral Raise',
    5: 'Bent Over Row',
    6: 'Side Lunge',
    7: 'Lying Triceps Press',
    8: 'Seated Biceps Curl Alt.',
    9: '3D Shoulder Press',
    10: 'Bench Press',
    11: 'Corkscrew',
    12: 'Crunch',
  };

  @override
  void initState() {
    super.initState();
    secondsRemaining = widget.durationPerExercise;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!isPaused) {
        if (secondsRemaining > 0) {
          setState(() {
            secondsRemaining--;
          });
        } else {
          await player.play(AssetSource('sounds/success.mp3'));
          if (currentImageIndex < widget.numberOfExercises) {
            setState(() {
              currentImageIndex++;
              secondsRemaining = widget.durationPerExercise;
            });
          } else {
            timer.cancel();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SelectionPage()),
              (route) => false,
            );
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
        secondsRemaining = widget.durationPerExercise;
      });
    }
  }

  void goToNext() {
    if (currentImageIndex < widget.numberOfExercises) {
      setState(() {
        currentImageIndex++;
        secondsRemaining = widget.durationPerExercise;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameMap = widget.mode == 'workout' ? workoutNames : dumbbellNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zurück zum Menü'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            timer?.cancel();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SelectionPage()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/${currentImageIndex}.jpg',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              nameMap[currentImageIndex] ?? 'Übung',
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


