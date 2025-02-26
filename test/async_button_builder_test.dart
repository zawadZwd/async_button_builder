import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


class TextAsyncButton extends StatelessWidget {
  const TextAsyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AsyncButtonBuilder(
            onPressed: () async {
              await Future<dynamic>.delayed(const Duration(seconds: 1));
            },
            builder: (_, child, callback, _) {
              return TextButton(onPressed: callback, child: child);
            },
            child: const Text('click me'),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('displays child text', (WidgetTester tester) async {
    // final textButton = TextAsyncButton();
    await tester.pumpWidget(TextAsyncButton());

    expect(find.text('click me'), findsOneWidget);
  });

  /*

  testWidgets('shows loading widget', (WidgetTester tester) async {
    const duration = Duration(milliseconds: 250);
    final textButton = MaterialApp(
      home: AsyncButtonBuilder(
        duration: duration,
        loadingWidget: const Text('loading'),
        onPressed: () async {
          await Future<dynamic>.delayed(const Duration(seconds: 1));
        },
        builder: (context, child, callback, state) {
          return TextButton(onPressed: callback, child: child);
        },
        child: const Text('click me'),
      ),
    );

    await tester.pumpWidget(textButton);

    await tester.tap(find.byType(TextButton));

    // 1/10 of a second later, loading should be showing
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('loading'), findsOneWidget);

    // Let the widget continue to settle otherwise I won't dispose timers
    // correctly. TODO: Explain why .900 is the magic number
    await tester.pumpAndSettle(const Duration(milliseconds: 900));
  });

  testWidgets('shows error widget', (WidgetTester tester) async {
    const duration = Duration(milliseconds: 250);
    final textButton = MaterialApp(
      home: AsyncButtonBuilder(
        duration: duration,
        errorWidget: const Text('error'),
        onPressed: () async {
          throw ArgumentError();
        },
        builder: (context, child, callback, state) {
          return TextButton(onPressed: callback, child: child);
        },
        child: const Text('click me'),
      ),
    );

    await tester.pumpWidget(textButton);
    final button = find.byType(TextButton).evaluate().first.widget as TextButton;

    expect(
      () => button.onPressed!.call(),
      throwsA(isA<ArgumentError>()),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('error notification bubbles up', (WidgetTester tester) async {
    const duration = Duration(milliseconds: 250);
    var idleCount = 0;
    var loadingCount = 0;
    var successCount = 0;
    var errorCount = 0;

    final textButton = MaterialApp(
      home: NotificationListener<AsyncButtonNotification>(
        onNotification: (notification) {
          switch (notification.buttonState) {
            case Idle():
              idleCount += 1;
              break;
            case Loading():
              loadingCount += 1;
              break;
            case Success():
              successCount += 1;
              break;
            default:
              errorCount += 1;
              break;
          }

          return true;
        },
        child: AsyncButtonBuilder(
          duration: duration,
          errorDuration: const Duration(milliseconds: 100),
          errorWidget: const Text('error'),
          onPressed: () async {
            throw ArgumentError();
          },
          builder: (context, child, callback, state) {
            return TextButton(onPressed: callback, child: child);
          },
          child: const Text('click me'),
        ),
      ),
    );

    await tester.pumpWidget(textButton);
    final button = find.byType(TextButton).evaluate().first.widget as TextButton;

    expect(
      () => button.onPressed!.call(),
      throwsA(isA<ArgumentError>()),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(errorCount, 1);
    expect(idleCount, 1);
    expect(loadingCount, 1);
    expect(successCount, 0);
  });

  testWidgets('Returns to child widget', (WidgetTester tester) async {
    const duration = Duration(milliseconds: 250);
    final textButton = MaterialApp(
      home: AsyncButtonBuilder(
        duration: duration,
        loadingWidget: const Text('loading'),
        onPressed: () async {
          await Future<dynamic>.delayed(const Duration(seconds: 1));
        },
        builder: (context, child, callback, state) {
          return TextButton(onPressed: callback, child: child);
        },
        child: const Text('click me'),
      ),
    );

    await tester.pumpWidget(textButton);

    await tester.tap(find.byType(TextButton));

    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('loading'), findsNothing);

    expect(find.text('click me'), findsOneWidget);
  });

  */

  // TODO: Make it work on dropdown buttons
  // AsyncButtonBuilder(
  //   child: Icon(Icons.arrow_upward),
  //   onPressed: (newValue) async {
  //     final oldValue = dropdownValue;

  //     setState(() {
  //       dropdownValue = newValue;
  //     });

  //     await Future.delayed(Duration(seconds: 1));

  //     try {
  //       if (Random().nextBool()) {
  //         throw 'yikes';
  //       }
  //     } catch (error) {
  //       setState(() {
  //         dropdownValue = oldValue;
  //       });
  //     }
  //   },
  //   builder: (context, child, callback, _) {
  //     return DropdownButton<String>(
  //       // icon: SizedBox(
  //       //   height: 16.0,
  //       //   width: 16.0,
  //       //   child: CircularProgressIndicator(),
  //       // ),
  //       onChanged: callback,
  //       items: ['one', 'two', 'three']
  //           .map((value) => DropdownMenuItem(
  //                 child: Text(value),
  //                 value: value,
  //               ))
  //           .toList(),
  //       value: dropdownValue,
  //     );
  //   },
  // ),
}
