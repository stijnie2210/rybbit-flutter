import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// Persistent queue that stores analytics events while the device is offline.
///
/// Events are serialised to JSON and stored in a Hive box so they survive app
/// restarts. Call [init] once before use and [dispose] when done.
class EventQueue {
  static const _boxName = 'rybbit_event_queue';
  Box? _box;

  /// Opens the underlying Hive box. Safe to call multiple times.
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
  }

  /// Adds [eventJson] to the tail of the queue.
  ///
  /// If the queue already holds [maxSize] events the oldest event is dropped
  /// to make room, keeping total storage bounded.
  Future<void> enqueue(
    Map<String, dynamic> eventJson, {
    required int maxSize,
  }) async {
    final box = _box;
    if (box == null) return;

    while (box.length >= maxSize) {
      await box.deleteAt(0);
    }

    await box.add(jsonEncode(eventJson));
  }

  /// Removes and returns all queued events atomically.
  ///
  /// Returns an empty list when the queue is empty.
  Future<List<Map<String, dynamic>>> dequeueAll() async {
    final box = _box;
    if (box == null || box.isEmpty) return [];

    final events = box.values
        .whereType<String>()
        .map((v) => Map<String, dynamic>.from(jsonDecode(v) as Map))
        .toList();

    await box.clear();
    return events;
  }

  /// Number of events currently in the queue.
  int get length => _box?.length ?? 0;

  /// Whether the queue holds no events.
  bool get isEmpty => length == 0;

  /// Closes the Hive box and releases resources.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
