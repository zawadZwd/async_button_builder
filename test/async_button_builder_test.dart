import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _duration = Duration(milliseconds: 50);

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

/// TextButton discards the returned Future, so errors from [AsyncCallback]
/// would become unhandled. This helper awaits and swallows them so tests can
/// assert on button state instead.
Widget textAsyncButton({
  required Widget child,
  required AsyncCallback? onPressed,
  Widget? loadingWidget,
  Widget? successWidget,
  Widget? errorWidget,
  bool showSuccess = true,
  bool showError = true,
  bool disabled = false,
  bool notifications = true,
  bool animateSize = false,
  Duration duration = _duration,
  Duration reverseDuration = _duration,
  Duration successDuration = const Duration(milliseconds: 50),
  Duration errorDuration = const Duration(milliseconds: 50),
  VoidCallback? onSuccess,
  VoidCallback? onError,
  ButtonState buttonState = const ButtonIdle(),
  ValueChanged<ButtonState>? onState,
}) {
  return AsyncButtonBuilder(
    animateSize: animateSize,
    duration: duration,
    reverseDuration: reverseDuration,
    successDuration: successDuration,
    errorDuration: errorDuration,
    loadingWidget: loadingWidget,
    successWidget: successWidget,
    errorWidget: errorWidget,
    showSuccess: showSuccess,
    showError: showError,
    disabled: disabled,
    notifications: notifications,
    onSuccess: onSuccess,
    onError: onError,
    buttonState: buttonState,
    onPressed: onPressed,
    builder: (_, buttonChild, callback, state) {
      onState?.call(state);
      return TextButton(
        onPressed: callback == null
            ? null
            : () {
                callback().ignore();
              },
        child: buttonChild,
      );
    },
    child: child,
  );
}

