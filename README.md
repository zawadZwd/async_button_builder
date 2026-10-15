# async_button_builder

AsyncButtonBuilder offers a simple way to extend any type of button with an asynchronous aspect. It allows adding loading, disabled, errored and completed states (with fluid animation between each) on top of buttons that perform asynchronous tasks.

## Getting Started

Include the package. It requires Flutter 3.47 or newer and builds on [`material_ui`](https://pub.dev/packages/material_ui), so add that as well:

```yaml
  async_button_builder: <latest_version>
  material_ui: ^1.7.0
```

The examples below assume these imports:

```dart
import 'package:async_button_builder/async_button_builder.dart';
import 'package:material_ui/material_ui.dart';
```

If your app still imports `package:flutter/material.dart`, run `dart fix --apply --code=migrate_design_widgets` to move it to `material_ui`. Until you do, wrap the app in `MaterialUiCompatibilityBridge` (for example from `MaterialApp.builder`). Without the bridge, the default success and error icons can't see your theme and use the default colors.

Wrap the builder around a button, passing the onPressed and child element to builder instead of the button directly. These two are the only required fields.

```dart
AsyncButtonBuilder(
  onPressed: () async {
    await Future<void>.delayed(const Duration(seconds: 1));
  },
  builder: (context, child, callback, _) {
    return TextButton(
      onPressed: callback,
      child: child,
    );
  },
  child: const Text('Click Me'),
),
```

If `onPressed` is null, `callback` is null as well, so the button renders as disabled.

<p>  
 <img src="https://github.com/Nolence/async_button_builder/blob/main/screenshots/ezgif-7-61c436edaec2.gif?raw=true"/>
</p>

The fourth value in the builder is the current `ButtonState`, which can be used to conditionally style the button. `ButtonState` is a Dart 3 sealed class with four subclasses — `ButtonIdle`, `ButtonLoading`, `ButtonSuccess` and `ButtonError` — so it can be matched exhaustively with `switch`.

By default a press goes from `ButtonLoading` straight back to `ButtonIdle`. Pass `showSuccess: true` and/or `showError: true` to show the success or error state (and get `onSuccess`/`onError` and the matching notifications).

> NOTE (Breaking change): As of v3.1.0, `ButtonState` is no longer a `freezed` union. Replace `.when(...)` / `.maybeWhen(...)` with a `switch` expression over `ButtonIdle()`, `ButtonLoading()`, `ButtonSuccess()` and `ButtonError()`.

```dart
AsyncButtonBuilder(
  showError: true,
  loadingWidget: const Text('Loading...'),
  onPressed: () async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // See the example app for a way to handle timeouts
    throw StateError('yikes');
  },
  builder: (context, child, callback, buttonState) {
    final buttonColor = switch (buttonState) {
      ButtonIdle() => Colors.yellow[200],
      ButtonLoading() => Colors.grey,
      ButtonSuccess() => Colors.orangeAccent,
      ButtonError() => Colors.orange,
    };

    return OutlinedButton(
      onPressed: callback,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: buttonColor,
      ),
      child: child,
    );
  },
  child: const Text('Click Me'),
),
```

<p>  
 <img src="https://github.com/Nolence/async_button_builder/blob/main/screenshots/ezgif-7-a971c6afaabf.gif?raw=true"/>
</p>

You can also drive the state of the button yourself using the  `buttonState` field:

```dart
AsyncButtonBuilder(
  buttonState: const ButtonSuccess(),
  // ...
),
```

## Notifications

Since v3.0.0, you can wrap a higher level parent to handle notifications that come from buttons. Why not use something like `runZonedGuarded`? Notification bubbling handles not only the error but the state of the button. If you'd like, for example, to trigger a circular spinner in the center of the app notifiying the user that something is happening, you can do so by listening to the `AsyncButtonNotification` and then using the `buttonState` to determine what to do.

It might also be a good idea to separate the errors that come from button presses and those that are not. An error wants to see why a button press silently failed but might not need to know why a background fetch failed.

```dart
MaterialApp(
  home: NotificationListener<AsyncButtonNotification>(
    onNotification: (notification) {
      switch (notification.buttonState) {
        case ButtonIdle():
          break; // nothing to do
        case ButtonLoading():
          break; // show circular loading widget?
        case ButtonSuccess():
          break; // show success snackbar?
        case ButtonError():
          break; // show error snackbar?
      }

      // Tells the notification to stop bubbling
      return true;
    },
    // This async button can be nested arbitrarily deep*
    child: AsyncButtonBuilder(
      duration: duration,
      errorDuration: const Duration(milliseconds: 100),
      showError: true,
      errorWidget: const Text('error'),
      onPressed: () async {
        throw ArgumentError('boom');
      },
      builder: (context, child, callback, state) {
        return TextButton(onPressed: callback, child: child);
      },
      child: const Text('click me'),
    ),
  ),
)

// See NotificationListener for more information
```

To disable the notifications, you can pass `false` to `notifications`.

## Customization

The default loading widget is `CircularProgressIndicator.adaptive()`, which shows a `CupertinoActivityIndicator` on iOS and macOS and a Material spinner elsewhere. The default success and error icons are Material `Icons` on every platform. For a fully iOS-styled button, pass your own widgets. This example needs the `cupertino_ui` package, and `CupertinoIcons` also needs `cupertino_icons`:

```dart
import 'package:cupertino_ui/cupertino_ui.dart';

AsyncButtonBuilder(
  onPressed: () async {
    await Future<void>.delayed(const Duration(seconds: 1));
  },
  loadingWidget: const CupertinoActivityIndicator(),
  showSuccess: true,
  showError: true,
  successWidget: const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeGreen),
  errorWidget: const Icon(CupertinoIcons.exclamationmark_circle, color: CupertinoColors.systemRed),
  builder: (context, child, callback, _) {
    return CupertinoButton(
      onPressed: callback,
      child: child,
    );
  },
  child: const Text('Click Me'),
),
```

`async_button_builder` even works for custom buttons. You can define your own widgets for loading, error, and completion as well as define the transitions between them. This example is a little verbose but shows some of what's possible.


```dart
AsyncButtonBuilder(
  loadingWidget: const Padding(
    padding: EdgeInsets.all(8.0),
    child: SizedBox(
      height: 16.0,
      width: 16.0,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  ),
  showSuccess: true,
  successWidget: const Padding(
    padding: EdgeInsets.all(4.0),
    child: Icon(
      Icons.check,
      color: Colors.purpleAccent,
    ),
  ),
  onPressed: () async {
    await Future<void>.delayed(const Duration(seconds: 2));
  },
  loadingSwitchInCurve: Curves.bounceInOut,
  loadingTransitionBuilder: (child, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  },
  builder: (context, child, callback, state) {
    return Material(
      color: switch (state) {
        ButtonSuccess() => Colors.purple[100],
        _ => Colors.blue,
      },
      // This prevents the loading indicator showing below the
      // button
      clipBehavior: Clip.hardEdge,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: callback,
        child: child,
      ),
    );
  },
  child: const Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    child: Text(
      'Click Me',
      style: TextStyle(color: Colors.white),
    ),
  ),
),
```

<p>  
 <img src="https://github.com/Nolence/async_button_builder/blob/main/screenshots/ezgif-7-4088c909ba83.gif?raw=true"/>
</p>

Issues and PR's welcome