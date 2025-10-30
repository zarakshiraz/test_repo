import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  
  bool _isListening = false;
  bool _isRecording = false;
  String _transcription = '';

  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  String get transcription => _transcription;

  /// Initialize speech recognition
  Future<bool> initializeSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      return await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    try {
      if (!_speech.isAvailable) {
        final initialized = await initializeSpeech();
        if (!initialized) {
          onError?.call('Speech recognition not available');
          return;
        }
      }

      _isListening = true;
      _transcription = '';

      await _speech.listen(
        onResult: (result) {
          _transcription = result.recognizedWords;
          onResult(_transcription);
          
          if (result.finalResult) {
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      _transcription = '';
    }
  }

  /// Start recording audio for voice messages
  Future<void> startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission denied');
        return;
      }

      // Check if we have permission to record
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        _isRecording = true;
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;
        return path;
      }
      return null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancel recording and delete file
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;
        
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
      _isRecording = false;
    }
  }

  /// Get recording duration
  Future<int> getRecordingDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // This is a simplified version - in production use audio metadata
        final size = await file.length();
        // Rough estimate: 1 second ≈ 16KB at 128kbps
        return (size / 16000).round();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting duration: $e');
      return 0;
    }
  }

  /// Clean up resources
  void dispose() {
    _speech.stop();
    _recorder.dispose();
  }
}
