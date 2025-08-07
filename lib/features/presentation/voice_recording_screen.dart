import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:interacting_tom/services/voice_recording_service.dart';  // Temporarily commented out
// import 'package:interacting_tom/widgets/custom_recording_button.dart';  // Temporarily commented out
// import 'package:interacting_tom/widgets/custom_recording_wave_widget.dart';  // Temporarily commented out

class VoiceRecordingScreen extends ConsumerStatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  ConsumerState<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends ConsumerState<VoiceRecordingScreen> {
  // Temporarily disabled due to Android compatibility issues
  // final VoiceRecordingService _recordingService = VoiceRecordingService();
  // bool _isRecording = false;
  // bool _isUploading = false;

  @override
  void dispose() {
    // _recordingService.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recording'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mic_off,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Voice Recording Temporarily Disabled',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'This feature is temporarily disabled due to Android compatibility issues.\n\nWe are working on a solution and will re-enable it soon.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 