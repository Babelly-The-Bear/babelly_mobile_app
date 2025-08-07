import 'package:flutter/material.dart';
import 'package:interacting_tom/features/presentation/animation_screen.dart';
import 'package:interacting_tom/features/presentation/flag_switch.dart';
import 'package:interacting_tom/features/presentation/voice_recording_screen.dart';
import 'package:interacting_tom/features/presentation/recording_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isRecording = false;
  int sessionsToday = 0;
  double avgScore = 85.5;

  @override
  Widget build(BuildContext context) {
    print('home screen built');
    return Scaffold(
      body: const AnimationScreen(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FlagSwitch(), 
          const SizedBox(height: 30),
          // const STTWidget(),  // Temporarily commented out
          // const SizedBox(height: 30),
          FloatingActionButton(
            heroTag: "voice_recording_button",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceRecordingScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
