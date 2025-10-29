import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../utils/haptic_feedback.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onSuggestionTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${message.isUser ? 'You' : 'Assistant'} said: ${message.text}',
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: GrocliSpacing.md,
            vertical: GrocliSpacing.xs,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GrocliSpacing.md,
                  vertical: GrocliSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? GrocliColors.primaryGreen
                      : GrocliColors.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(GrocliSpacing.borderRadiusLg),
                    topRight: const Radius.circular(GrocliSpacing.borderRadiusLg),
                    bottomLeft: message.isUser
                        ? const Radius.circular(GrocliSpacing.borderRadiusLg)
                        : const Radius.circular(GrocliSpacing.borderRadiusSm),
                    bottomRight: message.isUser
                        ? const Radius.circular(GrocliSpacing.borderRadiusSm)
                        : const Radius.circular(GrocliSpacing.borderRadiusLg),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: message.isUser
                            ? Colors.white
                            : GrocliColors.textPrimary,
                      ),
                ),
              ),
              if (message.suggestions != null &&
                  message.suggestions!.isNotEmpty) ...[
                const SizedBox(height: GrocliSpacing.xs),
                Wrap(
                  spacing: GrocliSpacing.xs,
                  runSpacing: GrocliSpacing.xs,
                  children: message.suggestions!.map((suggestion) {
                    return Semantics(
                      button: true,
                      label: 'Add suggestion: $suggestion',
                      child: InkWell(
                        onTap: () {
                          GrocliHaptics.light();
                          onSuggestionTap?.call(suggestion);
                        },
                        borderRadius:
                            BorderRadius.circular(GrocliSpacing.borderRadiusRound),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GrocliSpacing.sm,
                            vertical: GrocliSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: GrocliColors.accentBlueLight.withAlpha(51),
                            borderRadius: BorderRadius.circular(
                                GrocliSpacing.borderRadiusRound),
                            border: Border.all(
                              color: GrocliColors.accentBlue,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: GrocliSpacing.iconSizeSm,
                                color: GrocliColors.accentBlue,
                              ),
                              const SizedBox(width: GrocliSpacing.xxs),
                              Text(
                                suggestion,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: GrocliColors.accentBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
