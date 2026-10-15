## [4.0.0] - Unreleased
- **Breaking:** migrated from `package:flutter/material.dart` to the standalone [`material_ui`](https://pub.dev/packages/material_ui) package. Requires Flutter 3.47.0 and Dart 3.13.0 or newer.
- Apps that still use `package:flutter/material.dart` should run `dart fix --apply --code=migrate_design_widgets`, or wrap their tree in `MaterialUiCompatibilityBridge`. Otherwise the default success and error icons use the default `ThemeData` colors instead of the app's.
- `AsyncButtonNotification` now depends only on `package:flutter/widgets.dart`.
- The default `loadingWidget` is now `CircularProgressIndicator.adaptive()`. When `ThemeData.platform` is iOS or macOS it shows a `CupertinoActivityIndicator` instead of the Material spinner. Pass your own `loadingWidget` to keep the old look.
- **Breaking:** `showSuccess` and `showError` now default to `false`. A press goes straight from loading back to idle, so `ButtonSuccess`/`ButtonError` are not emitted (to `builder` or as notifications) and `onSuccess`/`onError` are not called unless you pass `showSuccess: true`/`showError: true`.
- Added `loadingSize` to set the width and height of the default loading indicator (default `16.0`).

## [3.2.0] - Unreleased
- Removed the `equatable` dependency. `ButtonState` subclasses now implement `==` and `hashCode` themselves, so states compare by value (e.g. `ButtonIdle() == ButtonIdle()`, `ButtonError(e, st) == ButtonError(e, st)`). This keeps a parent passing a non-const `buttonState` from resetting a button that is mid-press.
- Fix: a null `onPressed` disables the button again (passes a null `callback` to `builder`). Since 3.1.0 such a button got stuck in the loading state when pressed.
- Updated README and API docs to the current Flutter and Dart APIs: `switch` on `ButtonState` instead of `.when()`/`.maybeWhen()`, `foregroundColor` instead of the removed `primary` in `styleFrom`, `ColorScheme` instead of `accentColor`/`errorColor`.
- Clarified that `onSuccess`/`onError` are called after `successDuration`/`errorDuration`, and not at all when `showSuccess`/`showError` is false.
- `button_state.dart` moved from `lib/src/button_state/` to `lib/src/`. Import `package:async_button_builder/async_button_builder.dart` rather than `src/` paths.
- Tooling: replaced the removed `strong-mode` analyzer options with `strict-casts`, `strict-inference` and `strict-raw-types`, set the formatter page width to 160, and switched CI from `flutter format` to `dart format`.

## [3.1.0] - 2025-02-26
- **Breaking:** `ButtonState` is now a Dart 3 sealed class instead of a `freezed` union. Use `ButtonIdle`, `ButtonLoading`, `ButtonSuccess` and `ButtonError(error, [stackTrace])` with `switch` instead of `ButtonState.idle()`/`.when()`/`.maybeWhen()`.
- Removed the `freezed`, `freezed_annotation` and `build_runner` dependencies; value equality is provided by `equatable`.
- Minimum Dart SDK raised to 3.7.0.

## [3.0.0+1] - 2023-02-13
- Fix `Undefined name 'optionalTypeArgs'.` Also adds back the hard dep on freezed_annotation.

## [3.0.0] - 2023-02-13
- Added notification functionality. The error variant now passes through the error and stacktrace which would be needed for a notification to be useful. This is a breaking change as the error widget now takes an error and stacktrace as arguments.

## [2.3.0+2] - 2023-02-13
- Not pushed

## [2.3.0+1] - 2022-05-24
- Added back freezed_annotation as a hard dep.

## [2.3.0+1] - 2022-05-24
- Fixed onError never being called when an error occurs - Credit @jonjomckay

## [2.3.0] - 2022-05-24
- Removed freezed dependency and added new callbacks @mergehez
- Upgrade to freezed 2 (excluding user now) @quantosapplications @esenmx

## [2.2.0+1] - 2022-01-28
Ignore .vscode, update versions and re-export button state. Credit @esenmx

## [2.2.0] - 2022-01-07
Got rid of hook version as it was complicating a simple package and likely discouraging possible contributors.

## [2.1.4] - 2021-09-28
Fix manual button state changes. Credit to @iliser

## [2.1.3+9] - 2021-09-28
Upgraded deps

## [2.1.3+8] - 2021-09-28
Upgraded deps

## [2.1.3+7] - 2021-09-08
Fixed github actions

## [2.1.3+6] - 2021-08-31
Trying to fix pub stuff

## [2.1.3+5] - 2021-08-27
Trying to fix pub stuff

## [2.1.3+4] - 2021-08-27
Fix home page

## [2.1.3+3] - 2021-08-12
Have proper types exported

## [2.1.3+2] - 2021-08-12
Fix possibility of nested async button builders conflicting with each other due to matching keyed subtrees. In order to avoid this situation, the parent key of the async_button_builder is used in the creation of sub widgets.

## [2.1.3+1] - 2021-06-25
Was not using proper sucessDuration when setting timeouts (regression)

## [2.1.3] - 2021-06-18
Tests and builds against stable. flutter_lints now used in place of pedantic

## [2.1.2+1] - 2021-06-12
Fixes analysis errors so I stop getting annoying emails

## [2.1.2] - 2021-05-24
Errors from onpressed will throw with orignal call stack

## [2.1.1+2] - 2021-04-14
Makes onpressed nullable similar to other button's behaviour

## [2.1.1+1] - 2021-04-14
Add documentation on how to handle timeouts

## [2.1.1] - 2021-04-14
ValueKeys are now no longer required in order to differentiate children

## [2.1.0] - 2021-02-12
Remove null-safety prefix as it's now in stable

## [2.0.9-nullsafety.0] - 2021-02-12
Trying to bump version again to go over stable

## [2.0.8-nullsafety.0] - 2021-02-12
Trying to bump version again to go over stable

## [2.0.7-nullsafety.8] - 2021-02-12
Republish so current nullsafe becomes main. My mistake

## [2.0.2-nullsafety.7] - 2021-02-12
Added a typedef in place of inline type on function. Added doc to `builder` field

## [2.0.2-nullsafety.6] - 2021-02-09
Renamed Union classes to match that of factory constructor name (Should not be breaking).

## [2.0.2-nullsafety.5] - 2021-02-01
Removed example integration test

## [2.0.2-nullsafety.4] - 2021-01-26
Adds tests and test coverage. Adds on dispose to cancel timer.

## [2.0.2-nullsafety.3] - 2021-01-25
Removes dangling controller and cleans up main code up a bit

## [2.0.2-nullsafety.2] - 2021-01-25
Fixes wrong image path

## [2.0.1-nullsafety.2] - 2021-01-25
Renames fields to better match standards of other buttons. 

## [2.0.0-dev.1] - 2021-01-25

Breaking. Replaces the fourth argument with a sealed union that better allows for directly managing states, removes unnecessary arguments such as padding, adds transition builders for custom transitions. Currently still includes AnimatedSize.

## [1.0.0-nullsafety.0] - 2021-01-12

Breaking. Adds a fourth argument of loading to the builder. This removes the value notifier that was difficult or confusing to manage in actual usage in my use cases. The argument isLoading is now a `bool`. This also adds a `disabled` field in order to set that on construction.

## [0.1.0-nullsafety.0] - 2021-01-12

Replaces the bool type of isLoading for a ValueNotifier<bool>.

## [0.0.1-nullsafety.2] - 2021-01-12

Adds analysis options and removes unnecessary typedef

## [0.0.1-nullsafety.1] - 2021-01-12

Adds docs to parameters and removes use of unnecessary undescore internal variables.

## [0.0.1-nullsafety.0] - 2021-01-11

Holds basic builder AsyncButtonBuilder. No tests yet. NNBD is supported
