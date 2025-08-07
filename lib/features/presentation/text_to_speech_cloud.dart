// Temporarily commented out due to Android compatibility issues
// This file will be re-enabled once we resolve the just_audio plugin compatibility

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/features/data/google_cloud_repository.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/openai_response_controller.dart';
// import 'package:just_audio/just_audio.dart';  // Temporarily commented out

class TextToSpeechCloud extends ConsumerStatefulWidget {
  final Widget child;

  const TextToSpeechCloud({super.key, required this.child});

  @override
  ConsumerState<TextToSpeechCloud> createState() => _TextToSpeechState();
}

class _TextToSpeechState extends ConsumerState<TextToSpeechCloud> {
  // Temporarily disabled due to Android compatibility issues
  // final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    // player.dispose();
    super.dispose();
  }

  Future<void> _playTextToSpeech(String text) async {
    try {
      final currentLang = ref.read(animationStateControllerProvider).language;
      final audioBytes =
          await ref.read(synthesizeTextFutureProvider((text: text, lang: currentLang)).future);
      // player.setAudioSource(audioBytes as AudioSource); // Added type cast
      // await player.play();
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing text to speech: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily disabled due to Android compatibility issues
    return GestureDetector(
      onTap: () {
        final response = ref.read(openAIResponseControllerProvider);
        if (response != null) {
          _playTextToSpeech(response);
        }
      },
      child: widget.child,
    );
    
    // Original implementation commented out
    /*
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<AsyncValue<AudioPlayer?>>(
          audioPlayerProvider,
          (previous, next) {
            next.whenData((player) {
              if (player != null) {
                player.playerStateStream.listen((state) {
                  if (state.processingState == ProcessingState.completed) {
                    setState(() {
                      isPlaying = false;
                    });
                  }
                });
              }
            });
          },
        );

        return GestureDetector(
          onTap: () {
            final response = ref.read(openAIResponseControllerProvider);
            if (response != null) {
              _playTextToSpeech(response);
            }
          },
          child: widget.child,
        );
      },
    );
    */
  }
}
*/
