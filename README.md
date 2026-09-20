# fan_deck_otp 🎴

A stunning, physics-inspired Flutter OTP & PIN input widget featuring a **2-stage playing card fan-and-stack collapse animation**, a **rotating neon border loader**, and an **error rejection shake**.

Elevate your authentication and verification flow from standard static boxes into an engaging, polished micro-interaction that users love.

---

## ✨ Features

- 🃏 **2-Stage Card Deck Animation:**
  - **Phase 1 (Fan Arc):** When the final digit is entered, all boxes smoothly slide inward and fan out into an elegant card arc (e.g. `±25°`).
  - **Phase 2 (Stack Collapse):** The cards smoothly un-rotate and collapse directly into a single merged card in the center.
- ⚡ **Rotating Neon Border Loader:**
  - Seamless `SweepGradient` neon border with an outer blur glow that continuously spins around the merged card while verification is underway.
  - Fully customizable glow colors, line width, and speed.
- 💥 **Damped Sine-Wave Error Shake:**
  - On invalid code entry, an authentic decaying sine-wave shake vibrates the card, dissolves the digits, clears the input, and smoothly fans the cards back out into separate boxes with an error border.
- 🔢 **Dynamic Length (N-Digits):**
  - Works out of the box with any length: 4-digit PINs, 6-digit OTPs, or custom lengths with mathematically balanced fan symmetry.
- 🎮 **Dedicated Controller (`FanDeckOtpController`):**
  - Programmatic triggers for `triggerError()`, `clear()`, `isLocked`, and text manipulation.
  - Also fully compatible with Flutter's standard `TextEditingController`.
- 🔒 **PIN & Obscure Support:**
  - Support `obscureText: true` with configurable obscuring character (`•`, `*`, `●`, etc.).
- 🎨 **Deep Theming (`FanDeckOtpTheme`):**
  - Customize box dimensions, borders, fill colors, typography, shadows, fan angle, and animation timings.
- 📳 **Haptics & Native Autofill:**
  - Light impact on key press, medium impact on completion, and heavy vibration on error.
  - Native SMS / OTP autofill hints supported.

---

## 🎬 How the Animation Works

```
Typing:       [ 1 ]  [ 2 ]  [ 3 ]  [ 4 ]  [ 5 ]  [ 6 ]
                       │
                       ▼
Phase 1:          \  \  |  /  /    (Slides inward & fans into arc)
                       │
                       ▼
Phase 2:             [   ]         (Collapses into 1 single card)
                       │
                       ▼
Verifying:          [ ✦ ]          (Rotating neon border spinner)
                       │
                       ▼
If Invalid:       [ ~ ~ ]          (Vibrates, dissolves digits &
                                    fans back out into 6 boxes)
```

---

## 📦 Getting Started

Add `fan_deck_otp` to your `pubspec.yaml`:

```yaml
dependencies:
  fan_deck_otp: ^1.0.0
```

Or run:

```bash
flutter pub add fan_deck_otp
```

---

## 🚀 Quick Start

### 1. Basic 6-Digit OTP Field

```dart
import 'package:flutter/material.dart';
import 'package:fan_deck_otp/fan_deck_otp.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final FanDeckOtpController _controller = FanDeckOtpController();
  bool _isLoading = false;

  void _verifyOtp(String code) async {
    setState(() => _isLoading = true);

    // Simulate API verification
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (code == '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Successful! 🎉')),
      );
    } else {
      // Trigger error shake, dissolve & reverse fan-out
      _controller.triggerError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FanDeckOtpField(
            length: 6,
            otpController: _controller,
            isLoading: _isLoading,
            onCompleted: _verifyOtp,
          ),
        ),
      ),
    );
  }
}
```

---

### 2. 4-Digit Obscured PIN Code

```dart
FanDeckOtpField(
  length: 4,
  obscureText: true,
  obscuringCharacter: '●',
  theme: const FanDeckOtpTheme(
    activeBorderColor: Color(0xFF059669),
    filledBorderColor: Color(0xFF10B981),
    activeFillColor: Color(0xFFECFDF5),
    loaderColors: [
      Color(0xFF059669),
      Color(0xFF34D399),
      Color(0xFF059669),
    ],
  ),
  onCompleted: (pin) => print('Entered PIN: $pin'),
)
```

