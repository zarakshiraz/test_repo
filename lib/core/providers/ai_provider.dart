import 'package:flutter/foundation.dart';
import '../services/ai_transcription_service.dart';
import '../services/speech_service.dart';
import '../models/list_item.dart';

enum AIProcessingState {
  idle,
  recording,
  uploading,
  transcribing,
  extracting,
  completed,
  error,
}

class AIProvider extends ChangeNotifier {
  final AITranscriptionService _aiService;
  final SpeechService _speechService;

  AIProcessingState _state = AIProcessingState.idle;
  String? _errorMessage;
  ItemExtractionResponse? _extractionResult;
  String? _currentAudioPath;
  double _progress = 0.0;

  AIProvider({
    AITranscriptionService? aiService,
    SpeechService? speechService,
  })  : _aiService = aiService ?? AITranscriptionService(),
        _speechService = speechService ?? SpeechService();

  // Getters
  AIProcessingState get state => _state;
  String? get errorMessage => _errorMessage;
  ItemExtractionResponse? get extractionResult => _extractionResult;
  double get progress => _progress;
  bool get isRecording => _speechService.isRecording;
  bool get isProcessing => _state != AIProcessingState.idle && 
                          _state != AIProcessingState.completed &&
                          _state != AIProcessingState.error;

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      _setState(AIProcessingState.recording);
      await _speechService.startRecording();
      notifyListeners();
    } catch (e) {
      _setError('Failed to start recording: $e');
    }
  }

  /// Stop recording and process audio
  Future<void> stopRecordingAndProcess() async {
    try {
      if (!_speechService.isRecording) {
        throw Exception('Not currently recording');
      }

      _setState(AIProcessingState.uploading);
      _setProgress(0.1);

      final audioPath = await _speechService.stopRecording();
      if (audioPath == null) {
        throw Exception('Failed to save recording');
      }

      _currentAudioPath = audioPath;
      await _processAudioFile(audioPath);
    } catch (e) {
      _setError('Failed to process recording: $e');
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _speechService.cancelRecording();
      _reset();
    } catch (e) {
      _setError('Failed to cancel recording: $e');
    }
  }

  /// Process existing audio file
  Future<void> processAudioFile(String filePath) async {
    try {
      _setState(AIProcessingState.uploading);
      _currentAudioPath = filePath;
      await _processAudioFile(filePath);
    } catch (e) {
      _setError('Failed to process audio file: $e');
    }
  }

  /// Process text input (no audio)
  Future<void> processTextInput(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text cannot be empty');
      }

      _setState(AIProcessingState.extracting);
      _setProgress(0.5);

      final result = await _aiService.extractItemsFromText(text);
      
      _extractionResult = result;
      _setState(AIProcessingState.completed);
      _setProgress(1.0);
    } catch (e) {
      _setError('Failed to process text: $e');
    }
  }

  /// Internal method to process audio file
  Future<void> _processAudioFile(String filePath) async {
    try {
      // Upload audio
      _setState(AIProcessingState.uploading);
      _setProgress(0.2);
      
      final audioUrl = await _aiService.uploadAudioFile(filePath);
      
      // Transcribe
      _setState(AIProcessingState.transcribing);
      _setProgress(0.5);
      
      final transcription = await _aiService.transcribeAudio(audioUrl);
      
      // Extract items
      _setState(AIProcessingState.extracting);
      _setProgress(0.8);
      
      final extraction = await _aiService.extractItemsFromText(transcription.text);
      
      _extractionResult = ItemExtractionResponse(
        items: extraction.items,
        originalText: transcription.text,
      );
      
      _setState(AIProcessingState.completed);
      _setProgress(1.0);

      // Cleanup: Delete audio file from storage after processing
      // (optional, could keep for history)
      _aiService.deleteAudioFile(audioUrl).catchError((e) {
        debugPrint('Failed to delete audio file: $e');
      });
    } catch (e) {
      _setError('Processing failed: $e');
      rethrow;
    }
  }

  /// Retry the last failed operation
  Future<void> retry() async {
    if (_currentAudioPath != null) {
      await processAudioFile(_currentAudioPath!);
    } else if (_extractionResult?.originalText != null) {
      await processTextInput(_extractionResult!.originalText!);
    } else {
      _setError('Nothing to retry');
    }
  }

  /// Convert extracted items to ListItem models
  List<ListItem> convertToListItems({
    required String listId,
    required String userId,
    int startOrder = 0,
  }) {
    if (_extractionResult == null) {
      return [];
    }

    return _extractionResult!.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return _aiService.extractedItemToListItem(
        extractedItem: item,
        listId: listId,
        userId: userId,
        order: startOrder + index,
      );
    }).toList();
  }

  /// Reset state
  void _reset() {
    _state = AIProcessingState.idle;
    _errorMessage = null;
    _extractionResult = null;
    _currentAudioPath = null;
    _progress = 0.0;
    notifyListeners();
  }

  /// Clear results but keep state
  void clearResults() {
    _extractionResult = null;
    _currentAudioPath = null;
    notifyListeners();
  }

  void _setState(AIProcessingState state) {
    _state = state;
    _errorMessage = null;
    notifyListeners();
  }

  void _setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void _setError(String error) {
    _state = AIProcessingState.error;
    _errorMessage = error;
    _progress = 0.0;
    debugPrint('AIProvider error: $error');
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
