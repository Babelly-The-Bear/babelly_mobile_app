// Temporarily commented out due to Android compatibility issues
// This file will be re-enabled once we resolve the flutter_tts plugin compatibility

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechLocal extends ConsumerStatefulWidget {
  final Widget child;

  const TextToSpeechLocal({super.key, required this.child});

  @override
  ConsumerState<TextToSpeechLocal> createState() => _TextToSpeechLocalState();
}

class _TextToSpeechLocalState extends ConsumerState<TextToSpeechLocal> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    try {
      setState(() {
        isPlaying = true;
      });
      
      await flutterTts.speak(text);
      
      flutterTts.setCompletionHandler(() {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      print('Error in text-to-speech: $e');
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isPlaying) {
          _speak("Hello, this is a test of local text-to-speech functionality.");
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
*/
