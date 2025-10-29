import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _selectedCategory = 'Groceries';
  
  final List<String> _categories = [
    'Groceries',
    'Shopping',
    'Travel',
    'Party',
    'Work',
    'Personal',
    'Other',
  ];

  final List<String> _extractedItems = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // TODO: Implement actual recording
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _extractedItems.addAll([
        'Milk',
        'Bread',
        'Eggs',
        'Butter',
        'Cheese',
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items extracted from audio!')),
    );
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _processTextInput() {
    final text = _itemsController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate AI processing
    Future.delayed(const Duration(seconds: 1), () {
      final items = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      setState(() {
        _isProcessing = false;
        _extractedItems.addAll(items);
        _itemsController.clear();
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _extractedItems.removeAt(index);
    });
  }

  void _addItem(String item) {
    if (item.trim().isNotEmpty && !_extractedItems.contains(item.trim())) {
      setState(() {
        _extractedItems.add(item.trim());
      });
    }
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_extractedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // TODO: Implement list creation
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List created successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New List'),
        actions: [
          TextButton(
            onPressed: _createList,
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
                                    ? 'Recording... Release to stop'
                                    : 'Hold to record your list',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
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
              
              // Extracted Items
              if (_extractedItems.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Items (${_extractedItems.length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _extractedItems.clear();
                                });
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _extractedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Chip(
                              label: Text(item),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeItem(index),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Create Button
                ElevatedButton(
                  onPressed: _createList,
                  child: const Text('Create List'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}