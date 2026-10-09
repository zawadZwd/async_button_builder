import 'dart:async';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncButtonBuilderCallback = Widget Function(BuildContext context, Widget child, AsyncCallback? callback, ButtonState buttonState);

/// A `builder` that wraps a button providing disabled, loading, success and
/// error states while retaining almost full access to the original Button's
/// API. This is useful for any long running operations and helps better
/// improve UX.
///
/// ```dart
/// AsyncButtonBuilder(
///   loadingWidget: const Text('Loading...'),
///   onPressed: () async {
///     await Future<void>.delayed(const Duration(seconds: 1));
///     throw StateError('yikes');
///   },
///   builder: (context, child, callback, buttonState) {
///     final buttonColor = switch (buttonState) {
///       ButtonIdle() => Colors.yellow[200],
///       ButtonLoading() => Colors.grey,
///       ButtonSuccess() => Colors.orangeAccent,
///       ButtonError() => Colors.orange,
///     };
///
///     return OutlinedButton(
///       onPressed: callback,
///       style: OutlinedButton.styleFrom(
///         foregroundColor: Colors.black,
///         backgroundColor: buttonColor,
///       ),
///       child: child,
///     );
///   },
///   child: const Text('Click Me'),
/// )
/// ```
class AsyncButtonBuilder extends StatefulWidget {
  /// This builder provides the widget's [BuildContext], the variable [child]
  /// based on button state as well as the [callback] that should be passed to
  /// the button and the current [ButtonState]
  final AsyncButtonBuilderCallback builder;

  /// The child of the button. In the case of an [IconButton], this can be a an
  /// [Icon]. For a [TextButton], a [Text].
  ///
  /// This child will be animated between for the [loadingWidget] or default
  /// [CircularProgressIndicator] when the asynchronous [onPressed] is called.
  /// The animation will take place over [duration].
  final Widget child;

  /// The animation's duration between [child], [loadingWidget],
  /// [successWidget] and [errorWidget]. This same value is used for both the
  /// internal [AnimatedSize] and [TransitionBuilder].
  final Duration duration;

  /// The animation's reverse duration between [child], [loadingWidget],
  /// [successWidget] and [errorWidget]. This same value is used for both the
  /// internal [AnimatedSize] and [TransitionBuilder].
  final Duration reverseDuration;

  /// A callback that runs the async task. The button shows [ButtonLoading]
  /// while the returned future is pending, then [ButtonSuccess] or
  /// [ButtonError]. If null, the button is disabled.
  final AsyncCallback? onPressed;

  /// Called once [successDuration] has elapsed after [ButtonSuccess], right
  /// before the button returns to [ButtonIdle]. Not called when
  /// [showSuccess] is false.
  final VoidCallback? onSuccess;

  /// Called once [errorDuration] has elapsed after [ButtonError], right
  /// before the button returns to [ButtonIdle]. Not called when [showError]
  /// is false.
  final VoidCallback? onError;

  /// This is used to manually drive the state of the loading button thus
  /// initiating the corresponding animation and showing the correct button
  /// child.
  final ButtonState buttonState;

  /// This is used to manually drive the disabled state of the button.
  final bool disabled;

  /// The widget replaces the [child] when the button is in the loading state.
  /// If this is null the default widget is:
  ///
  /// SizedBox(
  ///   height: 16.0,
  ///   width: 16.0,
  ///   child: CircularProgressIndicator(),
  /// )
  final Widget? loadingWidget;

  /// The widget used to replace the [child] when the button is in a success
  /// state. If this is null the default widget is:
  ///
  /// Icon(
  ///   Icons.check,
  ///   color: Theme.of(context).colorScheme.secondary,
  /// )
  final Widget? successWidget;

  /// The widget used to replace the [child] when the button is in a error
  /// state. If this is null the default widget is:
  ///
  /// Icon(
  ///   Icons.error,
  ///   color: Theme.of(context).colorScheme.error,
  /// )
  final Widget? errorWidget;

  /// Whether to show the [successWidget] on success.
  final bool showSuccess;

  /// Whether to show the [errorWidget] on error.
  final bool showError;

  /// Optional [EdgeInsets] that will wrap around the [errorWidget]. This is a
  /// convenience field that can be replaced by defining your own [errorWidget]
  /// and wrapping it in a [Padding].
  final EdgeInsets? errorPadding;

