import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'card_border_loader.dart';
import 'fan_deck_otp_controller.dart';
import 'fan_deck_otp_theme.dart';

/// A premium animated OTP & PIN input widget featuring a 2-stage playing card
/// fan-and-stack collapse animation, rotating neon border loader, and error shake reset.
class FanDeckOtpField extends StatefulWidget {
  /// Number of code digits/boxes (e.g. 4, 6). Defaults to 6.
  final int length;

  /// Optional standard [TextEditingController].
  final TextEditingController? controller;

  /// Optional dedicated [FanDeckOtpController] providing helper methods like [triggerError].
  final FanDeckOtpController? otpController;

  /// Visual theme and timing configuration.
  final FanDeckOtpTheme theme;

  /// Optional custom [FocusNode].
  final FocusNode? focusNode;

  /// Whether to autofocus this input on mount.
  final bool autofocus;

  /// Whether user interaction is disabled.
  final bool readOnly;

  /// Whether the input is currently in a loading/verifying state.
  final bool isLoading;

  /// Trigger counter for invalid OTP errors. Whenever this counter increases,
  /// the error shake & reset animation plays.
  final int errorTrigger;

  /// Whether to obscure the entered code (useful for PIN entry).
  final bool obscureText;

  /// Character to display when [obscureText] is enabled. Defaults to '•'.
  final String obscuringCharacter;

  /// Keyboard type for input. Defaults to [TextInputType.number].
  final TextInputType keyboardType;

  /// Optional input formatters for filtering or custom entry logic.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to provide subtle haptic feedback on typing and error.
  final bool enableHaptics;

  /// Invoked whenever the entered text changes.
  final ValueChanged<String>? onChanged;

  /// Invoked as soon as all digits ([length]) have been entered.
  final ValueChanged<String>? onCompleted;

  /// Invoked when the keyboard action button is pressed.
  final ValueChanged<String>? onSubmitted;

  const FanDeckOtpField({
    super.key,
    this.length = 6,
    this.controller,
    this.otpController,
    this.theme = const FanDeckOtpTheme(),
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.isLoading = false,
    this.errorTrigger = 0,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.enableHaptics = true,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
  }) : assert(length >= 2, 'FanDeckOtpField length must be at least 2');

  @override
  State<FanDeckOtpField> createState() => FanDeckOtpFieldState();
}

