import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:rybbit_flutter/src/event_queue.dart';

void main() {
  late EventQueue queue;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rybbit_test_');
    queue = EventQueue();
    await queue.init(hivePath: tempDir.path);
  });

  tearDown(() async {
    await queue.dispose();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  final sampleEvent = <String, dynamic>{
    'type': 'pageview',
    'site_id': 'test-site',
    'pathname': '/home',
  };

  test('enqueue adds events, dequeueAll returns them and clears the box',
      () async {
    await queue.enqueue(sampleEvent, maxSize: 100);
    await queue.enqueue({...sampleEvent, 'pathname': '/about'}, maxSize: 100);

    expect(queue.length, 2);

    final events = await queue.dequeueAll();
    expect(events.length, 2);
    expect(events[0]['pathname'], '/home');
    expect(events[1]['pathname'], '/about');
    expect(queue.length, 0);
  });

  test('dequeueAll on empty queue returns empty list', () async {
    final events = await queue.dequeueAll();
    expect(events, isEmpty);
  });

  test('dequeueAll is idempotent — second call returns empty list', () async {
    await queue.enqueue(sampleEvent, maxSize: 100);

    final first = await queue.dequeueAll();
    expect(first.length, 1);

    final second = await queue.dequeueAll();
    expect(second, isEmpty);
  });

  test('maxQueueSize drops oldest event when queue is full', () async {
    await queue.enqueue({...sampleEvent, 'pathname': '/oldest'}, maxSize: 3);
    await queue.enqueue({...sampleEvent, 'pathname': '/second'}, maxSize: 3);
    await queue.enqueue({...sampleEvent, 'pathname': '/third'}, maxSize: 3);

    // Adding a 4th event should drop the oldest
    await queue.enqueue({...sampleEvent, 'pathname': '/newest'}, maxSize: 3);

    expect(queue.length, 3);
    final events = await queue.dequeueAll();
    final pathnames = events.map((e) => e['pathname']).toList();
    expect(pathnames, containsAll(['/second', '/third', '/newest']));
    expect(pathnames, isNot(contains('/oldest')));
  });

  test('events survive serialisation round-trip with nested properties',
      () async {
    final richEvent = <String, dynamic>{
      'type': 'custom_event',
      'site_id': 'site-1',
      'event_name': 'purchase',
      'properties': jsonEncode({'amount': 9.99, 'currency': 'USD'}),
    };

    await queue.enqueue(richEvent, maxSize: 100);
    final events = await queue.dequeueAll();

    expect(events.length, 1);
    expect(events[0]['event_name'], 'purchase');
    expect(events[0]['properties'], richEvent['properties']);
  });

  test('isEmpty reflects queue state', () async {
    expect(queue.isEmpty, isTrue);
    await queue.enqueue(sampleEvent, maxSize: 100);
    expect(queue.isEmpty, isFalse);
    await queue.dequeueAll();
    expect(queue.isEmpty, isTrue);
  });
}
