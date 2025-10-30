import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firestore_providers.dart';

class ParticipantsList extends ConsumerWidget {
  const ParticipantsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider);

    return participantsAsync.when(
      data: (participants) {
        if (participants.isEmpty) {
          return const Center(
            child: Text('No participants yet'),
          );
        }

        return ListView.builder(
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    child: Text(participant.name[0].toUpperCase()),
                  ),
                  if (participant.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(participant.name),
              subtitle: Text(
                participant.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: participant.isOnline ? Colors.green : Colors.grey,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading participants: $error'),
      ),
    );
  }
}
