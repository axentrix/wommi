import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../providers/repository_provider.dart';
import '../providers/user_state_provider.dart';
import '../services/device_storage.dart';
import '../services/local_backup_storage.dart';
import '../models/journey.dart';
import '../widgets/welcome_dialog.dart';

const String _apiUrl = 'https://wommi.vercel.app/api/send-code';

/// Final onboarding step - collects name/email and verifies the email via a
/// 6-digit code. Lives in the same Navigator flow as the other onboarding
/// screens (rather than a blocking dialog) so the user can step back through
/// name -> email -> code, and back out to the previous questionnaire screen.
class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // 0 = name, 1 = email, 2 = verification code
  int _currentPage = 0;
  String? _emailError;
  String? _codeError;
  bool _isSubmitting = false;
  bool _isSendingCode = false;
  String? _verificationCode; // For displaying the code in test mode

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage -= 1;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _nextPage() {
    setState(() => _currentPage += 1);
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    setState(() {
      _isSendingCode = true;
      _emailError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'action': 'send'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _verificationCode = responseData['code']?.toString();
        });
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
    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim();

    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'action': 'verify', 'code': code}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['verified'] == true) {
          final repository = ref.read(repositoryProvider);
          final notifier = ref.read(userStateProvider.notifier);

          final allProfiles = await repository.getAllUserProfiles();

          // Check localStorage backup if IndexedDB is empty
          if (allProfiles.isEmpty) {
            final backupProfile = await LocalBackupStorage.getUserProfile();
            if (backupProfile != null) {
              final restoredId = await repository.createUserProfile(
                backupProfile['name'] as String,
                backupProfile['email'] as String,
              );

              final backupJourneys = await LocalBackupStorage.getJourneyHistory();
              for (var journey in backupJourneys) {
                await repository.saveJourneyRecord(
                  userProfileId: restoredId,
                  journeyNumber: journey['journeyNumber'] as int,
                  gemsCollected: journey['gemsCollected'] as int,
                  startDate: DateTime.parse(journey['startDate'] as String),
                  endDate: DateTime.parse(journey['endDate'] as String),
                );
              }
            }
          }

          // Check if profile exists for this email (device sync)
          final existingProfile = await repository.getUserProfileByEmail(email);
          if (!mounted) return;

          if (existingProfile != null) {
            // Existing user - sync their data
            notifier.hydrateProfile(
                existingProfile.id, existingProfile.name, existingProfile.email);

            final records =
                await repository.getJourneyRecordsForUser(existingProfile.id);
            if (!mounted) return;

            if (records.isNotEmpty) {
              notifier.hydrateJourneyHistory(
                records
                    .map((r) => Journey(
                          journeyNumber: r.journeyNumber,
                          gemsCollected: r.gemsCollected,
                          startDate: r.startDate,
                          endDate: r.endDate,
                          isActive: false,
                        ))
                    .toList(),
              );
            }

            // Restore the currently in-progress journey's live day/gem
            // count - it has no JourneyRecord yet since it isn't finished,
            // so without this a returning user's active progress would
            // appear to reset to day 1 / 0 gems even though their profile
            // and past journeys were just found.
            final gemBalance = await repository.getCharmCount();
            final currentDay = await repository.calculateCurrentCycleDay();
            final streakDays = await repository.getStreakDays();
            if (!mounted) return;
            notifier.hydrateActiveJourney(
              currentDay: currentDay,
              gemBalance: gemBalance,
              streakDays: streakDays,
            );

            final completedDays = await repository.getDaysWithCharms();
            if (!mounted) return;
            notifier.hydrateCompletedDays(completedDays);

            final inProgressDays = await repository.getDaysWithRitualProgress();
            if (!mounted) return;
            notifier.hydrateInProgressDays(inProgressDays);

            await LocalBackupStorage.saveUserProfile(
              profileId: existingProfile.id,
              name: existingProfile.name,
              email: existingProfile.email,
            );
            await LocalBackupStorage.saveJourneyHistory(
              records
                  .map((r) => {
                        'journeyNumber': r.journeyNumber,
                        'gemsCollected': r.gemsCollected,
                        'startDate': r.startDate.toIso8601String(),
                        'endDate': r.endDate.toIso8601String(),
                      })
                  .toList(),
            );

            await DeviceStorage.saveEmail(email);
          } else {
            // New user - create profile
            final name = _nameController.text.trim();
            final profileId = await repository.createUserProfile(name, email);
            if (!mounted) return;

            notifier.setProfile(profileId, name, email);

            await LocalBackupStorage.saveUserProfile(
              profileId: profileId,
              name: name,
              email: email,
            );
            await LocalBackupStorage.saveJourneyHistory([]);

            await DeviceStorage.saveEmail(email);
          }

          if (!mounted) return;
          // Welcome them only once, right after name/email are in - not
          // before, since this is the last onboarding step before they
          // actually land on the home screen.
          await showWelcomeDialog(context);
          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
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
    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: WommiColors.ink),
                    onPressed: (_isSubmitting || _isSendingCode) ? null : _goBack,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Progress bar - the questionnaire itself is done at this point,
            // so all segments are filled.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: WommiColors.cyan,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow
                    Text(
                      'ONE LAST THING',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10.5,
                        letterSpacing: 1.89,
                        color: WommiColors.rose,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sub-step dots
                    Row(
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= _currentPage
                                  ? WommiColors.cyan
                                  : WommiColors.line,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildPage(),
                  ],
                ),
              ),
            ),
            // Footer with button
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 26),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_isSubmitting || _isSendingCode) ? null : _handleContinue,
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
                  child: (_isSendingCode || _isSubmitting)
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
                              ? 'Continue'
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case 0:
        return _buildNamePage();
      case 1:
        return _buildEmailPage();
      default:
        return _buildCodePage();
    }
  }

  Widget _buildNamePage() {
    return Column(
      key: const ValueKey('name'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your name?',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.25,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'So Wommi knows what to call you.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            height: 1.55,
            color: WommiColors.inkDim,
          ),
        ),
        const SizedBox(height: 26),
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.inter(fontSize: 15, color: WommiColors.ink),
          decoration: _fieldDecoration(hintText: 'Enter your name'),
          onSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }

  Widget _buildEmailPage() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your email?',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.25,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ll send a 6-digit code to verify it\'s you.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            height: 1.55,
            color: WommiColors.inkDim,
          ),
        ),
        const SizedBox(height: 26),
        TextField(
          controller: _emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          style: GoogleFonts.inter(fontSize: 15, color: WommiColors.ink),
          decoration: _fieldDecoration(
            hintText: 'Enter your email',
            errorText: _emailError,
          ),
          onSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }

  Widget _buildCodePage() {
    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter verification code',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.25,
            color: WommiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a 6-digit code to ${_emailController.text.trim()}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            height: 1.55,
            color: WommiColors.inkDim,
          ),
        ),
        if (_verificationCode != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WommiColors.goldSoft.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WommiColors.gold, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: WommiColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Test Mode: Your code is $_verificationCode',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: WommiColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
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
          decoration: _fieldDecoration(
            hintText: '000000',
            errorText: _codeError,
            counterText: '',
          ).copyWith(
            hintStyle: GoogleFonts.spaceMono(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: WommiColors.inkDim.withOpacity(0.3),
              letterSpacing: 8,
            ),
          ),
          onSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    String? errorText,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 15, color: WommiColors.inkDim),
      errorText: errorText,
      counterText: counterText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WommiColors.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WommiColors.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WommiColors.cyan, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
