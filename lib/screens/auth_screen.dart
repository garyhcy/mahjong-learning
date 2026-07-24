import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show firebaseAvailable;
import '../services/app_i18n.dart';
import '../services/firebase_service.dart';
import '../services/otp_service.dart';
import '../widgets/mascot_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  // OTP flow state
  bool _showOtpScreen = false;
  String? _pendingEmail;
  String? _demoOtpHint; // shown in demo mode for testing

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        // Sign in — no OTP required for login (per Gary's spec).
        await FirebaseService.signIn(email, password);
      } else {
        // Sign up — generate OTP and move to OTP screen.
        final code = await FirebaseService.signUp(email, password);
        // In production a Cloud Function would email this. For now surface
        // it as a hint in debug/web test contexts only.
        if (kDebugMode || kIsWeb) {
          _demoOtpHint = code;
        }
        setState(() {
          _pendingEmail = email;
          _showOtpScreen = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.code);
      });
    } catch (_) {
      setState(() {
        _errorMessage = AppI18n.t('auth.unexpected');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _socialLogin(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (_) {
      setState(() {
        _errorMessage = AppI18n.t('auth.socialFailed');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() =>
      _socialLogin(() => FirebaseService.signInWithGoogle());

  Future<void> _signInWithApple() =>
      _socialLogin(() => FirebaseService.signInWithApple());

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return AppI18n.t('auth.noAccountFound');
      case 'wrong-password':
        return AppI18n.t('auth.wrongPassword');
      case 'invalid-email':
        return AppI18n.t('auth.validEmailFull');
      case 'user-disabled':
        return AppI18n.t('auth.accountDisabled');
      case 'email-already-in-use':
        return AppI18n.t('auth.emailInUse');
      case 'weak-password':
        return AppI18n.t('auth.weakPassword');
      default:
        return AppI18n.t('auth.authFailed');
    }
  }

  // ── OTP verification ──
  Future<void> _verifyOtp(String code) async {
    if (_pendingEmail == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await FirebaseService.verifyOtp(_pendingEmail!, code);

      if (result == OtpResult.success) {
        // Firebase mode: user is already created; auth state will switch.
        await OtpService.clear();
      } else {
        setState(() {
          switch (result) {
            case OtpResult.expired:
              _errorMessage = AppI18n.t('otp.expired');
              break;
            case OtpResult.tooManyAttempts:
              _errorMessage = AppI18n.t('otp.tooManyAttempts');
              break;
            default:
              _errorMessage = AppI18n.t('otp.incorrect');
          }
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = AppI18n.t('otp.failed');
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_pendingEmail == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final code = await FirebaseService.resendOtp(_pendingEmail!);
      if (kDebugMode || kIsWeb) {
        setState(() => _demoOtpHint = code);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppI18n.t('otp.resent').replaceAll('{email}', _pendingEmail ?? '')),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      setState(() {
        _errorMessage = AppI18n.t('otp.resendFailed');
      });
    }
  }

  void _backToForm() {
    setState(() {
      _showOtpScreen = false;
      _pendingEmail = null;
      _demoOtpHint = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOtpScreen) {
      return _buildOtpBody(context);
    }
    return _buildAuthBody(context);
  }

  Widget _buildAuthBody(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotWidget(
                    expression: MascotExpression.happy,
                    size: 120.0,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppI18n.t('auth.appName'),
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppI18n.t('auth.tagline'),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) ...[
                    _buildErrorBox(),
                    const SizedBox(height: 12),
                  ],
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  if (firebaseAvailable) ...[
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildGoogleButton(),
                    if (!kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.macOS)) ...[
                      const SizedBox(height: 12),
                      _buildAppleButton(),
                    ],
                  ],
                  const SizedBox(height: 20),
                  _buildToggleRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBody(BuildContext context) {
    return OtpVerificationScreen(
      email: _pendingEmail ?? '',
      demoOtpHint: _demoOtpHint,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onVerify: _verifyOtp,
      onResend: _resendOtp,
      onBack: _backToForm,
    );
  }

  // ── Form field builders ──
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(AppI18n.t('auth.email'), AppI18n.t('auth.emailHint'),
          const Icon(Icons.email_outlined, size: 20)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppI18n.t('auth.enterEmail');
        }
        if (!value.contains('@')) {
          return AppI18n.t('auth.validEmail');
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      decoration: _inputDecoration(AppI18n.t('auth.password'), null,
          const Icon(Icons.lock_outlined, size: 20)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppI18n.t('auth.enterPassword');
        }
        if (value.length < 6) {
          return AppI18n.t('auth.weakPassword');
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(
      String label, String? hint, Icon prefixIcon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
        ),
      labelStyle: GoogleFonts.nunito(color: const Color(0xFF9E9E9E)),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF5350).withAlpha(76)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF5350), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFFC62828),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4CAF50).withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppI18n.t(_isLogin ? 'auth.signIn' : 'auth.createAccount'),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(AppI18n.t('auth.or'),
              style: GoogleFonts.nunito(
                  fontSize: 13, color: const Color(0xFF9E9E9E))),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)),
        label: Text(AppI18n.t('auth.continueWithGoogle'),
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            )),
      ),
    );
  }

  Widget _buildAppleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signInWithApple,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.apple, size: 24, color: Colors.white),
        label: Text(AppI18n.t('auth.continueWithApple'),
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppI18n.t(_isLogin ? 'auth.noAccount' : 'auth.haveAccount'),
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: const Color(0xFF757575),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
              _errorMessage = null;
            });
          },
          child: Text(
            AppI18n.t(_isLogin ? 'auth.signUp' : 'auth.signIn'),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }
}

// ── OTP Verification Screen ──
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.demoOtpHint,
    required this.isLoading,
    this.errorMessage,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  final String email;
  final String? demoOtpHint;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onResend;
  final VoidCallback onBack;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all 6 digits are filled.
    if (_getOtpCode().length == 6) {
      _focusNodes[5].unfocus();
      widget.onVerify(_getOtpCode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const MascotWidget(
                expression: MascotExpression.thinking,
                size: 100.0,
              ),
              const SizedBox(height: 24),
              Text(
                AppI18n.t('otp.title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppI18n.t('otp.sentTo').replaceAll('{email}', widget.email),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              // Demo hint banner (only shown when demoOtpHint is set).
              if (widget.demoOtpHint != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF4CAF50).withAlpha(76)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF4CAF50), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AppI18n.t('otp.demoHint').replaceAll('{code}', widget.demoOtpHint ?? ''),
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildOtpFields(),
              const SizedBox(height: 20),
              if (widget.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEF5350).withAlpha(76)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF5350), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.errorMessage!,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: const Color(0xFFC62828),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          if (_getOtpCode().length == 6) {
                            widget.onVerify(_getOtpCode());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF4CAF50).withAlpha(150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppI18n.t('otp.verify'),
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppI18n.t('otp.didntReceive'),
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.isLoading ? null : widget.onResend,
                    child: Text(
                      AppI18n.t('otp.resend'),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2D2D),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}
