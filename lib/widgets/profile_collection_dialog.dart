import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../providers/repository_provider.dart';
import '../providers/user_state_provider.dart';

const String apiUrl = 'https://wommi.vercel.app/api/send-code';

class ProfileCollectionDialog extends ConsumerStatefulWidget {
  const ProfileCollectionDialog({super.key});

  @override
  ConsumerState<ProfileCollectionDialog> createState() => _ProfileCollectionDialogState();
}

class _ProfileCollectionDialogState extends ConsumerState<ProfileCollectionDialog> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  int _currentPage = 0;
  String? _emailError;
  String? _codeError;
  bool _isSubmitting = false;
  bool _isSendingCode = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    setState(() {
      _isSendingCode = true;
      _emailError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'action': 'send'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _nextPage();
      } else {
        setState(() {
          _emailError = 'Failed to send verification code. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = 'Network error. Please check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'action': 'verify', 'code': code}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['verified'] == true) {
          // Check if email is already in database
          final repository = ref.read(repositoryProvider);
          final alreadyUsed = await repository.isEmailTaken(email);
          if (!mounted) return;

          if (alreadyUsed) {
            setState(() {
              _isSubmitting = false;
              _codeError = 'This email is already in use.';
            });
            return;
          }

          // Create profile
          final name = _nameController.text.trim();
          print('[ProfileDialog] Creating profile: $name ($email)');
          final profileId = await repository.createUserProfile(name, email);
          if (!mounted) return;

          print('[ProfileDialog] Profile created with ID: $profileId');
          ref.read(userStateProvider.notifier).setProfile(profileId, name, email);
          print('[ProfileDialog] Profile set in state');
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isSubmitting = false;
            _codeError = 'Invalid verification code.';
          });
        }
      } else {
        final responseData = json.decode(response.body);
        setState(() {
          _isSubmitting = false;
          _codeError = responseData['error'] ?? 'Verification failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _codeError = 'Network error. Please check your connection.';
      });
    }
  }

  Future<void> _handleContinue() async {
    // Page 0: Name
    if (_currentPage == 0) {
      if (_nameController.text.trim().isNotEmpty) {
        _nextPage();
      }
      return;
    }

    // Page 1: Email - send verification code
    if (_currentPage == 1) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        setState(() => _emailError = 'Please enter a valid email.');
        return;
      }
      await _sendVerificationCode();
      return;
    }

    // Page 2: Verify code
    if (_currentPage == 2) {
      final code = _codeController.text.trim();
      if (code.length != 6) {
        setState(() => _codeError = 'Please enter the 6-digit code.');
        return;
      }
      await _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissal
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: WommiColors.bg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Content
              Container(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      '🌸',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Wommi',
                      style: GoogleFonts.unbounded(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: WommiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s personalize your experience',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: WommiColors.inkDim,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Page view
                    SizedBox(
                      height: 140,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          // Page 1: Name
                          _buildNamePage(),
                          // Page 2: Email
                          _buildEmailPage(),
                          // Page 3: Verification Code
                          _buildCodePage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  children: [
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == 0
                                ? WommiColors.cyan
                                : WommiColors.line,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == 1
                                ? WommiColors.cyan
                                : WommiColors.line,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == 2
                                ? WommiColors.cyan
                                : WommiColors.line,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _isSendingCode) ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WommiColors.cyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 14,
                          shadowColor: WommiColors.cyan.withOpacity(0.38),
                        ),
                        child: _isSendingCode
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _currentPage == 0
                                    ? 'Next'
                                    : _currentPage == 1
                                        ? 'Send Code'
                                        : 'Complete',
                                style: GoogleFonts.unbounded(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your name?',
          style: GoogleFonts.unbounded(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: WommiColors.ink,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: WommiColors.inkDim,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.cyan,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => _nextPage(),
        ),
      ],
    );
  }

  Widget _buildEmailPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your email?',
          style: GoogleFonts.unbounded(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          style: GoogleFonts.inter(
            fontSize: 15,
            color: WommiColors.ink,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: WommiColors.inkDim,
            ),
            errorText: _emailError,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.cyan,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }

  Widget _buildCodePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter verification code',
          style: GoogleFonts.unbounded(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to ${_emailController.text.trim()}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: WommiColors.inkDim,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (_) {
            if (_codeError != null) {
              setState(() => _codeError = null);
            }
          },
          style: GoogleFonts.spaceMono(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: WommiColors.ink,
            letterSpacing: 8,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: GoogleFonts.spaceMono(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: WommiColors.inkDim.withOpacity(0.3),
              letterSpacing: 8,
            ),
            errorText: _codeError,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.line,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WommiColors.cyan,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }
}
