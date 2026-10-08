import 'dart:math';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// Persists the anonymous id that identifies this installation to Rybbit.
///
/// Without it the server falls back to a hash of IP address and user agent,
/// which changes whenever a phone switches between Wi-Fi and cellular. The id
/// is random and contains no device or user information.
class IdentityStore {
  static const _boxName = 'rybbit_identity';
  static const _anonymousIdKey = 'anonymous_id';

  Box? _box;
  String? _anonymousId;

  /// The current anonymous id, or null before [init] has completed.
  String? get anonymousId => _anonymousId;

  /// Opens the underlying Hive box and loads the anonymous id, creating and
  /// storing one on first launch.
  ///
  /// [hivePath] overrides the storage directory; used in tests to avoid the
  /// `path_provider` Flutter plugin dependency.
  Future<void> init({String? hivePath}) async {
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }
    _box = await Hive.openBox(_boxName);

    final stored = _box!.get(_anonymousIdKey);
    if (stored is String && stored.isNotEmpty) {
      _anonymousId = stored;
    } else {
      await reset();
    }
  }

  /// Replaces the anonymous id with a new random one, so later events can't
  /// be linked to earlier ones.
  Future<String> reset() async {
    final id = generateAnonymousId();
    _anonymousId = id;
    await _box?.put(_anonymousIdKey, id);
    return id;
  }

  /// Closes the Hive box and releases resources.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}

/// Generates a random version 4 UUID from a cryptographically secure source.
String generateAnonymousId([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
