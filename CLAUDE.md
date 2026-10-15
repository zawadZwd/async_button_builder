# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`async_button_builder` is a Flutter package (not an app) that wraps any button widget with async-aware idle/loading/success/error states, animated transitions between them, and optional notification bubbling. The package has no backend, no app entry point of its own — `example/` is a demo app that consumes the published API like a real user would.

Material widgets come from the standalone `material_ui` package (`package:material_ui/material_ui.dart`), not `package:flutter/material.dart`. Do not reintroduce `flutter/material.dart` imports: its `ThemeData` is a different type, so mixing the two breaks theme lookup. Minimum is Flutter 3.47 / Dart 3.13; CI pins the same Flutter version.

## Commands

Run all commands from the repo root unless noted.

```bash
flutter pub get                              # install deps
flutter analyze                              # static analysis (uses analysis_options.yaml)
dart format --output=none --set-exit-if-changed lib test  # CI's formatting check (page width 160, set in analysis_options.yaml)
flutter test                                 # run all tests
flutter test test/async_button_builder_test.dart                  # run the single test file
flutter test test/async_button_builder_test.dart --plain-name "some test name"  # run one test by name
```

CI (`.github/workflows/dart.yaml`) runs, in order: `flutter pub get` → format check → `flutter analyze` → `flutter analyze` in `example/` → `flutter test`. Match this locally before considering work done.

The `example/` app has its own `pubspec.yaml`/deps; run `flutter pub get` inside `example/` if working on it.

## Architecture

The package is intentionally small — three files under `lib/src/`, all re-exported from `lib/async_button_builder.dart`:

- **`button_state.dart`** — `ButtonState` is a sealed class with four variants: `ButtonIdle`, `ButtonLoading`, `ButtonSuccess`, `ButtonError(error, [stackTrace])`. Consumers pattern-match with Dart's `switch` (no `freezed`/`equatable` dependency — both were tried and removed). Each subclass implements `==`/`hashCode` by hand; this value equality is load-bearing, because `didUpdateWidget` compares old and new `buttonState` and identity comparison would reset an in-flight button whenever a parent rebuilds with a non-const state.
- **`async_button_builder.dart`** — `AsyncButtonBuilder` (StatefulWidget) is the core. It does **not** render a button itself; it calls `widget.builder(context, child, callback, buttonState)` and the caller supplies the actual button (`TextButton`, `IconButton`, custom widget, etc.). Key internal flow:
  - `_handlePressed` drives the state machine: emits `ButtonLoading`, awaits `widget.onPressed()`, then emits `ButtonSuccess`/`ButtonError` via `_showOutcome`, which auto-resets to `ButtonIdle` after `successDuration`/`errorDuration` using an internal `Timer` (`_resetAfter`).
  - `_phase()` maps the current `ButtonState` to the curve/transition/child to feed an `AnimatedSwitcher`, optionally wrapped in `AnimatedSize` (`widget.animateSize`). Per-state switch-in/switch-out curves and transition builders are all separately overridable (`idle*`, `loading*`, `success*`, `error*` fields).
  - The widget can be driven externally via `widget.buttonState` (bypassing the internal async flow) — `didUpdateWidget` syncs internal state when the external value changes.
  - Nested `AsyncButtonBuilder`s need distinct `ValueKey`s; `_keyed`/`_parentKeyValue` namespace the internal `__idle__`/`__loading__`/etc. subtree keys per parent key to avoid `GlobalKey` collisions.
  - `_emit` dispatches `AsyncButtonNotification` up the widget tree (unless `notifications: false`) so a `NotificationListener<AsyncButtonNotification>` ancestor can react to any descendant button's state — including nested buttons.
- **`async_button_notification.dart`** — thin `Notification` subclass carrying the `ButtonState`.

When changing state-transition logic, check both the widget test file (`test/async_button_builder_test.dart`, which drives buttons via a `TextButton` test harness and asserts on `ButtonState` via an `onState` callback) and the README's inline examples, since the README's code samples are the primary user-facing documentation and should stay runnable against the current API.

## Linting

`analysis_options.yaml` enables several stricter-than-default lints beyond `flutter_lints`: `strict-casts`/`strict-inference`/`strict-raw-types`, `require_trailing_commas`, `always_use_package_imports`, `always_declare_return_types`, `avoid_void_async`, among others. Follow these in new code rather than relying on default Flutter lint behavior.
