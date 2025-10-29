import 'dart:async';
import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/messaging_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final ListModel list;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.list,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final MessagingService _messagingService = MessagingService();
  final ScrollController _scrollController = ScrollController();
  
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messagingService.subscribeToListTopic(widget.list.id);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scrollController.dispose();
    _messagingService.unsubscribeFromListTopic(widget.list.id);
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendTextMessage(String text) async {
    final message = MessageModel(
      id: '',
      listId: widget.list.id,
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      type: MessageType.text,
      textContent: text,
      timestamp: DateTime.now(),
      readBy: {widget.currentUserId: true},
    );

    await _firestoreService.sendMessage(message);
    _scrollToBottom();
  }

  Future<void> _sendVoiceMessage(
    String filePath,
    int duration,
    List<double> waveform,
  ) async {
    try {
      final voiceUrl = await _storageService.uploadVoiceNote(
        filePath,
        widget.list.id,
      );

      final message = MessageModel(
        id: '',
        listId: widget.list.id,
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        type: MessageType.voice,
        voiceUrl: voiceUrl,
        voiceDuration: duration,
        waveformData: waveform,
        timestamp: DateTime.now(),
        readBy: {widget.currentUserId: true},
      );

      await _firestoreService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending voice message: $e')),
        );
      }
    }
  }

  void _onTypingChanged(bool isTyping) {
    _typingTimer?.cancel();

    _firestoreService.setTypingStatus(
      widget.list.id,
      widget.currentUserId,
      isTyping,
    );

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _firestoreService.setTypingStatus(
          widget.list.id,
          widget.currentUserId,
          false,
        );
      });
    }
  }

  void _markMessagesAsRead(List<MessageModel> messages) {
    for (var message in messages) {
      if (message.senderId != widget.currentUserId &&
          !(message.readBy[widget.currentUserId] ?? false)) {
        _firestoreService.markMessageAsRead(
          widget.list.id,
          message.id,
          widget.currentUserId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestoreService.getMessages(widget.list.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isNotEmpty) {
                  _markMessagesAsRead(messages);
                  _scrollToBottom();
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == widget.currentUserId,
                      currentUserId: widget.currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<Map<String, bool>>(
            stream: _firestoreService.getTypingUsers(widget.list.id),
            builder: (context, snapshot) {
              final typingUsers = snapshot.data ?? {};
              final othersTyping = typingUsers.entries
                  .where((entry) =>
                      entry.key != widget.currentUserId && entry.value)
                  .isNotEmpty;

              if (othersTyping) {
                return const TypingIndicator();
              }

              return const SizedBox.shrink();
            },
          ),
          MessageInput(
            onSendText: _sendTextMessage,
            onSendVoice: _sendVoiceMessage,
            onTypingChanged: _onTypingChanged,
          ),
        ],
      ),
    );
  }
}
