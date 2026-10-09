// import 'package:equatable/equatable.dart';

sealed class ButtonState {
  const ButtonState();
}

final class ButtonIdle extends ButtonState {
  const ButtonIdle();
}

final class ButtonLoading extends ButtonState {
  const ButtonLoading();
}

final class ButtonSuccess extends ButtonState {
  const ButtonSuccess();
}

final class ButtonError extends ButtonState {
  final Object error;
  final StackTrace? stackTrace;

  const ButtonError(this.error, [this.stackTrace]);
}
