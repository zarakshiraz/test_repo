import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _imagePicker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      final controller = ref.read(profileControllerProvider.notifier);
      await controller.uploadProfilePhoto(
        userId: currentUser.id,
        imageFile: File(image.path),
      );

      if (mounted) {
        final state = ref.read(profileControllerProvider);
        state.when(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile photo updated!')),
            );
          },
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload photo: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            controller.resetState();
          },
          loading: () {},
        );
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final nameController = TextEditingController(text: currentUser.displayName);
    final phoneController = TextEditingController(text: currentUser.phoneNumber);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = ref.read(profileControllerProvider.notifier);
              await controller.updateProfile(
                userId: currentUser.id,
                displayName: nameController.text.trim(),
                phoneNumber: phoneController.text.trim().isNotEmpty
                    ? phoneController.text.trim()
                    : null,
              );

              if (mounted) {
                Navigator.pop(context);
                final state = ref.read(profileControllerProvider);
                state.when(
                  data: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated!')),
                    );
                  },
                  error: (error, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: $error'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    controller.resetState();
                  },
                  loading: () {},
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final controller = ref.read(profileControllerProvider.notifier);
      await controller.deleteAccount(currentUser.id);

      if (mounted) {
        final state = ref.read(profileControllerProvider);
        state.when(
          data: (_) {
            context.go(AppRouter.login);
          },
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete account: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            controller.resetState();
          },
          loading: () {},
        );
      }
    }
  }

  Future<void> _updateNotificationSettings({
    bool? notifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final controller = ref.read(profileControllerProvider.notifier);
    await controller.updateNotificationSettings(
      userId: currentUser.id,
      notificationsEnabled: notifications,
      emailNotificationsEnabled: emailNotifications,
      pushNotificationsEnabled: pushNotifications,
    );

    if (mounted) {
      final state = ref.read(profileControllerProvider);
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          controller.resetState();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final controller = ref.read(authControllerProvider.notifier);
              await controller.signOut();
              if (context.mounted) {
                context.go(AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in'));
          }

          final isLoading = profileState.isLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                  onPressed:
                                      isLoading ? null : _pickAndUploadImage,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        if (user.phoneNumber != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Member since ${DateFormat.yMMMd().format(user.createdAt)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _showEditProfileDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('All Notifications'),
                        subtitle: const Text('Enable or disable all notifications'),
                        value: user.notificationsEnabled,
                        onChanged: isLoading
                            ? null
                            : (value) => _updateNotificationSettings(
                                  notifications: value,
                                ),
                      ),
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive notifications via email'),
                        value: user.emailNotificationsEnabled,
                        onChanged: isLoading || !user.notificationsEnabled
                            ? null
                            : (value) => _updateNotificationSettings(
                                  emailNotifications: value,
                                ),
                      ),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Receive push notifications'),
                        value: user.pushNotificationsEnabled,
                        onChanged: isLoading || !user.notificationsEnabled
                            ? null
                            : (value) => _updateNotificationSettings(
                                  pushNotifications: value,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text('Permanently delete your account'),
                        onTap: isLoading ? null : _showDeleteAccountDialog,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
