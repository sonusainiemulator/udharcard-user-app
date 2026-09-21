import 'dart:async';
import 'package:flutter/foundation.dart';

/// A lightweight, reliable Debouncer that cancels previous pending calls
/// when user is rapidly typing into text fields.
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}