class FanDeckOtpFieldState extends State<FanDeckOtpField>
    with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final TextEditingController _effectiveTextController;
  final bool _ownsTextController = false;

  late final AnimationController _fanOutController;
  late final Animation<double> _fanOutAnimation;
  late final AnimationController _loadingBorderController;
  late final AnimationController _shakeController;
  late final AnimationController _digitsOpacityController;

  bool _isMerged = false;
  bool _isError = false;
  bool _isErrorAnimating = false;
  int _lastErrorTrigger = 0;
  async.Timer? _errorResetTimer;

  TextEditingController get _textController =>
      widget.otpController?.textEditingController ??
      widget.controller ??
      _effectiveTextController;

  bool get _isLocked =>
      widget.readOnly || (widget.otpController?.isLocked ?? false);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);

    if (widget.controller == null && widget.otpController == null) {
      _effectiveTextController = TextEditingController();
    } else {
      _effectiveTextController = _textController;
    }

    _textController.addListener(_onTextChange);
    widget.otpController?.addListener(_onOtpControllerChanged);

    _lastErrorTrigger = widget.errorTrigger;

    _fanOutController = AnimationController(
      vsync: this,
      duration: widget.theme.fanDuration,
    );
    _fanOutAnimation = CurvedAnimation(
      parent: _fanOutController,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );

    _loadingBorderController = AnimationController(
      vsync: this,
      duration: widget.theme.loaderDuration,
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: widget.theme.shakeDuration,
    );

    _digitsOpacityController = AnimationController(
      vsync: this,
      duration: widget.theme.dissolveDuration,
      value: 1.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateAnimationState();
      if (widget.autofocus && !_focusNode.hasFocus && !_isLocked) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant FanDeckOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.theme.fanDuration != widget.theme.fanDuration) {
      _fanOutController.duration = widget.theme.fanDuration;
    }
    if (oldWidget.theme.loaderDuration != widget.theme.loaderDuration) {
      _loadingBorderController.duration = widget.theme.loaderDuration;
      _loadingBorderController.repeat();
    }
    if (oldWidget.theme.shakeDuration != widget.theme.shakeDuration) {
      _shakeController.duration = widget.theme.shakeDuration;
    }
    if (oldWidget.theme.dissolveDuration != widget.theme.dissolveDuration) {
      _digitsOpacityController.duration = widget.theme.dissolveDuration;
    }

    if (oldWidget.controller != widget.controller ||
        oldWidget.otpController != widget.otpController) {
      oldWidget.controller?.removeListener(_onTextChange);
      oldWidget.otpController?.textEditingController
          .removeListener(_onTextChange);
      oldWidget.otpController?.removeListener(_onOtpControllerChanged);

      _textController.addListener(_onTextChange);
      widget.otpController?.addListener(_onOtpControllerChanged);
    }

    if (widget.errorTrigger != _lastErrorTrigger &&
        widget.errorTrigger > _lastErrorTrigger) {
      _lastErrorTrigger = widget.errorTrigger;
      triggerWrongOtpAnimation();
    } else {
      _updateAnimationState();
    }
  }

  void _onOtpControllerChanged() {
    final otpCtrl = widget.otpController;
    if (otpCtrl == null) return;
    if (otpCtrl.errorTrigger > _lastErrorTrigger) {
      _lastErrorTrigger = otpCtrl.errorTrigger;
      triggerWrongOtpAnimation();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChange);
    widget.otpController?.removeListener(_onOtpControllerChanged);
    if (_ownsTextController) {
      _effectiveTextController.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChanged);
    }
    _errorResetTimer?.cancel();
    _fanOutController.dispose();
    _loadingBorderController.dispose();
    _shakeController.dispose();
    _digitsOpacityController.dispose();
    super.dispose();
  }

  double get _shakeOffset {
    if (!_shakeController.isAnimating) return 0.0;
    final p = _shakeController.value;
    // Damped sine wave: 3 oscillations decaying smoothly to 0
    final decay = 1.0 - p;
    return math.sin(p * math.pi * 6) * 12.0 * decay;
  }

  /// Programmatically triggers the invalid OTP animation:
  /// horizontal shake, digit dissolve, input clear, and smooth reverse fan-out.
  Future<void> triggerWrongOtpAnimation() async {
    if (!mounted) return;

    if (widget.enableHaptics) {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _isError = true;
      _isErrorAnimating = true;
      _isMerged = false;
    });

    // 1. Shake horizontally
    _shakeController.forward(from: 0.0);

    // 2. Dissolve / fade out the digits
    await _digitsOpacityController.animateTo(
      0.0,
      duration: widget.theme.dissolveDuration,
      curve: Curves.easeOut,
    );

    // 3. Clear text while invisible
    _textController.clear();
    _digitsOpacityController.value = 1.0;

    // 4. Smoothly fan out and reverse cards back to row positions
    if (_fanOutController.value > 0.0) {
      await _fanOutController.animateTo(
        0.0,
        duration: widget.theme.fanDuration,
        curve: Curves.easeOutCubic,
      );
    }

    if (!mounted) return;

    setState(() {
      _isErrorAnimating = false;
    });

    // 5. Restore focus
    if (!_focusNode.hasFocus && !_isLocked) {
      _focusNode.requestFocus();
    }

    // 6. Reset error border after brief delay
    _errorResetTimer?.cancel();
    _errorResetTimer = async.Timer(const Duration(milliseconds: 800), () {
      if (mounted && _isError) {
        setState(() {
          _isError = false;
        });
      }
    });
  }

  void _onTextChange() {
    if (_isError && _textController.text.isNotEmpty) {
      setState(() {
        _isError = false;
      });
    } else {
      setState(() {});
    }

    final text = _textController.text.trim();
    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }

    if (text.length == widget.length && widget.onCompleted != null) {
      if (widget.enableHaptics) {
        HapticFeedback.mediumImpact();
      }
      widget.onCompleted!(text);
    }

    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (_isErrorAnimating) return;
    final isFull = _textController.text.trim().length == widget.length;

    if (isFull && !_isMerged) {
      _isMerged = true;
      _fanOutController.forward(from: 0.0);
    } else if (!isFull && _isMerged) {
      _isMerged = false;
      _fanOutController.reverse(from: _fanOutController.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text.trim();
    final isFocused = _focusNode.hasFocus && !_isLocked;
    final count = widget.length;

    return GestureDetector(
      onTap: () {
        if (_isLocked) return;
        if (_isError) {
          setState(() {
            _isError = false;
          });
        }
        if (!_focusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final double boxWidth = widget.theme.boxWidth ??
              math.min(48.0, (totalWidth - ((count - 1) * 8.0)) / count);
          final double boxHeight = widget.theme.boxHeight;
          final double gap = widget.theme.gap ??
              ((totalWidth - (count * boxWidth)) / (count - 1)).clamp(4.0, 32.0);

          final double centerIndex = (count - 1) / 2.0;

          return SizedBox(
            height: boxHeight + 36.0,
            width: totalWidth,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Hidden native TextField receiving keyboard inputs, autofill & gestures
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      keyboardType: widget.keyboardType,
                      maxLength: widget.length,
                      readOnly: _isLocked,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: widget.inputFormatters ??
                          [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: widget.onSubmitted,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Animated Builder for 2-Stage Transition:
                // Stage 1 (0.0 -> 0.5): Row positions slide into center & fan out into an arc
                // Stage 2 (0.5 -> 1.0): Cards un-rotate and collapse into a single stacked card
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _fanOutAnimation,
                    _loadingBorderController,
                    _shakeController,
                    _digitsOpacityController,
                  ]),
                  builder: (context, child) {
                    final t = _fanOutAnimation.value;
                    final double loaderOpacity =
                        (!_isError && !_isErrorAnimating && t > 0.85)
                            ? ((t - 0.85) / 0.15).clamp(0.0, 1.0)
                            : 0.0;

                    return Transform.translate(
                      offset: Offset(_shakeOffset, 0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          ...List.generate(count, (index) {
                            String digit = '';
                            if (index < text.length) {
                              digit = widget.obscureText
                                  ? widget.obscuringCharacter
                                  : text[index];
                            }

                            final isCurrent = isFocused &&
                                ((index == text.length) ||
                                    (index == count - 1 &&
                                        text.length == count));
                            final isFilled = index < text.length;

                            final double rowX =
                                (index - centerIndex) * (boxWidth + gap);

                            // Calculate target fan angle in degrees
                            final double fraction =
                                count <= 1 ? 0.5 : index / (count - 1.0);
                            final double targetAngleDeg =
                                -widget.theme.maxFanAngle +
                                    (fraction * 2.0 * widget.theme.maxFanAngle);

                            double currentX;
                            double angleRad;

                            if (t <= 0.5) {
                              // Phase 1: Separate row boxes -> Circular Fan Arc
                              final double p1 = (t / 0.5).clamp(0.0, 1.0);
                              final double start1 =
                                  (index / count.toDouble()) * 0.25;
                              final double end1 =
                                  math.min(1.0, start1 + 0.75);
                              final double rawT1 =
                                  ((p1 - start1) / (end1 - start1))
                                      .clamp(0.0, 1.0);
                              final double progress1 =
                                  Curves.easeInOutCubic.transform(rawT1);

                              currentX = rowX * (1.0 - progress1);
                              angleRad = (targetAngleDeg * progress1) *
                                  (math.pi / 180.0);
                            } else {
                              // Phase 2: Fan Arc -> Single Center Merged Card (0° rotation)
                              final double p2 =
                                  ((t - 0.5) / 0.5).clamp(0.0, 1.0);
                              final double progress2 =
                                  Curves.easeInOutCubic.transform(p2);

                              currentX = 0.0;
                              angleRad = (targetAngleDeg * (1.0 - progress2)) *
                                  (math.pi / 180.0);
                            }

                            final Color borderColor = _isError
                                ? widget.theme.errorBorderColor
                                : (isCurrent
                                    ? widget.theme.activeBorderColor
                                    : (isFilled
                                        ? widget.theme.filledBorderColor
                                        : widget.theme.inactiveBorderColor));

                            final double borderWidth = _isError
                                ? widget.theme.errorBorderWidth
                                : (isCurrent
                                    ? widget.theme.activeBorderWidth
                                    : widget.theme.borderWidth);

                            final Color fillColor = _isError
                                ? widget.theme.errorFillColor
                                : (isFilled
                                    ? widget.theme.filledFillColor
                                    : (isCurrent
                                        ? widget.theme.activeFillColor
                                        : widget.theme.inactiveFillColor));

                            final List<BoxShadow>? shadows = _isError
                                ? widget.theme.errorBoxShadow
                                : (isCurrent
                                    ? widget.theme.activeBoxShadow
                                    : widget.theme.boxShadow);

                            return Transform.translate(
                              offset: Offset(currentX, 0),
                              child: Transform.rotate(
                                angle: angleRad,
                                alignment: widget.theme.fanPivotAlignment,
                                child: Container(
                                  width: boxWidth,
                                  height: boxHeight,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: widget.theme.borderRadius,
                                    border: Border.all(
                                      color: borderColor,
                                      width: borderWidth,
                                    ),
                                    boxShadow: shadows,
                                  ),
                                  child: Opacity(
                                    opacity: _digitsOpacityController.value
                                        .clamp(0.0, 1.0),
                                    child: Text(
                                      digit,
                                      style: _isError
                                          ? widget.theme.errorTextStyle
                                          : widget.theme.textStyle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Glowing rotating neon border loader overlay
                          if (loaderOpacity > 0) ...[
                            Opacity(
                              opacity: loaderOpacity,
                              child: IgnorePointer(
                                child: SizedBox(
                                  width: boxWidth,
                                  height: boxHeight,
                                  child: CustomPaint(
                                    painter: CardBorderLoaderPainter(
                                      angle: _loadingBorderController.value *
                                          2 *
                                          math.pi,
                                      colors: widget.theme.loaderColors,
                                      borderRadius: widget.theme.borderRadius,
                                      glowWidth: widget.theme.loaderGlowWidth,
                                      lineWidth: widget.theme.loaderLineWidth,
                                      blurRadius:
                                          widget.theme.loaderBlurRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
