import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:interacting_tom/features/services/audio_recording_service.dart';
import 'dart:io';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool isRecording = false;
  Duration recordingDuration = Duration.zero;
  Timer? _timer;
  String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  final AudioRecordingService _audioService = AudioRecordingService();
  RecordingSession? _currentSession;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeAudioService();
  }

  Future<void> _initializeAudioService() async {
    final hasPermission = await _audioService.initialize();
    if (!hasPermission) {
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone permission required for recording'),
        backgroundColor: Color(0xFFE74C3C),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        isRecording = true;
        recordingDuration = Duration.zero;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          recordingDuration += const Duration(seconds: 1);
        });
      });

      _showRecordingStarted();
    } catch (e) {
      print('Error starting recording: $e');
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      _currentSession = await _audioService.stopRecording();
      
      setState(() {
        isRecording = false;
      });

      if (_currentSession != null) {
        _showRecordingStopped();
        _showSessionDetails();
      } else {
        _showError('Failed to save recording');
      }
    } catch (e) {
      print('Error stopping recording: $e');
      _showError('Failed to stop recording');
    }
  }

  void _showRecordingStarted() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Recording baby vocalizations... 🎤'),
          ],
        ),
        backgroundColor: const Color(0xFFA0724C),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRecordingStopped() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Recording saved! Duration: ${_formatDuration(recordingDuration)}'),
          ],
        ),
        backgroundColor: const Color(0xFFA8B5A0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSessionDetails() {
    if (_currentSession != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFF9F6F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Recording Complete!',
            style: TextStyle(
              color: Color(0xFF8B5A3C),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Session ID', _currentSession!.sessionId),
              _buildDetailRow('Duration', _formatDuration(_currentSession!.duration)),
              _buildDetailRow('File Size', '${_getFileSize(_currentSession!.audioFilePath)} KB'),
              _buildDetailRow('Timestamp', _formatDateTime(_currentSession!.timestamp)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B5A3C)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF8B5A3C).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF8B5A3C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final sizeInBytes = file.lengthSync();
        return (sizeInBytes / 1024).toStringAsFixed(1);
      }
    } catch (e) {
      print('Error getting file size: $e');
    }
    return '0.0';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9F6F0), // Vanilla
              Color(0xFFF5F1EB), // Cream
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B5A3C),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recording Session',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5A3C),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRecording ? const Color(0xFFE74C3C) : const Color(0xFFA8B5A0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRecording ? Icons.fiber_manual_record : Icons.mic,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isRecording ? 'REC' : 'READY',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Session Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F6F0), // Vanilla
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5A3C).withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Session ID',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B5A3C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sessionId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5A3C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem('Duration', _formatDuration(recordingDuration)),
                                _buildInfoItem('Timestamp', DateTime.now().toString().substring(0, 19)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Recording Visualization
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F0), // Vanilla
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5A3C).withOpacity(0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isRecording ? 140 : 120,
                                  height: isRecording ? 140 : 120,
                                  decoration: BoxDecoration(
                                    color: isRecording 
                                        ? const Color(0xFFE74C3C).withOpacity(0.2)
                                        : const Color(0xFFA0724C).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: isRecording ? [
                                      BoxShadow(
                                        color: const Color(0xFFE74C3C).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ] : null,
                                  ),
                                  child: Icon(
                                    isRecording ? Icons.fiber_manual_record : Icons.mic,
                                    size: isRecording ? 70 : 60,
                                    color: isRecording 
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFFA0724C),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  isRecording ? 'Recording...' : 'Ready to Record',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isRecording 
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF8B5A3C),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isRecording 
                                      ? 'Capturing baby vocalizations'
                                      : 'Press the button to start',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF8B5A3C).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Control Button
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isRecording 
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFFA0724C),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isRecording 
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFFA0724C)).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isRecording ? _stopRecording : _startRecording,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isRecording ? Icons.stop : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isRecording ? 'Stop Recording' : 'Start Recording',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF8B5A3C).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5A3C),
          ),
        ),
      ],
    );
  }
} 