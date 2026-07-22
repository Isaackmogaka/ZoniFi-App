import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/wallet_state.dart';
import 'home_screen.dart';

/// OtpScreen: now requires a verificationId from LoginScreen — the
/// "receipt" proving an SMS was genuinely requested for this number.
/// Combined with whatever the user types, this is what lets us check
/// the code for real against Firebase, instead of accepting any 6
/// digits like our test version did.
class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  String get _enteredCode => _controllers.map((c) => c.text).join();

  /// The real verification: combine the verificationId (proof an SMS
  /// was requested) with what the user typed into ONE credential
  /// object, then ask Firebase to check it. This can genuinely fail
  /// now — wrong code, expired code — unlike our test version.
  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _enteredCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign-in succeeded but no user was returned.');
      }

      HapticFeedback.mediumImpact();

      // This is the real handoff moment: WalletState now knows WHICH
      // real, permanent user this is, and loads (or creates) their
      // actual Firestore data — no more shared test_user_1.
      if (mounted) {
        await context.read<WalletState>().setUserId(user.uid);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Genuinely wrong or expired code lands here. We clear the
      // boxes and let the user try again, rather than letting them
      // through on bad input.
      HapticFeedback.vibrate();
      setState(() {
        _isVerifying = false;
        _errorMessage = e.code == 'invalid-verification-code'
            ? 'Incorrect code. Please try again.'
            : (e.message ?? 'Verification failed. Please try again.');
        for (final controller in _controllers) {
          controller.clear();
        }
      });
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    } catch (e) {
      HapticFeedback.vibrate();
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _resendCode() {
    HapticFeedback.lightImpact();
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _errorMessage = null;
    });
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'To resend, go back and tap "Send code" again.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
    // NOTE: a fuller implementation would re-call verifyPhoneNumber
    // directly from here using the resendToken Firebase provides —
    // kept simple for now by directing the user back to LoginScreen,
    // which already has working send logic.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.slate400),
                  children: [
                    const TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildDigitBox(index)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppColors.red),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!_isComplete || _isVerifying) ? null : _verifyCode,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _resendCode,
                  child: const Text(
                    "Didn't get a code? Resend",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }

          setState(() {});

          if (_isComplete) {
            FocusScope.of(context).unfocus();
            _verifyCode();
          }
        },
      ),
    );
  }
}