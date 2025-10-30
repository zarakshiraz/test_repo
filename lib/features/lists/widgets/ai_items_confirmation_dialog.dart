import 'package:flutter/material.dart';
import '../../../core/services/ai_transcription_service.dart';

/// Dialog to confirm and edit AI-extracted items before adding to list
class AIItemsConfirmationDialog extends StatefulWidget {
  final List<ExtractedItem> extractedItems;
  final String? originalText;
  final Function(List<ExtractedItem>) onConfirm;

  const AIItemsConfirmationDialog({
    super.key,
    required this.extractedItems,
    this.originalText,
    required this.onConfirm,
  });

  @override
  State<AIItemsConfirmationDialog> createState() => _AIItemsConfirmationDialogState();
}

class _AIItemsConfirmationDialogState extends State<AIItemsConfirmationDialog> {
  late List<_EditableItem> _items;
  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = widget.extractedItems
        .map((item) => _EditableItem(
              content: item.content,
              confidence: item.confidence,
              category: item.category,
              notes: item.notes,
              isSelected: true,
            ))
        .toList();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isSelected = !_items[index].isSelected;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _editItem(int index) {
    final item = _items[index];
    final controller = TextEditingController(text: item.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Item name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _items[index].content = controller.text.trim();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNewItem() {
    if (_newItemController.text.trim().isEmpty) return;
    
    setState(() {
      _items.add(_EditableItem(
        content: _newItemController.text.trim(),
        confidence: 1.0,
        isSelected: true,
      ));
      _newItemController.clear();
    });
  }

  void _confirmSelection() {
    final selectedItems = _items
        .where((item) => item.isSelected)
        .map((item) => ExtractedItem(
              content: item.content,
              confidence: item.confidence,
              category: item.category,
              notes: item.notes,
            ))
        .toList();
    
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
      );
      return;
    }

    widget.onConfirm(selectedItems);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _items.where((item) => item.isSelected).length;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Found ${_items.length} Items',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.originalText != null)
                          Text(
                            'From: "${widget.originalText}"',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Items list
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('No items found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildItemTile(item, index);
                      },
                    ),
            ),
            
            // Add new item
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newItemController,
                      decoration: const InputDecoration(
                        hintText: 'Add another item...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _addNewItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewItem,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$selectedCount item${selectedCount == 1 ? '' : 's'} selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: selectedCount > 0 ? _confirmSelection : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Add to List'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(_EditableItem item, int index) {
    final lowConfidence = item.confidence < 0.7;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: item.isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: item.isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.05)
            : null,
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isSelected,
          onChanged: (_) => _toggleItem(index),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.content,
                style: TextStyle(
                  decoration: item.isSelected
                      ? null
                      : TextDecoration.lineThrough,
                  color: lowConfidence ? Colors.orange[700] : null,
                ),
              ),
            ),
            if (lowConfidence)
              Tooltip(
                message: 'Low confidence (${(item.confidence * 100).toInt()}%)',
                child: Icon(
                  Icons.warning_amber,
                  size: 16,
                  color: Colors.orange[700],
                ),
              ),
          ],
        ),
        subtitle: item.notes != null
            ? Text(
                item.notes!,
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _editItem(index),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              onPressed: () => _removeItem(index),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableItem {
  String content;
  final double confidence;
  final String? category;
  final String? notes;
  bool isSelected;

  _EditableItem({
    required this.content,
    required this.confidence,
    this.category,
    this.notes,
    this.isSelected = true,
  });
}
