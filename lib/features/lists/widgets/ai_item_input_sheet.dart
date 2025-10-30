import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/services/ai_transcription_service.dart';

/// Bottom sheet for AI-powered item input
/// Supports both voice recording and text input
class AIItemInputSheet extends StatefulWidget {
  final Function(List<ExtractedItem>) onItemsExtracted;
  final String? initialText;

  const AIItemInputSheet({
    super.key,
    required this.onItemsExtracted,
    this.initialText,
  });

  @override
  State<AIItemInputSheet> createState() => _AIItemInputSheetState();
}

class _AIItemInputSheetState extends State<AIItemInputSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isTextMode = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isTextMode = !_isTextMode;
    });
  }

  Future<void> _processText(BuildContext context) async {
    final provider = context.read<AIProvider>();
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    await provider.processTextInput(text);
    
    if (!context.mounted) return;
    
    if (provider.state == AIProcessingState.completed &&
        provider.extractionResult != null) {
      widget.onItemsExtracted(provider.extractionResult!.items);
      Navigator.of(context).pop();
    }
  }

  Future<void> _startRecording(BuildContext context) async {
    final provider = context.read<AIProvider>();
    await provider.startRecording();
  }

  Future<void> _stopRecording(BuildContext context) async {
    final provider = context.read<AIProvider>();
    await provider.stopRecordingAndProcess();
    
    if (!context.mounted) return;
    
    if (provider.state == AIProcessingState.completed &&
        provider.extractionResult != null) {
      widget.onItemsExtracted(provider.extractionResult!.items);
      Navigator.of(context).pop();
    }
  }

  Future<void> _cancelRecording(BuildContext context) async {
    final provider = context.read<AIProvider>();
    await provider.cancelRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Items with AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isTextMode ? Icons.mic : Icons.text_fields),
                        onPressed: provider.isProcessing ? null : _toggleMode,
                        tooltip: _isTextMode ? 'Switch to voice' : 'Switch to text',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Content
                if (provider.isProcessing)
                  _buildProcessingView(context, provider)
                else if (provider.state == AIProcessingState.error)
                  _buildErrorView(context, provider)
                else if (_isTextMode)
                  _buildTextInputView(context, provider)
                else
                  _buildVoiceInputView(context, provider),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInputView(BuildContext context, AIProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter or paste your list here...\n\nExample:\n- Milk, eggs, and bread\n- 2 apples\n- Tomato sauce',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _processText(context),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Extract Items with AI'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputView(BuildContext context, AIProvider provider) {
    final isRecording = provider.isRecording;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            isRecording ? Icons.mic : Icons.mic_none,
            size: 80,
            color: isRecording ? Colors.red : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isRecording
                ? 'Recording... Speak naturally'
                : 'Tap to start recording',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? 'Example: "I need milk, eggs, and bread"'
                : 'Just speak your list items naturally',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (isRecording)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _cancelRecording(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _stopRecording(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: () => _startRecording(context),
              icon: const Icon(Icons.mic),
              label: const Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(BuildContext context, AIProvider provider) {
    final stateMessages = {
      AIProcessingState.uploading: 'Uploading audio...',
      AIProcessingState.transcribing: 'Transcribing speech...',
      AIProcessingState.extracting: 'Extracting items...',
    };

    final message = stateMessages[provider.state] ?? 'Processing...';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: provider.progress),
          const SizedBox(height: 8),
          Text(
            '${(provider.progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, AIProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  provider.clearResults();
                  setState(() {
                    _isTextMode = true;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => provider.retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
