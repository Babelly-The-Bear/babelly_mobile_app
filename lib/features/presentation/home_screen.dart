import 'package:flutter/material.dart';
import 'package:interacting_tom/features/presentation/animation_screen.dart';
import 'package:interacting_tom/features/presentation/flag_switch.dart';
import 'package:interacting_tom/features/presentation/speech_to_text.dart';
import 'package:interacting_tom/features/presentation/voice_recording_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('home screen built');
    return Scaffold(
      body: const AnimationScreen(),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        spacing: 30,
        children: [
          const FlagSwitch(), 
          const STTWidget(),
          FloatingActionButton(
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
