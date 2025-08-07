import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VoiceRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String? _currentRecordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Request microphone permission
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web browsers handle permissions differently
      print('Web platform detected - permissions handled by browser');
      return true;
    }
    
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Generate a unique filename for the recording
  String _generateUniqueId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      10,
      (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      if (kIsWeb) {
        print('Web recording not fully supported yet - use mobile for full functionality');
        return false;
      }

      // Check permission
      if (!await requestPermission()) {
        print('Microphone permission denied');
        return false;
      }

      // Generate unique filename
      final uniqueId = _generateUniqueId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'voice_recording_${timestamp}_$uniqueId.wav';

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _currentRecordingPath = '${appDir.path}/$fileName';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      print('Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _audioRecorder.stop();
      _isRecording = false;

      print('Recording stopped: $path');
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Upload recording to Firebase Storage and store metadata in database
  Future<String?> uploadToCloudStorage(String localFilePath) async {
    try {
      if (kIsWeb) {
        print('Web upload not fully supported yet');
        return null;
      }

      final file = File(localFilePath);
      if (!await file.exists()) {
        print('Recording file not found: $localFilePath');
        return null;
      }

      // Create Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = localFilePath.split('/').last;
      final cloudRef = storageRef.child('voice_recordings/$fileName');

      // Upload file
      final uploadTask = cloudRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Store metadata in Firebase Database
      await _storeRecordingMetadata(fileName, downloadUrl, file.lengthSync());

      print('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading to cloud storage: $e');
      return null;
    }
  }

  /// Store recording metadata in Firebase Database
  Future<void> _storeRecordingMetadata(String fileName, String downloadUrl, int fileSize) async {
    try {
      final recordingData = {
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'fileSize': fileSize,
        'uploadedAt': ServerValue.timestamp,
        'status': 'uploaded',
      };

      // Store in database with database ID "voice" structure
      await _database.ref('voice/recordings').push().set(recordingData);
      print('Recording metadata stored in database');
    } catch (e) {
      print('Error storing recording metadata: $e');
    }
  }

  /// Get all recordings from the voice database
  Future<List<Map<String, dynamic>>> getRecordings() async {
    try {
      final snapshot = await _database.ref('voice/recordings').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final Map<String, dynamic> recording = Map<String, dynamic>.from(entry.value as Map);
          recording['id'] = entry.key;
          return recording;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting recordings: $e');
      return [];
    }
  }

  /// Listen to recordings changes in real-time
  Stream<List<Map<String, dynamic>>> getRecordingsStream() {
    return _database.ref('voice/recordings').onValue.map((event) {
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final Map<String, dynamic> recording = Map<String, dynamic>.from(entry.value as Map);
          recording['id'] = entry.key;
          return recording;
        }).toList();
      }
      return [];
    });
  }

  /// Record and upload in one operation
  Future<String?> recordAndUpload() async {
    try {
      if (kIsWeb) {
        print('Web recording not fully supported - please use mobile device for voice recording');
        return null;
      }

      // Start recording
      final started = await startRecording();
      if (!started) return null;

      // Wait for user to stop recording (you'll need to implement this in UI)
      // For now, we'll return the local path
      return _currentRecordingPath;
    } catch (e) {
      print('Error in record and upload: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _audioRecorder.dispose();
  }
} 