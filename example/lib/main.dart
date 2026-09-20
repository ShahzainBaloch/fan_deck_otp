import 'package:flutter/material.dart';
import 'package:fan_deck_otp/fan_deck_otp.dart';

void main() {
  runApp(const FanDeckOtpDemoApp());
}

class FanDeckOtpDemoApp extends StatelessWidget {
  const FanDeckOtpDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fan Deck OTP Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D7BD9)),
        useMaterial3: true,
      ),
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  final FanDeckOtpController _sixDigitController = FanDeckOtpController();
  final FanDeckOtpController _fourDigitController = FanDeckOtpController();

  bool _isSixDigitLoading = false;
  String _lastCompletedCode = '';

  @override
  void dispose() {
    _sixDigitController.dispose();
    _fourDigitController.dispose();
    super.dispose();
  }

  void _onSixDigitCompleted(String code) async {
    setState(() {
      _lastCompletedCode = code;
      _isSixDigitLoading = true;
    });

    // Simulate network authentication verification
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isSixDigitLoading = false;
    });

    if (code == '123456') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification Successful! 🎉'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP! Try 123456 (Triggering shake & reset)'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      _sixDigitController.triggerError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'fan_deck_otp Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Section 1: Standard 6-Digit OTP Card
            _buildCard(
              title: '1. Standard 6-Digit OTP',
              subtitle:
                  'Fans out like a deck of playing cards and merges into a single center card with a neon loader.',
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  FanDeckOtpField(
                    length: 6,
                    otpController: _sixDigitController,
                    isLoading: _isSixDigitLoading,
                    onCompleted: _onSixDigitCompleted,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _sixDigitController.triggerError(),
                        icon: const Icon(Icons.vibration, size: 18),
                        label: const Text('Trigger Error Shake'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          foregroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _sixDigitController.clear(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  if (_lastCompletedCode.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Last Entered: $_lastCompletedCode (hint: try 123456)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: 4-Digit Obscured PIN Code Card
            _buildCard(
              title: '2. 4-Digit Obscured PIN',
              subtitle:
                  'Supports any length (N=4) with obscured digits (•) and custom emerald gradient colors.',
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  FanDeckOtpField(
                    length: 4,
                    otpController: _fourDigitController,
                    obscureText: true,
                    obscuringCharacter: '●',
                    theme: const FanDeckOtpTheme(
                      activeBorderColor: Color(0xFF059669),
                      filledBorderColor: Color(0xFF10B981),
                      activeFillColor: Color(0xFFECFDF5),
                      textStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                      loaderColors: [
                        Color(0xFF059669),
                        Color(0xFF34D399),
                        Color(0xFF059669),
                      ],
                    ),
                    onCompleted: (pin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('4-Digit PIN Completed: $pin'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _fourDigitController.triggerError(),
                        icon: const Icon(Icons.bolt, size: 18),
                        label: const Text('Trigger Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          foregroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _fourDigitController.clear(),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Dark Cyber Theme
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3. Cyber Dark Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Glowing neon violet & cyan accents with dark card backgrounds.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: FanDeckOtpField(
                      length: 5,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
