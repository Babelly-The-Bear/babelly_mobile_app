import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/services/voice_recording_service.dart';
import 'package:interacting_tom/widgets/custom_recording_button.dart';
import 'package:interacting_tom/widgets/custom_recording_wave_widget.dart';

class VoiceRecordingScreen extends ConsumerStatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  ConsumerState<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends ConsumerState<VoiceRecordingScreen> {
  final VoiceRecordingService _recordingService = VoiceRecordingService();
  bool _isRecording = false;
  String? _uploadedFileUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _recordingService.dispose();
    super.dispose();
  }

  Future<void> _handleRecording() async {
    if (kIsWeb) {
      _showSnackBar('Voice recording is not fully supported in web browsers. Please use a mobile device for the full voice recording experience.');
      return;
    }

    if (!_isRecording) {
      // Start recording
      final started = await _recordingService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
        });
      } else {
        _showSnackBar('Failed to start recording. Please check microphone permissions.');
      }
    } else {
      // Stop recording
      final recordingPath = await _recordingService.stopRecording();
      setState(() {
        _isRecording = false;
      });

      if (recordingPath != null) {
        // Upload to cloud storage
        await _uploadRecording(recordingPath);
      } else {
        _showSnackBar('Failed to stop recording.');
      }
    }
  }

            Future<void> _uploadRecording(String localFilePath) async {
            setState(() {
              _isUploading = true;
            });

            try {
              final cloudUrl = await _recordingService.uploadToCloudStorage(localFilePath);
              setState(() {
                _uploadedFileUrl = cloudUrl;
                _isUploading = false;
              });

              if (cloudUrl != null) {
                _showSnackBar('Recording uploaded successfully! Metadata stored in database.');
                // Here you can trigger analysis or send the URL to your backend
                _triggerAnalysis(cloudUrl);
              } else {
                _showSnackBar('Failed to upload recording.');
              }
            } catch (e) {
              setState(() {
                _isUploading = false;
              });
              _showSnackBar('Error uploading recording: $e');
            }
          }

  void _triggerAnalysis(String cloudUrl) {
    // TODO: Implement analysis trigger
    // This could be:
    // 1. Send to your backend API
    // 2. Trigger a Cloud Function
    // 3. Send to Google Cloud Speech-to-Text
    // 4. Send to your AI analysis service
    print('Triggering analysis for: $cloudUrl');
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
        backgroundColor: const Color(0xFFD6E2EA),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD6E2EA),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status text
            Text(
              kIsWeb 
                ? 'Web Browser Detected'
                : (_isRecording ? 'Recording...' : 'Tap to Record'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Recording wave animation
            if (_isRecording) const CustomRecordingWaveWidget(),
            const SizedBox(height: 30),

            // Recording button
            CustomRecordingButton(
              isRecording: kIsWeb ? false : _isRecording,
              onPressed: _isUploading ? () {} : _handleRecording,
            ),
            const SizedBox(height: 30),

            // Upload status
            if (_isUploading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Uploading to cloud...'),
                ],
              ),

            // Uploaded file info
            if (_uploadedFileUrl != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_done, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Recording Uploaded!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analysis in progress...',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    kIsWeb ? Icons.warning_amber : Icons.info_outline, 
                    color: kIsWeb ? Colors.orange : Colors.blue
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb ? 'Web Browser Limitation' : 'How it works:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb 
                      ? 'Voice recording requires microphone access and is best experienced on mobile devices. Please use a mobile device for the full voice recording functionality.'
                      : '1. Tap the button to start recording\n'
                        '2. Speak your message\n'
                        '3. Tap again to stop and upload\n'
                        '4. Your recording will be analyzed automatically',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 