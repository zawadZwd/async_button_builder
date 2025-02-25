import 'dart:async';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncButtonBuilderCallback = Widget Function(
  BuildContext context,
  Widget child,
  AsyncCallback? callback,
  ButtonState buttonState,
);

/// A `builder` that wraps a button providing disabled, loading, success and
/// error states while retaining almost full access to the original Button's
/// API. This is useful for any long running operations and helps better
/// improve UX.
///
/// {@tool dartpad --template=stateful_widget_material}
///
/// ```dart
///
/// @override
/// Widget build(BuildContext context) {
///   return AsyncButtonBuilder(
///     child: Text('Click Me'),
///     loadingWidget: Text('Loading...'),
///     onPressed: () async {
///       await Future.delayed(Duration(seconds: 1));
///
///       throw 'yikes';
///     },
///     builder: (context, child, callback, buttonState) {
///       final buttonColor = buttonState.when(
///         idle: () => Colors.yellow[200],
///         loading: () => Colors.grey,
///         success: () => Colors.orangeAccent,
///         error: () => Colors.orange,
///       );
///
///       return OutlinedButton(
///         child: child,
///         onPressed: callback,
///         style: OutlinedButton.styleFrom(
///           primary: Colors.black,
///           backgroundColor: buttonColor,
///         ),
///       );
///     },
///   ),
/// }
/// ```
/// {@end-tool}
///
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

  /// A callback that runs the async task. This is wrapped in order to begin
  /// the button's internal `isLoading` before and after the operation
  /// completes.
  final AsyncCallback? onPressed;

  /// A callback that runs [buttonState] changes to [ButtonState.success]
  final VoidCallback? onSuccess;

  /// A callback that runs [buttonState] changes to [ButtonState.error]
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
  ///   color: Theme.of(context).accentColor,
  /// );
  final Widget? successWidget;

  /// The widget used to replace the [child] when the button is in a error
  /// state. If this is null the default widget is:
  ///
  /// Icon(
  ///   Icons.error,
  ///   color: Theme.of(context).errorColor,
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
    Key? key,
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
    this.buttonState = const ButtonState.idle(),
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
  }) : super(key: key);

  @override
  State<AsyncButtonBuilder> createState() => _AsyncButtonBuilderState();
}

class _AsyncButtonBuilderState extends State<AsyncButtonBuilder> with SingleTickerProviderStateMixin {
  late ButtonState buttonState;
  Timer? timer;

