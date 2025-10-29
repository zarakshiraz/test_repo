import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../widgets/chat_message_bubble.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../utils/haptic_feedback.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: '0',
          text: 'Hi! I\'m your grocery assistant. How can I help you today?',
          isUser: false,
          suggestions: [
            'Breakfast ideas',
            'Healthy snacks',
            'Weekly meal plan',
            'Party supplies',
          ],
        ),
      );
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text.trim(),
          isUser: true,
        ),
      );
      _isTyping = true;
    });

    _textController.clear();
    GrocliHaptics.light();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _generateResponse(text);
    });
  }

  void _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String response;
    List<String>? suggestions;

    if (lowerMessage.contains('breakfast')) {
      response =
          'Great! Here are some breakfast essentials. Tap to add them to your list:';
      suggestions = ['Eggs', 'Bread', 'Milk', 'Orange Juice', 'Cereal'];
    } else if (lowerMessage.contains('healthy') || lowerMessage.contains('snack')) {
      response = 'Here are some healthy snack options:';
      suggestions = ['Greek Yogurt', 'Almonds', 'Carrots', 'Hummus', 'Apples'];
    } else if (lowerMessage.contains('meal') || lowerMessage.contains('weekly')) {
      response = 'For a weekly meal plan, you might need:';
      suggestions = [
        'Chicken Breast',
        'Rice',
        'Vegetables',
        'Pasta',
        'Ground Beef'
      ];
    } else if (lowerMessage.contains('party')) {
      response = 'Planning a party? Here are some essentials:';
      suggestions = ['Chips', 'Soda', 'Paper Plates', 'Napkins', 'Ice'];
    } else {
      response =
          'I can help you with meal planning and suggestions! Try asking about breakfast ideas, healthy snacks, or party supplies.';
      suggestions = null;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isUser: false,
          suggestions: suggestions,
        ),
      );
      _isTyping = false;
    });

    GrocliHaptics.success();
    _scrollToBottom();
  }

  void _addSuggestionToList(String suggestion) {
    GrocliHaptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$suggestion" to your list'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
        ),
      ),
    );
    Navigator.pop(context, suggestion);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GrocliHaptics.light();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: GrocliSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(
                  message: _messages[index],
                  onSuggestionTap: _addSuggestionToList,
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(GrocliSpacing.md),
              child: Row(
                children: [
                  const SizedBox(width: GrocliSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GrocliSpacing.md,
                      vertical: GrocliSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: GrocliColors.surfaceLight,
                      borderRadius:
                          BorderRadius.circular(GrocliSpacing.borderRadiusLg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypingDot(delay: 0),
                        const SizedBox(width: GrocliSpacing.xxs),
                        _TypingDot(delay: 150),
                        const SizedBox(width: GrocliSpacing.xxs),
                        _TypingDot(delay: 300),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(GrocliSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Ask for suggestions...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: GrocliSpacing.md,
                            vertical: GrocliSpacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              GrocliSpacing.borderRadiusRound,
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: GrocliSpacing.sm),
                    Semantics(
                      button: true,
                      label: 'Send message',
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () => _sendMessage(_textController.text),
                        child: const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: GrocliColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
