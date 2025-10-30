import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../../core/providers/list_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../models/provisional_item.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemsController = TextEditingController();
  final _uuid = const Uuid();
  final _audioRecorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isSaving = false;
  String _selectedCategory = 'Groceries';
  String? _recordingPath;
  String? _errorMessage;
  
  final List<String> _categories = [
    'Groceries',
    'Shopping',
    'Travel',
    'Party',
    'Work',
    'Personal',
    'Other',
  ];

  final List<ProvisionalItem> _items = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _itemsController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Microphone permission denied';
      });
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Simulate AI processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock extracted items from AI
      final mockItems = ['Milk', 'Bread', 'Eggs', 'Butter', 'Cheese'];
      
      setState(() {
        _isProcessing = false;
        for (final item in mockItems) {
          _items.add(ProvisionalItem(
            id: _uuid.v4(),
            content: item,
            source: ItemSource.aiSuggested,
            order: _items.length,
          ));
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Items extracted from audio!')),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _errorMessage = 'Failed to stop recording: $e';
      });
    }
  }

  void _processTextInput() {
    final text = _itemsController.text.trim();
    if (text.isEmpty) return;

    final itemTexts = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    setState(() {
      for (final itemText in itemTexts) {
        _items.add(ProvisionalItem(
          id: _uuid.v4(),
          content: itemText,
          source: ItemSource.manual,
          order: _items.length,
        ));
      }
      _itemsController.clear();
    });
  }

  void _removeItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
      _reorderItems();
    });
  }

  void _editItem(String id, String newContent) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(content: newContent);
      }
    });
  }

  void _reorderItems() {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(order: i);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _reorderItems();
    });
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final listProvider = ListProvider(userId: authProvider.currentUser!.id);
      final itemContents = _items.map((item) => item.content).toList();

      final list = await listProvider.createList(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        items: itemContents,
      );

      if (list == null) {
        throw Exception(listProvider.errorMessage ?? 'Failed to create list');
      }

      // Save recording path to local storage if available
      if (_recordingPath != null && File(_recordingPath!).existsSync()) {
        // TODO: Upload recording to Firebase Storage
        debugPrint('Recording saved at: $_recordingPath');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('List created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditItemDialog(ProvisionalItem item) {
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
          ElevatedButton(
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                _editItem(item.id, newContent);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New List'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _items.isEmpty ? null : _createList,
              child: const Text('Create'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'List Title',
                  hintText: 'e.g., Weekly Groceries',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Brief description of your list',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Add Items Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Items',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Voice Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isRecording 
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isRecording ? Colors.red : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_isProcessing) ...[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              const Text('Processing audio...'),
                            ] else ...[
                              GestureDetector(
                                onTapDown: (_) => _startRecording(),
                                onTapUp: (_) => _stopRecording(),
                                onTapCancel: () => _stopRecording(),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: _isRecording ? Colors.red : Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isRecording ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isRecording 
                                    ? 'Recording... Tap to stop'
                                    : 'Tap to record your list',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              if (_recordingPath != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Recording saved',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Text Input
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _itemsController,
                              decoration: const InputDecoration(
                                hintText: 'Type items separated by commas',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _processTextInput,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Items List
              if (_items.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Items (${_items.length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _items.clear();
                                });
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Long press and drag to reorder items',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                              key: ValueKey(item.id),
                              leading: Icon(
                                Icons.drag_handle,
                                color: Colors.grey[400],
                              ),
                              title: Text(item.content),
                              subtitle: item.source == ItemSource.aiSuggested
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          size: 14,
                                          color: Colors.blue[300],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'AI suggested',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[300],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditItemDialog(item),
                                    tooltip: 'Edit item',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _removeItem(item.id),
                                    tooltip: 'Remove item',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Create Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _createList,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create List'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}