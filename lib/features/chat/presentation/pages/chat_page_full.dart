import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/message_provider.dart';
import '../../../../core/models/message.dart';
import '../../../../core/services/speech_service.dart';

class ChatPageFull extends StatefulWidget {
  final String listId;

  const ChatPageFull({
    super.key,
    required this.listId,
  });

  @override
  State<ChatPageFull> createState() => _ChatPageFullState();
}

class _ChatPageFullState extends State<ChatPageFull> {
  final _messageController = TextEditingController();
  final _speechService = SpeechService();
  final _scrollController = ScrollController();
  bool _isRecording = false;

  @override
  void dispose() {
    _messageController.dispose();
    _speechService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendTextMessage(BuildContext context) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final messageProvider = context.read<MessageProvider>();
    await messageProvider.sendTextMessage(
      listId: widget.listId,
      content: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _startVoiceRecording() async {
    setState(() {
      _isRecording = true;
    });
    await _speechService.startRecording();
  }

  Future<void> _stopVoiceRecording(BuildContext context) async {
    final path = await _speechService.stopRecording();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) return;

      final duration = await _speechService.getRecordingDuration(path);
      final messageProvider = context.read<MessageProvider>();
      
      // In production, upload to Firebase Storage and get URL
      await messageProvider.sendVoiceMessage(
        listId: widget.listId,
        voiceUrl: path,
        voiceDuration: duration,
      );

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return ChangeNotifierProvider(
      create: (_) => MessageProvider(userId: authProvider.currentUser!.id)
        ..loadMessages(widget.listId),
      child: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          final messages = messageProvider.getMessagesForList(widget.listId);

          return Scaffold(
            appBar: AppBar(
              title: const Text('List Chat'),
            ),
            body: Column(
              children: [
                // Messages List
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text('Start a conversation about this list'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isOwnMessage =
                                message.senderId == authProvider.currentUser!.id;

                            return _MessageBubble(
                              message: message,
                              isOwnMessage: isOwnMessage,
                            );
                          },
                        ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Voice Button
                        GestureDetector(
                          onLongPressStart: (_) => _startVoiceRecording(),
                          onLongPressEnd: (_) => _stopVoiceRecording(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Text Input
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _isRecording
                                  ? 'Recording...'
                                  : 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendTextMessage(context),
                            enabled: !_isRecording,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Send Button
                        IconButton(
                          onPressed: () => _sendTextMessage(context),
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;

  const _MessageBubble({
    required this.message,
    required this.isOwnMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isOwnMessage
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isOwnMessage
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.voice) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: isOwnMessage ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${message.voiceDuration ?? 0}s',
                          style: TextStyle(
                            color: isOwnMessage ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isOwnMessage ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
