import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contacts_providers.dart';

class UserSearchItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  final String userId;

  const UserSearchItem({
    super.key,
    required this.user,
    required this.userId,
  });

  @override
  ConsumerState<UserSearchItem> createState() => _UserSearchItemState();
}

class _UserSearchItemState extends ConsumerState<UserSearchItem> {
  bool _isSending = false;

  Future<void> _sendRequest() async {
    setState(() {
      _isSending = true;
    });

    try {
      final repository = ref.read(contactsRepositoryProvider);
      
      await repository.sendContactRequest(
        fromUserId: widget.userId,
        toUserId: widget.user['id'] as String,
        fromUserName: widget.user['displayName'] as String? ?? 'Unknown',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact request sent')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user['displayName'] as String? ?? 'Unknown';
    final email = widget.user['email'] as String?;
    final photoUrl = widget.user['photoUrl'] as String?;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null ? Text(displayName[0].toUpperCase()) : null,
      ),
      title: Text(displayName),
      subtitle: email != null ? Text(email) : null,
      trailing: _isSending
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : ElevatedButton(
              onPressed: _sendRequest,
              child: const Text('Add'),
            ),
    );
  }
}
