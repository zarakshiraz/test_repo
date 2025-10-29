import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadVoiceNote(String filePath, String listId) async {
    final file = File(filePath);
    final fileName = '${_uuid.v4()}.m4a';
    final ref = _storage.ref().child('voice_notes/$listId/$fileName');

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> deleteVoiceNote(String voiceUrl) async {
    try {
      final ref = _storage.refFromURL(voiceUrl);
      await ref.delete();
    } catch (e) {
      // Error deleting voice note - fail silently
    }
  }
}
