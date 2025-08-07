import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordingSession {
  final String sessionId;
  final DateTime timestamp;
  final Duration duration;
  final String audioFilePath;
  final String? childId;
  final Map<String, dynamic> metadata;

  RecordingSession({
    required this.sessionId,
    required this.timestamp,
    required this.duration,
    required this.audioFilePath,
    this.childId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inMilliseconds,
      'audioFilePath': audioFilePath,
      'childId': childId,
      'metadata': metadata,
    };
  }

  factory RecordingSession.fromJson(Map<String, dynamic> json) {
    return RecordingSession(
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(milliseconds: json['duration'] as int),
      audioFilePath: json['audioFilePath'] as String,
      childId: json['childId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
}

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;

  Future<bool> initialize() async {
    try {
      // Check permissions
      if (await _audioRecorder.hasPermission()) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error initializing audio recorder: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // Get the documents directory for storing recordings
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${recordingsDir.path}/recording_$timestamp.m4a';
      _recordingStartTime = DateTime.now();

      // Start recording
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      print('Started recording at: $_currentRecordingPath');
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  Future<RecordingSession?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null && _recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        final sessionId = _recordingStartTime!.millisecondsSinceEpoch.toString();

        final session = RecordingSession(
          sessionId: sessionId,
          timestamp: _recordingStartTime!,
          duration: duration,
          audioFilePath: path,
          metadata: {
            'device': Platform.operatingSystem,
            'sampleRate': 44100,
            'bitRate': 128000,
            'encoder': 'aacLc',
          },
        );

        _currentRecordingPath = null;
        _recordingStartTime = null;

        print('Recording stopped. Duration: ${duration.inSeconds}s');
        return session;
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }

    return null;
  }

  Future<void> pauseRecording() async {
    if (_isRecording) {
      await _audioRecorder.pause();
    }
  }

  Future<void> resumeRecording() async {
    if (_isRecording) {
      await _audioRecorder.resume();
    }
  }

  Future<List<RecordingSession>> getRecordedSessions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        return [];
      }

      final files = await recordingsDir.list().toList();
      final sessions = <RecordingSession>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.m4a')) {
          final stat = await file.stat();
          final sessionId = file.path.split('/').last.replaceAll('.m4a', '');
          
          sessions.add(RecordingSession(
            sessionId: sessionId,
            timestamp: stat.modified,
            duration: Duration.zero, // Would need to store duration separately
            audioFilePath: file.path,
          ));
        }
      }

      return sessions;
    } catch (e) {
      print('Error getting recorded sessions: $e');
      return [];
    }
  }

  Future<void> deleteRecording(String sessionId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      final file = File('${recordingsDir.path}/recording_$sessionId.m4a');
      
      if (await file.exists()) {
        await file.delete();
        print('Deleted recording: $sessionId');
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await _audioRecorder.stop();
    }
    await _audioRecorder.dispose();
  }
} 