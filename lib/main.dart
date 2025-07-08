import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  final TextEditingController pauseController = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zurück zum Menü'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
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
            const SizedBox(height: 20),
            TextField(
              controller: pauseController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Wartezeit zwischen Übungen (Sekunden)',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                int seconds = int.tryParse(secondsController.text) ?? 60;
                int count = int.tryParse(exercisesController.text) ?? 7;
                int pause = int.tryParse(pauseController.text) ?? 5;

                int maxExercises = widget.mode == 'workout' ? 34 : 12;
                if (count > maxExercises) count = maxExercises;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExercisePage(
                      durationPerExercise: seconds,
                      numberOfExercises: count,
                      mode: widget.mode,
                      pauseBetweenExercises: pause,
                      onFinished: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectionPage()),
                          (route) => false,
                        );
                      },
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

final Map<int, String> workoutNames = {
  1: 'Liegestütz',
  2: 'Planken',
  3: 'Lunge&Kick',
  4: 'Diamond Push-up',
  5: 'Bicycle crunch',
  6: 'drop&touch',
  7: 'one leg push up',
  8: '1-2 box and kick',
  9: 'windscreen wiper',
  10: 'reverse crunch & hug',
  11: 'push up & rotation',
  12: 'squat thrusts',
  13: 'skater',
  14: 'mountain climbers',
  15: 'jumping jacks',
  16: 'side plank crunch',
  17: 'power squat',
  18: 'one leg wall sit',
  19: 'triceps dip',
  20: 'v sit twist',
  21: 'advanced bird dog',
  22: 'bird dog',
  23: 'mountain climbers',
  24: 'long jumps',
  25: 'downward dog grasshopper',
  26: 'hindu push up',
  27: 'superman',
  28: 'full side plank',
  29: 'side to side hop',
  30: 'chair split squat',
  31: 'lunge',
  32: 'reverse plank',
  33: 'abdominal crunch',
  34: 'high knees',
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


class ExercisePage extends StatefulWidget {
  final int durationPerExercise;
  final int numberOfExercises;
  final String mode;
  final int pauseBetweenExercises;
  final VoidCallback onFinished;

  const ExercisePage({
    super.key,
    required this.durationPerExercise,
    required this.numberOfExercises,
    required this.mode,
    required this.pauseBetweenExercises,
    required this.onFinished,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late List<int> exerciseIndices;
  int currentExercise = 0;
  int remainingSeconds = 0;
  bool isPaused = false;
  late Timer timer;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    exerciseIndices = _generateRandomExercises();
    _startExercise();
  }

  List<int> _generateRandomExercises() {
    final random = Random();
    final indices = <int>{};
    int max = widget.mode == 'workout' ? workoutNames.length : dumbbellNames.length;

    while (indices.length < widget.numberOfExercises) {
      indices.add(random.nextInt(max) + 1);
    }
    return indices.toList();
  }

  void _startExercise() async {
    setState(() {
      isPaused = false;
      remainingSeconds = widget.durationPerExercise;
    });

    String name = _getCurrentExerciseName();
    await tts.setLanguage("en-US");
    tts.speak(name);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds == 0) {
        timer.cancel();

        if (currentExercise + 1 < exerciseIndices.length) {
          setState(() {
            currentExercise++;
          });

          Future.delayed(Duration(seconds: widget.pauseBetweenExercises), () {
            _startExercise();
          });
        } else {
          widget.onFinished();
        }
      }
    });
  }

  String _getCurrentExerciseName() {
    int id = exerciseIndices[currentExercise];
    return widget.mode == 'workout' ? workoutNames[id]! : dumbbellNames[id]!;
  }

  String _getCurrentImagePath() {
    int id = exerciseIndices[currentExercise];
    String prefix = widget.mode == 'workout' ? '' : 'h';
    return 'assets/images/$prefix$id.jpg';
  }

  @override
  void dispose() {
    timer.cancel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = _getCurrentExerciseName();
    String imagePath = _getCurrentImagePath();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            timer.cancel();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SelectionPage()),
              (route) => false,
            );
          },
        ),
        title: const Text('Übung', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Noch $remainingSeconds Sekunden',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