---

### 3. Cyber Dark Neon Theme

```dart
FanDeckOtpField(
  length: 6,
  theme: const FanDeckOtpTheme(
    activeBorderColor: Color(0xFF8B5CF6),
    filledBorderColor: Color(0xFFA78BFA),
    inactiveBorderColor: Color(0xFF334155),
    activeFillColor: Color(0xFF1E1B4B),
    inactiveFillColor: Color(0xFF1E293B),
    filledFillColor: Color(0xFF0F172A),
    textStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE0E7FF),
    ),
    loaderColors: [
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
    ],
  ),
)
```

---

## ⚙️ Properties & Customization

### `FanDeckOtpField`

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `length` | `int` | `6` | Number of digit boxes (minimum 2). |
| `otpController` | `FanDeckOtpController?` | `null` | Controller providing `triggerError()`, `clear()`, etc. |
| `controller` | `TextEditingController?` | `null` | Standard Flutter text controller. |
| `theme` | `FanDeckOtpTheme` | `FanDeckOtpTheme()` | Visual styles, timing durations, and colors. |
| `isLoading` | `bool` | `false` | Displays rotating neon border loader around merged card. |
| `errorTrigger` | `int` | `0` | Counter triggering error shake whenever incremented. |
| `obscureText` | `bool` | `false` | Masks entered digits. |
| `obscuringCharacter` | `String` | `'•'` | Masking character used when `obscureText` is true. |
| `enableHaptics` | `bool` | `true` | Triggers subtle tactile vibrations on type and error. |
| `readOnly` | `bool` | `false` | Disallows user input interaction. |
| `autofocus` | `bool` | `false` | Automatically requests focus on mount. |
| `onChanged` | `ValueChanged<String>?` | `null` | Invoked on each text change. |
| `onCompleted` | `ValueChanged<String>?` | `null` | Invoked immediately when all digits are entered. |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Invoked on keyboard action submit. |

---

### `FanDeckOtpTheme`

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `boxWidth` | `double?` | `null` (auto-fit) | Width of each digit box. |
| `boxHeight` | `double` | `56.0` | Height of each digit box. |
| `gap` | `double?` | `null` (auto-fit) | Spacing between boxes in row layout. |
| `borderRadius` | `BorderRadius` | `12.0` | Corner radius of the boxes. |
| `activeBorderColor` | `Color` | `#2D7BD9` | Border color for focused box. |
| `filledBorderColor` | `Color` | `rgba(#2D7BD9, 0.6)` | Border color for filled boxes. |
| `inactiveBorderColor`| `Color` | `#CBD5E1` | Border color for empty boxes. |
| `errorBorderColor` | `Color` | `#EF4444` | Border color during error state. |
| `activeFillColor` | `Color` | `#EFF6FF` | Background fill for focused box. |
| `filledFillColor` | `Color` | `Colors.white` | Background fill for filled boxes. |
| `inactiveFillColor` | `Color` | `#F8FAFC` | Background fill for empty boxes. |
| `errorFillColor` | `Color` | `#FEF2F2` | Background fill during error state. |
| `textStyle` | `TextStyle` | `22px Bold #0F172A` | Font style for entered digits. |
| `errorTextStyle` | `TextStyle` | `22px Bold #DC2626` | Font style during error state. |
| `loaderColors` | `List<Color>` | `[#2D7BD9, #00F0FF, #2D7BD9]` | Gradient colors for neon loader. |
| `maxFanAngle` | `double` | `25.0` | Maximum angular spread in degrees. |
| `fanDuration` | `Duration` | `900ms` | Duration for card fan and collapse transition. |
| `shakeDuration` | `Duration` | `450ms` | Duration for damped error shake. |
| `dissolveDuration`| `Duration` | `200ms` | Duration for digit opacity fade-out on error. |
| `loaderDuration` | `Duration` | `1500ms` | Duration for a 360° spin of the neon border. |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
