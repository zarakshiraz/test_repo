import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'local_storage_service.dart';
import 'firestore_service.dart';
import '../models/sync_status.dart';
import '../models/activity_log.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';

class SyncService {
  final LocalStorageService _localStorage;
  final FirestoreService _firestore;
  final Connectivity _connectivity = Connectivity();
  final _uuid = const Uuid();

  bool _isSyncing = false;
  bool _isOnline = true;
  final _syncStatusController = StreamController<bool>.broadcast();
  final _conflictController = StreamController<String>.broadcast();

  Stream<bool> get syncStatusStream => _syncStatusController.stream;
  Stream<String> get conflictStream => _conflictController.stream;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  SyncService(this._localStorage, this._firestore) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) async {
      final wasOffline = !_isOnline;
      _isOnline = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (_isOnline && wasOffline) {
        await syncPendingChanges();
      }
    });

    _connectivity.checkConnectivity().then((result) {
      _isOnline = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    });
  }

  Future<void> syncPendingChanges() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      await _syncTodoLists();
      await _syncTodoItems();
      await _syncMessages();
    } catch (e) {
      // Sync error, will retry on next connectivity change
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _syncTodoLists() async {
    final pendingLists = _localStorage.getPendingTodoLists();

    for (final localList in pendingLists) {
      try {
        final remoteList = await _firestore.getTodoList(localList.id);

        if (remoteList == null) {
          await _firestore.saveTodoList(localList);
          localList.syncStatus = SyncStatus.synced;
          await localList.save();
          
          await _logActivity(
            entityType: 'TodoList',
            entityId: localList.id,
            action: 'created',
          );
        } else {
          final conflict = await _resolveConflict(
            localList.updatedAt,
            remoteList.updatedAt,
            localList.id,
            'TodoList',
          );

          if (conflict) {
            localList.syncStatus = SyncStatus.conflict;
            await localList.save();
            _conflictController.add(
                'Conflict detected for list "${localList.name}". Using latest version.');
          } else {
            await _firestore.saveTodoList(localList);
            localList.syncStatus = SyncStatus.synced;
            await localList.save();
            
            await _logActivity(
              entityType: 'TodoList',
              entityId: localList.id,
              action: 'updated',
            );
          }
        }
      } catch (e) {
        // Error syncing TodoList, will retry later
      }
    }
  }

  Future<void> _syncTodoItems() async {
    final pendingItems = _localStorage.getPendingTodoItems();

    for (final localItem in pendingItems) {
      try {
        final remoteItem = await _firestore.getTodoItem(localItem.id);

        if (remoteItem == null) {
          await _firestore.saveTodoItem(localItem);
          localItem.syncStatus = SyncStatus.synced;
          await localItem.save();
          
          await _logActivity(
            entityType: 'TodoItem',
            entityId: localItem.id,
            action: 'created',
          );
        } else {
          final conflict = await _resolveConflict(
            localItem.updatedAt,
            remoteItem.updatedAt,
            localItem.id,
            'TodoItem',
          );

          if (conflict) {
            localItem.syncStatus = SyncStatus.conflict;
            await localItem.save();
            _conflictController.add(
                'Conflict detected for item "${localItem.title}". Using latest version.');
          } else {
            await _firestore.saveTodoItem(localItem);
            localItem.syncStatus = SyncStatus.synced;
            await localItem.save();
            
            await _logActivity(
              entityType: 'TodoItem',
              entityId: localItem.id,
              action: 'updated',
            );
          }
        }
      } catch (e) {
        // Error syncing TodoItem, will retry later
      }
    }
  }

  Future<void> _syncMessages() async {
    final pendingMessages = _localStorage.getPendingMessages();

    for (final localMessage in pendingMessages) {
      try {
        final remoteMessage = await _firestore.getMessage(localMessage.id);

        if (remoteMessage == null) {
          await _firestore.saveMessage(localMessage);
          localMessage.syncStatus = SyncStatus.synced;
          await localMessage.save();
          
          await _logActivity(
            entityType: 'Message',
            entityId: localMessage.id,
            action: 'created',
          );
        } else {
          final conflict = await _resolveConflict(
            localMessage.updatedAt,
            remoteMessage.updatedAt,
            localMessage.id,
            'Message',
          );

          if (conflict) {
            localMessage.syncStatus = SyncStatus.conflict;
            await localMessage.save();
            _conflictController.add(
                'Conflict detected for message. Using latest version.');
          } else {
            await _firestore.saveMessage(localMessage);
            localMessage.syncStatus = SyncStatus.synced;
            await localMessage.save();
            
            await _logActivity(
              entityType: 'Message',
              entityId: localMessage.id,
              action: 'updated',
            );
          }
        }
      } catch (e) {
        // Error syncing Message, will retry later
      }
    }
  }

  Future<bool> _resolveConflict(
    DateTime localUpdatedAt,
    DateTime remoteUpdatedAt,
    String entityId,
    String entityType,
  ) async {
    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      await _logActivity(
        entityType: entityType,
        entityId: entityId,
        action: 'conflict_resolved',
        conflictDetails:
            'Remote version (${remoteUpdatedAt.toIso8601String()}) is newer than local (${localUpdatedAt.toIso8601String()}). Using remote version.',
      );
      return true;
    }
    return false;
  }

  Future<void> _logActivity({
    required String entityType,
    required String entityId,
    required String action,
    String? conflictDetails,
  }) async {
    final log = ActivityLog(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      action: action,
      conflictDetails: conflictDetails,
      timestamp: DateTime.now(),
    );

    await _localStorage.saveActivityLog(log);
    
    if (_isOnline) {
      try {
        await _firestore.saveActivityLog(log);
      } catch (e) {
        // Error saving activity log to Firestore
      }
    }
  }

  Future<void> pullRemoteChanges() async {
    if (!_isOnline) return;

    try {
      final remoteLists = await _firestore.todoListsCollection
          .where('isDeleted', isEqualTo: false)
          .get();

      for (final doc in remoteLists.docs) {
        final remoteList =
            TodoList.fromFirestore(doc.data() as Map<String, dynamic>);
        final localList = _localStorage.getTodoList(remoteList.id);

        if (localList == null) {
          await _localStorage.saveTodoList(remoteList);
        } else if (remoteList.updatedAt.isAfter(localList.updatedAt) &&
            localList.syncStatus == SyncStatus.synced) {
          await _localStorage.saveTodoList(remoteList);
        }
      }

      final remoteItems = await _firestore.todoItemsCollection
          .where('isDeleted', isEqualTo: false)
          .get();

      for (final doc in remoteItems.docs) {
        final remoteItem =
            TodoItem.fromFirestore(doc.data() as Map<String, dynamic>);
        final localItem = _localStorage.getTodoItem(remoteItem.id);

        if (localItem == null) {
          await _localStorage.saveTodoItem(remoteItem);
        } else if (remoteItem.updatedAt.isAfter(localItem.updatedAt) &&
            localItem.syncStatus == SyncStatus.synced) {
          await _localStorage.saveTodoItem(remoteItem);
        }
      }
    } catch (e) {
      // Error pulling remote changes
    }
  }

  void dispose() {
    _syncStatusController.close();
    _conflictController.close();
  }
}
