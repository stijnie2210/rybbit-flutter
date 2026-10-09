import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/src/route_observer.dart';

void main() {
  late List<String> screens;
  late bool enabled;
  late GlobalKey<NavigatorState> navigatorKey;

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [
          RybbitRouteObserver(
            isEnabled: () => enabled,
            onScreenView: screens.add,
          ),
        ],
        home: const SizedBox(),
      ),
    );
  }

  Route<void> page(String? name) => MaterialPageRoute<void>(
    settings: RouteSettings(name: name),
    builder: (_) => const SizedBox(),
  );

  setUp(() {
    screens = [];
    enabled = true;
    navigatorKey = GlobalKey<NavigatorState>();
  });

  testWidgets('tracks pushed and revealed pages', (tester) async {
    await pumpApp(tester);
    screens.clear();

    navigatorKey.currentState!.push(page('/products'));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push(page('/products/detail'));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(screens, ['/products', '/products/detail', '/products']);
  });

  testWidgets('tracks replaced pages', (tester) async {
    await pumpApp(tester);
    navigatorKey.currentState!.push(page('/a'));
    await tester.pumpAndSettle();
    screens.clear();

    navigatorKey.currentState!.pushReplacement(page('/b'));
    await tester.pumpAndSettle();

    expect(screens, ['/b']);
  });

  testWidgets('ignores opening and closing dialogs and bottom sheets', (
    tester,
  ) async {
    await pumpApp(tester);
    navigatorKey.currentState!.push(page('/products'));
    await tester.pumpAndSettle();
    screens.clear();

    final context = navigatorKey.currentContext!;
    showDialog<void>(context: context, builder: (_) => const SizedBox());
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const SizedBox(height: 100),
    );
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(screens, isEmpty);
  });

  testWidgets('skips routes without a name', (tester) async {
    await pumpApp(tester);
    screens.clear();

    navigatorKey.currentState!.push(page(null));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push(page(''));
    await tester.pumpAndSettle();

    expect(screens, isEmpty);
  });

  testWidgets('tracks nothing while disabled', (tester) async {
    enabled = false;
    await pumpApp(tester);

    navigatorKey.currentState!.push(page('/products'));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(screens, isEmpty);
  });

  testWidgets('SDK observer is safe to use before initialize', (tester) async {
    final rybbit = RybbitFlutter.instance;
    expect(rybbit.isInitialized, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [rybbit.routeObserver],
        home: const SizedBox(),
      ),
    );
    navigatorKey.currentState!.push(page('/products'));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