  /// Optional [EdgeInsets] that will wrap around the [successWidget]. This is a
  /// convenience field that can be replaced by defining your own
  /// [successWidget] and wrapping it in a [Padding].
  final EdgeInsets? successPadding;

  /// Defines a custom transition when animating between any state and `idle`
  final AnimatedSwitcherTransitionBuilder idleTransitionBuilder;

  /// Defines a custom transition when animating between any state and `loading`
  final AnimatedSwitcherTransitionBuilder loadingTransitionBuilder;

  /// Defines a custom transition when animating between any state and `success`
  final AnimatedSwitcherTransitionBuilder successTransitionBuilder;

  /// Defines a custom transition when animating between any state and `error`
  final AnimatedSwitcherTransitionBuilder errorTransitionBuilder;

  /// The amount of idle time the [successWidget] shows
  final Duration successDuration;

  /// The amount of idle time the [errorWidget] shows
  final Duration errorDuration;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `idle`
  final Curve idleSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `loading`
  final Curve loadingSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `success`
  final Curve successSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `error`
  final Curve errorSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `idle`
  final Curve idleSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `loading`
  final Curve loadingSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `success`
  final Curve successSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `error`
  final Curve errorSwitchOutCurve;

  /// Defines a curve for the internal [AnimatedSize]
  final Curve sizeCurve;

  /// Defines the [Clip] for the internal [AnimatedSize]
  final Clip sizeClipBehavior;

  /// Defines the [Alignment] for the internal [AnimatedSize]
  final Alignment sizeAlignment;

  /// Whether to animate the [Size] of the widget implicitly.
  final bool animateSize;

  /// Whether we should bubble up [AsyncButtonNotification]s up the widget tree.
  /// This is useful if you want to listen to the state of the button from a
  /// parent widget.
  final bool notifications;

  const AsyncButtonBuilder({
    super.key,
    required this.child,
    required this.onPressed,
    required this.builder,
    this.onSuccess,
    this.onError,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.showSuccess = true,
    this.showError = true,
    this.errorPadding,
    this.successPadding,
    this.buttonState = const ButtonIdle(),
    this.duration = const Duration(milliseconds: 250),
    this.reverseDuration = const Duration(milliseconds: 250),
    this.disabled = false,
    this.successDuration = const Duration(seconds: 1),
    this.errorDuration = const Duration(seconds: 1),
    this.loadingTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.idleTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.successTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.errorTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.idleSwitchInCurve = Curves.linear,
    this.loadingSwitchInCurve = Curves.linear,
    this.successSwitchInCurve = Curves.linear,
    this.errorSwitchInCurve = Curves.linear,
    this.idleSwitchOutCurve = Curves.linear,
    this.loadingSwitchOutCurve = Curves.linear,
    this.successSwitchOutCurve = Curves.linear,
    this.errorSwitchOutCurve = Curves.linear,
    this.sizeCurve = Curves.linear,
    this.sizeClipBehavior = Clip.hardEdge,
    this.sizeAlignment = Alignment.center,
    this.animateSize = true,
    this.notifications = true,
  });

  @override
  State<AsyncButtonBuilder> createState() => _AsyncButtonBuilderState();
}