void main() {
  testWidgets('displays child text', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('shows loading widget while onPressed is running', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          loadingWidget: const Text('loading'),
          onPressed: () async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('loading'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });

  testWidgets('shows success widget after successful onPressed', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          successWidget: const Text('success'),
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('success'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('shows error widget when onPressed throws', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          errorWidget: const Text('error'),
          onPressed: () async {
            throw ArgumentError('boom');
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('error'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('returns to child after loading completes', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          loadingWidget: const Text('loading'),
          successDuration: Duration.zero,
          onPressed: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('loading'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('loading'), findsNothing);
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('disables callback while loading', (tester) async {
    ButtonState? lastState;
    var pressCount = 0;

    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onPressed: () async {
            pressCount += 1;
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          onState: (state) => lastState = state,
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(lastState, isA<ButtonLoading>());
    expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);

    await tester.pumpAndSettle();
    expect(pressCount, 1);
  });

  testWidgets('disabled flag nulls the callback', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          disabled: true,
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
  });

  testWidgets('skips success widget when showSuccess is false', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          showSuccess: false,
          successWidget: const Text('success'),
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('success'), findsNothing);
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('skips error widget when showError is false', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          showError: false,
          errorWidget: const Text('error'),
          onPressed: () async {
            throw ArgumentError('boom');
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.text('error'), findsNothing);
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('invokes onSuccess after success duration', (tester) async {
    var onSuccessCalled = false;

    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onSuccess: () => onSuccessCalled = true,
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(onSuccessCalled, isFalse);

    await tester.pumpAndSettle();
    expect(onSuccessCalled, isTrue);
  });

  testWidgets('invokes onError after error duration', (tester) async {
    var onErrorCalled = false;

    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onError: () => onErrorCalled = true,
          onPressed: () async {
            throw ArgumentError('boom');
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(onErrorCalled, isFalse);

    await tester.pumpAndSettle();
    expect(onErrorCalled, isTrue);
  });

  testWidgets('error notification bubbles up', (tester) async {
    var idleCount = 0;
    var loadingCount = 0;
    var successCount = 0;
    var errorCount = 0;

    await tester.pumpWidget(
      wrap(
        NotificationListener<AsyncButtonNotification>(
          onNotification: (notification) {
            switch (notification.buttonState) {
              case ButtonIdle():
                idleCount += 1;
              case ButtonLoading():
                loadingCount += 1;
              case ButtonSuccess():
                successCount += 1;
              case ButtonError():
                errorCount += 1;
            }
            return true;
          },
          child: textAsyncButton(
            errorWidget: const Text('error'),
            onPressed: () async {
              throw ArgumentError('boom');
            },
            child: const Text('click me'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(loadingCount, 1);
    expect(errorCount, 1);
    expect(successCount, 0);

    await tester.pumpAndSettle();
    expect(idleCount, 1);
  });

  testWidgets('success notification bubbles up', (tester) async {
    final states = <ButtonState>[];

    await tester.pumpWidget(
      wrap(
        NotificationListener<AsyncButtonNotification>(
          onNotification: (notification) {
            states.add(notification.buttonState);
            return true;
          },
          child: textAsyncButton(
            onPressed: () async {},
            child: const Text('click me'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(states.whereType<ButtonLoading>(), hasLength(1));
    expect(states.whereType<ButtonSuccess>(), hasLength(1));
    expect(states.whereType<ButtonIdle>(), hasLength(1));
    expect(states.whereType<ButtonError>(), isEmpty);
  });

  testWidgets('does not dispatch notifications when notifications is false', (tester) async {
    var notificationCount = 0;

    await tester.pumpWidget(
      wrap(
        NotificationListener<AsyncButtonNotification>(
          onNotification: (_) {
            notificationCount += 1;
            return true;
          },
          child: textAsyncButton(
            notifications: false,
            successDuration: Duration.zero,
            onPressed: () async {},
            child: const Text('click me'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(notificationCount, 0);
  });

  testWidgets('uses default loading indicator when loadingWidget is null', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onPressed: () async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(_duration);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('respects controlled buttonState from parent', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          buttonState: const ButtonLoading(),
          loadingWidget: const Text('loading'),
          onPressed: () async {},
          child: const Text('click me'),
        ),
      ),
    );

    expect(find.text('loading'), findsOneWidget);
    expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
  });

  testWidgets('null onPressed nulls the callback', (tester) async {
    await tester.pumpWidget(
      wrap(
        textAsyncButton(
          onPressed: null,
          child: const Text('click me'),
        ),
      ),
    );

    expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
    expect(find.text('click me'), findsOneWidget);
  });

  testWidgets('parent rebuild with equal non-const state keeps internal state', (tester) async {
    ButtonState? lastState;
    late StateSetter rebuildParent;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            return textAsyncButton(
              buttonState: ButtonIdle(),
              loadingWidget: const Text('loading'),
              onPressed: () async {
                await Future<void>.delayed(const Duration(milliseconds: 200));
              },
              onState: (state) => lastState = state,
              child: const Text('click me'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(lastState, isA<ButtonLoading>());

    rebuildParent(() {});
    await tester.pump();

    expect(lastState, isA<ButtonLoading>());
    expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);

    await tester.pumpAndSettle();
  });

  testWidgets('changing controlled buttonState updates the button', (tester) async {
    ButtonState controlled = const ButtonIdle();
    late StateSetter rebuildParent;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            return textAsyncButton(
              buttonState: controlled,
              successWidget: const Text('success'),
              onPressed: () async {},
              child: const Text('click me'),
            );
          },
        ),
      ),
    );

    expect(find.text('click me'), findsOneWidget);

    rebuildParent(() => controlled = const ButtonSuccess());
    await tester.pumpAndSettle();

    expect(find.text('success'), findsOneWidget);
    expect(find.text('click me'), findsNothing);
  });

  group('ButtonState equality', () {
    test('non-const instances of the same state are equal', () {
      expect(ButtonIdle(), ButtonIdle());
      expect(ButtonLoading(), ButtonLoading());
      expect(ButtonSuccess(), ButtonSuccess());
      expect(ButtonIdle().hashCode, ButtonIdle().hashCode);
    });

    test('different states are not equal', () {
      expect(ButtonIdle(), isNot(ButtonLoading()));
      expect(ButtonLoading(), isNot(ButtonSuccess()));
      expect(ButtonSuccess(), isNot(ButtonError('x')));
    });

    test('ButtonError compares error and stackTrace', () {
      final error = ArgumentError('boom');
      final stackTrace = StackTrace.current;

      expect(ButtonError(error, stackTrace), ButtonError(error, stackTrace));
      expect(ButtonError(error, stackTrace).hashCode, ButtonError(error, stackTrace).hashCode);
      expect(ButtonError(error), isNot(ButtonError(ArgumentError('other'))));
      expect(ButtonError(error, stackTrace), isNot(ButtonError(error)));
    });
  });
}
