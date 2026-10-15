import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/widgets.dart';

class AsyncButtonNotification extends Notification {
  const AsyncButtonNotification({
    required this.buttonState,
  });

  final ButtonState buttonState;
}
