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
  final int pauseBetweenExercises;
  final String mode;

  const ExercisePage({
    super.key,
    required this.durationPerExercise,
    required this.numberOfExercises,
    required this.mode,
    required this.pauseBetweenExercises,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late int secondsRemaining;
  int currentExerciseIndex = 0;
  Timer? timer;
  bool isPaused = false;
  bool inPause = false;
  final player = AudioPlayer();
  final flutterTts = FlutterTts();
  List<int> selectedExercises = [];

  final Map<int, String> workoutNames = {
    1: 'Liegestütz', 2: 'Planken', 3: 'Lunge&Kick', 4: 'Diamond Push-up',
    5: 'Bicycle crunch', 6: 'drop&touch', 7: 'one leg push up',
    8: '1-2 box and kick', 9: 'windscreen wiper', 10: 'reverse crunch & hug',
    11: 'push up & rotation', 12: 'squat thrusts', 13: 'skater',
    14: 'mountain climbers', 15: 'jumping jacks', 16: 'side plank crunch',
    17: 'power squat', 18: 'one leg wall sit', 19: 'triceps dip',
    20: 'v sit twist', 21: 'advanced bird dog', 22: 'bird dog',
    23: 'mountain climbers', 24: 'long jumps', 25: 'downward dog grasshopper',
    26: 'hindu push up', 27: 'superman', 28: 'full side plank',
    29: 'side to side hop', 30: 'chair split squat', 31: 'lunge',
    32: 'reverse plank', 33: 'abdominal crunch', 34: 'high knees',
  };

  final Map<int, String> dumbbellNames = {
    1: 'Goblet Squat', 2: 'Scaption', 3: 'Arnold Press',
    4: 'Bent Over Lateral Raise', 5: 'Bent Over Row', 6: 'Side Lunge',
    7: 'Lying Triceps Press', 8: 'Seated Biceps Curl Alt.',
    9: '3D Shoulder Press', 10: 'Bench Press', 11: 'Corkscrew',
    12: 'Crunch',
  };

  @override
  void initState() {
    super.initState();
    initWorkout();
  }

  Future<void> initWorkout() async {
    await flutterTts.speak("Willkommen zur Fitness App");
    await Future.delayed(const Duration(seconds: 2));
    final max = widget.mode == 'workout' ? 34 : 12;
    selectedExercises = List.generate(max, (i) => i + 1)..shuffle();
    selectedExercises = selectedExercises.take(widget.numberOfExercises).toList();
    secondsRemaining = widget.durationPerExercise;
    startTimer();
    await announceNextExercise();
  }

  Future<void> announceNextExercise() async {
    final nameMap = widget.mode == 'workout' ? workoutNames : dumbbellNames;
    final currentExercise = selectedExercises[currentExerciseIndex];
    final name = nameMap[currentExercise] ?? "Übung";
    await flutterTts.speak(name);
    await Future.delayed(const Duration(seconds: 1));
    await flutterTts.speak("3");
    await Future.delayed(const Duration(seconds: 1));
    await flutterTts.speak("2");
    await Future.delayed(const Duration(seconds: 1));
    await flutterTts.speak("1");
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
          if (inPause) {
            if (currentExerciseIndex < widget.numberOfExercises - 1) {
              setState(() {
                currentExerciseIndex++;
                inPause = false;
                secondsRemaining = widget.durationPerExercise;
              });
              await announceNextExercise();
            } else {
              timer.cancel();
              await flutterTts.speak("Fertig, alles geschafft!");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SelectionPage()),
                (route) => false,
              );
            }
          } else {
            setState(() {
              inPause = true;
              secondsRemaining = widget.pauseBetweenExercises;
            });
            await flutterTts.speak("Rest");
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

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameMap = widget.mode == 'workout' ? workoutNames : dumbbellNames;
    final currentExercise = selectedExercises[currentExerciseIndex];
    final total = widget.numberOfExercises;
    final done = currentExerciseIndex + (inPause ? 1 : 0);
    final remaining = total - done;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zurück zum Menü'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
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
            if (!inPause)
              Image.asset(
                'assets/images/$currentExercise.jpg',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            Text(
              inPause ? 'Pause' : nameMap[currentExercise] ?? 'Übung',
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '$secondsRemaining Sekunden',
              style: const TextStyle(fontSize: 24, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            Text(
              'Übung ${done + 1} von $total (${remaining} verbleibend)',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: done / total,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 30),
            IconButton(
              onPressed: pauseOrResume,
              icon: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }
}
