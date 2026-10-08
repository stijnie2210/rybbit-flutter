import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:rybbit_flutter/src/identity_store.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rybbit_identity_test_');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('creates an anonymous id on first init', () async {
    final store = IdentityStore();
    await store.init(hivePath: tempDir.path);

    expect(store.anonymousId, matches(uuidV4));
    await store.dispose();
  });

  test('keeps the same anonymous id across restarts', () async {
    final first = IdentityStore();
    await first.init(hivePath: tempDir.path);
    final id = first.anonymousId;
    await first.dispose();

    final second = IdentityStore();
    await second.init(hivePath: tempDir.path);

    expect(second.anonymousId, id);
    await second.dispose();
  });

  test('reset replaces and persists the anonymous id', () async {
    final store = IdentityStore();
    await store.init(hivePath: tempDir.path);
    final oldId = store.anonymousId;

    final newId = await store.reset();
    expect(newId, isNot(oldId));
    expect(store.anonymousId, newId);
    await store.dispose();

    final reopened = IdentityStore();
    await reopened.init(hivePath: tempDir.path);
    expect(reopened.anonymousId, newId);
    await reopened.dispose();
  });

  test('generateAnonymousId returns distinct v4 UUIDs', () {
    final random = Random(42);
    final ids = {for (var i = 0; i < 100; i++) generateAnonymousId(random)};

    expect(ids, hasLength(100));
    expect(ids.every(uuidV4.hasMatch), isTrue);
  });
}