  @override
  void initState() {
    buttonState = widget.buttonState;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AsyncButtonBuilder oldWidget) {
    if (widget.buttonState != oldWidget.buttonState) {
      setState(() {
        buttonState = widget.buttonState;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPressed = widget.onPressed;
    final widgetKey = widget.key;
    final loadingWidget = widget.loadingWidget ??
        const SizedBox(
          height: 16.0,
          width: 16.0,
          child: CircularProgressIndicator(),
        );
    var successWidget = widget.successWidget ??
        Icon(
          Icons.check,
          color: theme.colorScheme.secondary,
        );
    var errorWidget = widget.errorWidget ??
        Icon(
          Icons.error,
          color: theme.colorScheme.error,
        );
    final successPadding = widget.successPadding;
    final errorPadding = widget.errorPadding;

    // This is necessary in the case of nested async button builders.
    // We cannot have the same __idle__, __loading__, etc. keys as they might
    // conflict with one another.
    String parentKeyValue = '';

    if (widgetKey != null && widgetKey is ValueKey) {
      parentKeyValue = widgetKey.value.toString();
    }

    if (successPadding != null) {
      successWidget = Padding(
        padding: successPadding,
        child: successWidget,
      );
    }

    if (errorPadding != null) {
      errorWidget = Padding(
        padding: errorPadding,
        child: errorWidget,
      );
    }

    final switcher = AnimatedSwitcher(
      // TODO: This duration is same as size's duration. That's okay right?
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      switchInCurve: switch (buttonState) {
        ButtonState.idle => widget.idleSwitchInCurve,
        ButtonState.loading => widget.loadingSwitchInCurve,
        ButtonState.success => widget.successSwitchInCurve,
        _ => widget.errorSwitchInCurve,
      },
      switchOutCurve: switch (buttonState) {
        ButtonState.idle => widget.idleSwitchOutCurve,
        ButtonState.loading => widget.loadingSwitchOutCurve,
        ButtonState.success => widget.successSwitchOutCurve,
        _ => widget.errorSwitchOutCurve,
      },
      transitionBuilder: switch (buttonState) {
        ButtonState.idle => widget.idleTransitionBuilder,
        ButtonState.loading => widget.loadingTransitionBuilder,
        ButtonState.success => widget.successTransitionBuilder,
        _ => widget.errorTransitionBuilder,
      },
      child: switch (buttonState) {
        ButtonState.idle => KeyedSubtree(
            key: ValueKey('__idle__$parentKeyValue'),
            child: widget.child,
          ),
        ButtonState.loading => KeyedSubtree(
            key: ValueKey('__loading__$parentKeyValue'),
            child: loadingWidget,
          ),
        ButtonState.success => KeyedSubtree(
            key: ValueKey('__success__$parentKeyValue'),
            child: successWidget,
          ),
        _ => KeyedSubtree(
            key: ValueKey('__error__$parentKeyValue'),
            child: errorWidget,
          ),
      },
    );

    return widget.builder(
      context,
      // TODO: I really just wanted an AnimatedSwitcher and the default
      // transitionBuilder to be a SizedTransition but it was impossible
      // to figure out how to reproduce the exact behaviour of AnimatedSize
      widget.animateSize
          ? AnimatedSize(
              duration: widget.duration,
              reverseDuration: widget.reverseDuration,
              alignment: widget.sizeAlignment,
              clipBehavior: widget.sizeClipBehavior,
              curve: widget.sizeCurve,
              child: switcher,
            )
          : switcher,
      widget.disabled
          ? null
          : switch (buttonState) {
              ButtonState.idle => () {
                  final completer = Completer<void>();

                  // I might not want to set buttonState if we're being
                  // driven by widget.buttonState...
                  setState(() {
                    buttonState = const ButtonState.loading();
                  });

                  if (widget.notifications) {
                    const AsyncButtonNotification(
                      buttonState: ButtonState.loading(),
                    ).dispatch(context);
                  }

                  timer?.cancel();

                  onPressed?.call().then((_) {
                    completer.complete();

                    if (mounted) {
                      if (widget.showSuccess) {
                        setState(() {
                          buttonState = const ButtonState.success();
                        });

                        if (widget.notifications && context.mounted) {
                          const AsyncButtonNotification(
                            buttonState: ButtonState.success(),
                          ).dispatch(context);
                        }

                        setTimer(widget.successDuration, widget.onSuccess);
                      } else {
                        setState(() {
                          buttonState = const ButtonState.idle();
                        });

                        if (widget.notifications && context.mounted) {
                          const AsyncButtonNotification(
                            buttonState: ButtonState.idle(),
                          ).dispatch(context);
                        }
                      }
                    }
                  }).catchError((Object error, StackTrace stackTrace) {
                    completer.completeError(error, stackTrace);

                    if (mounted) {
                      if (widget.showError) {
                        setState(() {
                          buttonState = ButtonState.error(error, stackTrace);
                        });

                        if (widget.notifications && context.mounted) {
                          AsyncButtonNotification(
                            buttonState: ButtonState.error(error, stackTrace),
                          ).dispatch(context);
                        }

                        setTimer(widget.errorDuration, widget.onError);
                      } else {
                        setState(() {
                          buttonState = const ButtonState.idle();
                        });

                        if (widget.notifications && context.mounted) {
                          const AsyncButtonNotification(
                            buttonState: ButtonState.idle(),
                          ).dispatch(context);
                        }
                      }
                    }
                  });

                  return completer.future;
                },
              _ => null,
            },
      buttonState,
    );
  }

  void setTimer(Duration duration, [VoidCallback? then]) {
    timer = Timer(
      duration,
      () {
        timer?.cancel();

        then?.call();

        if (mounted) {
          setState(() {
            buttonState = const ButtonState.idle();
          });

          if (widget.notifications) {
            const AsyncButtonNotification(
              buttonState: ButtonState.idle(),
            ).dispatch(context);
          }
        }
      },
    );
  }
}


/*

buttonState.maybeWhen(
              idle: () => () {
                
              },
              orElse: () => null,
            ),




*/