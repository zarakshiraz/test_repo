import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../utils/haptic_feedback.dart';

class GroceryListItemWidget extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const GroceryListItemWidget({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: GrocliSpacing.md),
        decoration: BoxDecoration(
          color: GrocliColors.error,
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: GrocliSpacing.iconSizeLg,
        ),
      ),
      confirmDismiss: (direction) async {
        await GrocliHaptics.medium();
        return true;
      },
      onDismissed: (direction) {
        GrocliHaptics.success();
        onDelete();
      },
      child: Semantics(
        label: '${item.name}, ${item.quantity} ${item.quantity > 1 ? 'items' : 'item'}, ${item.isCompleted ? 'completed' : 'not completed'}',
        button: true,
        checked: item.isCompleted,
        onTapHint: 'Toggle completion',
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: GrocliSpacing.md,
            vertical: GrocliSpacing.xs,
          ),
          elevation: item.isCompleted ? 0 : GrocliSpacing.elevationLow,
          child: InkWell(
            onTap: () {
              GrocliHaptics.light();
              onTap();
            },
            borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
            child: Padding(
              padding: const EdgeInsets.all(GrocliSpacing.md),
              child: Row(
                children: [
                  Checkbox(
                    value: item.isCompleted,
                    onChanged: (value) {
                      GrocliHaptics.selection();
                      onToggle();
                    },
                  ),
                  const SizedBox(width: GrocliSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.isCompleted
                                    ? GrocliColors.textSecondary
                                    : null,
                              ),
                        ),
                        if (item.category != null) ...[
                          const SizedBox(height: GrocliSpacing.xxs),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: GrocliSpacing.iconSizeSm,
                                color: GrocliColors.textSecondary,
                              ),
                              const SizedBox(width: GrocliSpacing.xxs),
                              Text(
                                item.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: GrocliColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GrocliSpacing.sm,
                      vertical: GrocliSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: item.isCompleted
                          ? GrocliColors.textHint
                          : GrocliColors.primaryGreenLight,
                      borderRadius:
                          BorderRadius.circular(GrocliSpacing.borderRadiusRound),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.isCompleted
                                ? Colors.white
                                : GrocliColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
