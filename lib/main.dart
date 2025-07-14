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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/start_bild.jpg',
            fit: BoxFit.cover,
          ),
          Center(
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
        ],
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
                      //enableHalfTime: true,
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
  int currentExercise = 0;
  int remainingTime = 0;
  bool isPaused = false;
  Timer? timer;
  List<String> exercises = [];
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    generateExercises();
    startExercise();
  }

  @override
  void dispose() {
    timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void generateExercises() {
    final source = widget.mode == 'workout' ? workoutNames : dumbbellNames;
    final random = Random();
    final keys = source.keys.toList()..shuffle();
    exercises = keys.take(widget.numberOfExercises).map((k) => source[k]!).toList();
  }

  void startExercise() {
    setState(() {
      isPaused = false;
      remainingTime = widget.durationPerExercise;
    });

    speak(exercises[currentExercise]);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (remainingTime == widget.durationPerExercise ~/ 2) {
          speak("Half-time");
        }

        if (remainingTime > 0) {
          remainingTime--;
        } else {
          t.cancel();
          if (currentExercise < exercises.length - 1) {
            setState(() {
              isPaused = true;
              remainingTime = widget.pauseBetweenExercises;
            });

            speak("Pause");

            Timer.periodic(const Duration(seconds: 1), (pt) {
              setState(() {
                if (remainingTime > 0) {
                  remainingTime--;
                } else {
                  pt.cancel();
                  setState(() {
                    currentExercise++;
                  });
                  startExercise();
                }
              });
            });
          } else {
            widget.onFinished();
          }
        }
      });
    });
  }

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  void goToPreviousExercise() {
    if (currentExercise > 0) {
      timer?.cancel();
      setState(() {
        currentExercise--;
        startExercise();
      });
    }
  }

  void goToNextExercise() {
    if (currentExercise < exercises.length - 1) {
      timer?.cancel();
      setState(() {
        currentExercise++;
        startExercise();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = widget.mode == 'workout'
        ? 'assets/images/${currentExercise + 1}.jpg'
        : 'assets/images/h${currentExercise + 1}.jpg';

    double progress = remainingTime / widget.durationPerExercise;

    return Scaffold(
      appBar: AppBar(
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
        title: Text('Übung ${currentExercise + 1} / ${exercises.length}'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (!isPaused)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                exercises[currentExercise],
                style: const TextStyle(color: Colors.white, fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
          if (isPaused && currentExercise + 1 < exercises.length)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pause...\nNächste Übung: ${exercises[currentExercise + 1]}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          Image.asset(
            imagePath,
            height: 250,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Bild nicht gefunden", style: TextStyle(color: Colors.grey));
            },
          ),
          Text(
            '${remainingTime}s',
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
          LinearProgressIndicator(
            value: isPaused ? 1.0 : progress,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (currentExercise > 0)
                ElevatedButton(
                  onPressed: goToPreviousExercise,
                  child: const Text("Zurück"),
                ),
              if (currentExercise < exercises.length - 1)
                ElevatedButton(
                  onPressed: goToNextExercise,
                  child: const Text("Weiter"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
