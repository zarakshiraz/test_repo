import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/suggestion_provider.dart';
import '../../../../core/services/suggestion_service.dart';

class SuggestionChipBar extends ConsumerWidget {
  final String listId;
  final Function(String) onAccept;
  final VoidCallback? onDismissAll;
  
  const SuggestionChipBar({
    super.key,
    required this.listId,
    required this.onAccept,
    this.onDismissAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionState = ref.watch(suggestionProvider(listId));
    final suggestionNotifier = ref.read(suggestionProvider(listId).notifier);
    
    if (suggestionState.suggestions.isEmpty && !suggestionState.isLoading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggestions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (suggestionState.suggestions.isNotEmpty && onDismissAll != null)
                TextButton(
                  onPressed: () {
                    // Dismiss all suggestions
                    for (final suggestion in suggestionState.suggestions) {
                      suggestionNotifier.dismissSuggestion(
                        listId: listId,
                        suggestion: suggestion,
                      );
                    }
                    onDismissAll?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Dismiss all',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (suggestionState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestionState.suggestions.map((suggestion) {
                return _SuggestionChip(
                  suggestion: suggestion,
                  onAccept: () async {
                    await suggestionNotifier.acceptSuggestion(
                      listId: listId,
                      suggestion: suggestion,
                    );
                    onAccept(suggestion.text);
                  },
                  onDismiss: () async {
                    await suggestionNotifier.dismissSuggestion(
                      listId: listId,
                      suggestion: suggestion,
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;
  
  const _SuggestionChip({
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
  });
  
  IconData _getSourceIcon() {
    switch (suggestion.source) {
      case SuggestionSource.ai:
        return Icons.auto_awesome;
      case SuggestionSource.recentItems:
        return Icons.history;
      case SuggestionSource.template:
        return Icons.category;
      case SuggestionSource.relatedItems:
        return Icons.link;
    }
  }
  
  Color _getSourceColor(BuildContext context) {
    switch (suggestion.source) {
      case SuggestionSource.ai:
        return Colors.purple.shade700;
      case SuggestionSource.recentItems:
        return Colors.blue.shade700;
      case SuggestionSource.template:
        return Colors.green.shade700;
      case SuggestionSource.relatedItems:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getSourceColor(context).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAccept,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSourceIcon(),
                  size: 16,
                  color: _getSourceColor(context),
                ),
                const SizedBox(width: 6),
                Text(
                  suggestion.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
