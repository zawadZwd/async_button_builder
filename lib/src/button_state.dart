/// The state of an `AsyncButtonBuilder`: [ButtonIdle], [ButtonLoading],
/// [ButtonSuccess] or [ButtonError].
///
/// ```dart
/// final color = switch (buttonState) {
///   ButtonIdle() => Colors.pink,
///   ButtonLoading() => Colors.blue,
///   ButtonSuccess() => Colors.green,
///   ButtonError() => Colors.red,
/// };
/// ```
sealed class ButtonState {
  const ButtonState();
}

final class ButtonIdle extends ButtonState {
  const ButtonIdle();

  @override
  bool operator ==(Object other) => other is ButtonIdle;

  @override
  int get hashCode => (ButtonIdle).hashCode;
}

final class ButtonLoading extends ButtonState {
  const ButtonLoading();

  @override
  bool operator ==(Object other) => other is ButtonLoading;

  @override
  int get hashCode => (ButtonLoading).hashCode;
}

final class ButtonSuccess extends ButtonState {
  const ButtonSuccess();

  @override
  bool operator ==(Object other) => other is ButtonSuccess;

  @override
  int get hashCode => (ButtonSuccess).hashCode;
}

final class ButtonError extends ButtonState {
  final Object error;
  final StackTrace? stackTrace;

  const ButtonError(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) => other is ButtonError && other.error == error && other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);
}
