import 'package:flutter/material.dart';

/// Optional dedicated controller for [FanDeckOtpField] that provides programmatic
/// triggers such as [triggerError], [clear], and [isLocked] status.
class FanDeckOtpController extends ChangeNotifier {
  final TextEditingController textEditingController;
  final bool _ownsTextController;

  bool _isLocked = false;
  int _errorTrigger = 0;

  FanDeckOtpController({
    String? initialText,
    TextEditingController? textController,
  })  : textEditingController = textController ??
            TextEditingController(text: initialText ?? ''),
        _ownsTextController = textController == null {
    textEditingController.addListener(_onInternalTextChanged);
  }

  /// The current text value of the OTP input.
  String get text => textEditingController.text;

  set text(String value) {
    textEditingController.text = value;
  }

  /// Whether the input is currently locked/frozen (disallowing user entry).
  bool get isLocked => _isLocked;

  set isLocked(bool value) {
    if (_isLocked != value) {
      _isLocked = value;
      notifyListeners();
    }
  }

  /// Internal error trigger counter used to inform the widget of an error event.
  int get errorTrigger => _errorTrigger;

  /// Programmatically triggers the error sequence:
  /// Damped sine-wave shake, digit dissolve, input clear, and reverse fan-out.
  void triggerError() {
    _errorTrigger++;
    notifyListeners();
  }

  /// Clears the input code.
  void clear() {
    textEditingController.clear();
  }

  /// Locks input interaction.
  void lock() {
    isLocked = true;
  }

  /// Unlocks input interaction.
  void unlock() {
    isLocked = false;
  }

  void _onInternalTextChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    textEditingController.removeListener(_onInternalTextChanged);
    if (_ownsTextController) {
      textEditingController.dispose();
    }
    super.dispose();
  }
}