class _AsyncButtonBuilderState extends State<AsyncButtonBuilder> {
  late ButtonState buttonState;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    buttonState = widget.buttonState;
  }

  @override
  void didUpdateWidget(covariant AsyncButtonBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.buttonState != oldWidget.buttonState) {
      setState(() => buttonState = widget.buttonState);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase(context);

    final switcher = AnimatedSwitcher(
      // TODO: This duration is same as size's duration. That's okay right?
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      switchInCurve: phase.switchInCurve,
      switchOutCurve: phase.switchOutCurve,
      transitionBuilder: phase.transitionBuilder,
      child: phase.child,
    );

    return widget.builder(
      context,
      // TODO: I really just wanted an AnimatedSwitcher and the default
      // transitionBuilder to be a SizedTransition but it was impossible
      // to figure out how to reproduce the exact behaviour of AnimatedSize
      widget.animateSize ? _animatedSize(switcher) : switcher,
      _pressCallback(),
      buttonState,
    );
  }

  /// Curves, transition and child for the current [buttonState].
  ///
  /// Nested builders must not share `__idle__`, `__loading__` and the other
  /// state keys, so a parent [ValueKey] is appended when one is set.
  _Phase _phase(BuildContext context) {
    final theme = Theme.of(context);
    final parentKey = _parentKeyValue(widget.key);
    final loadingChild = widget.loadingWidget ?? const SizedBox(height: 16.0, width: 16.0, child: CircularProgressIndicator());
    final successChild = _padded(widget.successPadding, widget.successWidget ?? Icon(Icons.check, color: theme.colorScheme.secondary));
    final errorChild = _padded(widget.errorPadding, widget.errorWidget ?? Icon(Icons.error, color: theme.colorScheme.error));

    return switch (buttonState) {
      ButtonIdle() => (
        switchInCurve: widget.idleSwitchInCurve,
        switchOutCurve: widget.idleSwitchOutCurve,
        transitionBuilder: widget.idleTransitionBuilder,
        child: _keyed('__idle__', parentKey, widget.child),
      ),
      ButtonLoading() => (
        switchInCurve: widget.loadingSwitchInCurve,
        switchOutCurve: widget.loadingSwitchOutCurve,
        transitionBuilder: widget.loadingTransitionBuilder,
        child: _keyed('__loading__', parentKey, loadingChild),
      ),
      ButtonSuccess() => (
        switchInCurve: widget.successSwitchInCurve,
        switchOutCurve: widget.successSwitchOutCurve,
        transitionBuilder: widget.successTransitionBuilder,
        child: _keyed('__success__', parentKey, successChild),
      ),
      ButtonError() => (
        switchInCurve: widget.errorSwitchInCurve,
        switchOutCurve: widget.errorSwitchOutCurve,
        transitionBuilder: widget.errorTransitionBuilder,
        child: _keyed('__error__', parentKey, errorChild),
      ),
    };
  }

  Widget _animatedSize(Widget child) {
    return AnimatedSize(
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      alignment: widget.sizeAlignment,
      clipBehavior: widget.sizeClipBehavior,
      curve: widget.sizeCurve,
      child: child,
    );
  }

  AsyncCallback? _pressCallback() {
    if (widget.disabled || widget.onPressed == null) return null;

    return switch (buttonState) {
      ButtonIdle() => _handlePressed,
      _ => null,
    };
  }

  Future<void> _handlePressed() {
    final completer = Completer<void>();

    // I might not want to set buttonState if we're being
    // driven by widget.buttonState...
    _emit(const ButtonLoading());
    timer?.cancel();

    widget.onPressed
        ?.call()
        .then((_) {
          completer.complete();
          if (!mounted) return;

          _showOutcome(show: widget.showSuccess, outcome: const ButtonSuccess(), duration: widget.successDuration, onFinished: widget.onSuccess);
        })
        .catchError((Object error, StackTrace stackTrace) {
          completer.completeError(error, stackTrace);
          if (!mounted) return;

          _showOutcome(show: widget.showError, outcome: ButtonError(error, stackTrace), duration: widget.errorDuration, onFinished: widget.onError);
        });

    return completer.future;
  }

  void _showOutcome({required bool show, required ButtonState outcome, required Duration duration, required VoidCallback? onFinished}) {
    if (!show) {
      _emit(const ButtonIdle());
      return;
    }

    _emit(outcome);
    _resetAfter(duration, onFinished);
  }

  void _emit(ButtonState next) {
    setState(() => buttonState = next);

    if (widget.notifications && context.mounted) {
      AsyncButtonNotification(buttonState: next).dispatch(context);
    }
  }

  void _resetAfter(Duration duration, VoidCallback? then) {
    timer = Timer(duration, () {
      timer?.cancel();
      then?.call();

      if (!mounted) return;

      setState(() => buttonState = const ButtonIdle());

      if (widget.notifications) {
        const AsyncButtonNotification(buttonState: ButtonIdle()).dispatch(context);
      }
    });
  }
}

typedef _Phase = ({Curve switchInCurve, Curve switchOutCurve, AnimatedSwitcherTransitionBuilder transitionBuilder, Widget child});

Widget _keyed(String stateKey, String parentKey, Widget child) {
  return KeyedSubtree(key: ValueKey('$stateKey$parentKey'), child: child);
}

Widget _padded(EdgeInsets? padding, Widget child) {
  if (padding == null) return child;
  return Padding(padding: padding, child: child);
}

String _parentKeyValue(Key? key) {
  if (key is ValueKey) return key.value.toString();
  return '';
}
