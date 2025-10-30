import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contacts_providers.dart';

class ImportContactsScreen extends ConsumerStatefulWidget {
  final String userId;

  const ImportContactsScreen({super.key, required this.userId});

  @override
  ConsumerState<ImportContactsScreen> createState() =>
      _ImportContactsScreenState();
}

class _ImportContactsScreenState extends ConsumerState<ImportContactsScreen> {
  bool _isImporting = false;
  String? _errorMessage;
  bool _importComplete = false;

  Future<void> _importContacts() async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(contactsRepositoryProvider);
      
      final hasPermission = await repository.requestContactPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Contacts permission is required';
          _isImporting = false;
        });
        return;
      }

      await repository.importDeviceContacts(widget.userId);

      setState(() {
        _isImporting = false;
        _importComplete = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts imported successfully')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _importComplete ? Icons.check_circle : Icons.contacts,
              size: 80,
              color: _importComplete ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              _importComplete
                  ? 'Import Complete!'
                  : 'Import Device Contacts',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _importComplete
                  ? 'Your contacts have been successfully imported.'
                  : 'This will scan your phone contacts and add any users who are already using the app.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
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
            ],
            const SizedBox(height: 32),
            if (!_importComplete)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isImporting ? null : _importContacts,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isImporting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Import Contacts'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
