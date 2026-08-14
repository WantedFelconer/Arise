import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'app/app.dart';
import 'core/database/arise_database.dart';
import 'core/network/token_storage.dart';
import 'core/sync/offline_command_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // Initialize the persistent local database.
  // This is the single Drift SQLite instance for the entire app lifetime.
  // -------------------------------------------------------------------------
  final db = AriseDatabase();

  // -------------------------------------------------------------------------
  // Retrieve or generate a stable device ID.
  // Used for multi-device conflict tracking in the sync engine.
  // -------------------------------------------------------------------------
  const uuidGen = Uuid();
  String deviceId = await db.getAppMeta('device_id') ?? '';
  if (deviceId.isEmpty) {
    deviceId = uuidGen.v4();
    await db.setAppMeta('device_id', deviceId);
  }

  // -------------------------------------------------------------------------
  // Build the persistent command queue with the stable device ID.
  // -------------------------------------------------------------------------
  final commandQueue = PersistentCommandQueue(db, deviceId: deviceId);

  runApp(
    ProviderScope(
      overrides: [
        // Database — single source of truth for all local repositories
        ariseDatabaseProvider.overrideWithValue(db),

        // Command queue — survives app restart
        commandQueueProvider.overrideWithValue(commandQueue),

        // Token storage — secure platform storage (Keychain / EncryptedSharedPrefs)
        tokenStorageProvider.overrideWithValue(SecureTokenStorage()),
      ],
      child: const AriseApp(),
    ),
  );
}
