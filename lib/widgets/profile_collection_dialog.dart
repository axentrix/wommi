import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';

class ProfileCollectionDialog extends StatefulWidget {
  const ProfileCollectionDialog({super.key});

  @override
  State<ProfileCollectionDialog> createState() => _ProfileCollectionDialogState();
}

class _ProfileCollectionDialogState extends State<ProfileCollectionDialog> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: Consumer(
                        builder: (context, ref, child) {
                          return ElevatedButton(
                            onPressed: () {
                              if (_currentPage == 0) {
                                if (_nameController.text.trim().isNotEmpty) {
                                  _nextPage();
                                }
                              } else {
                                if (_emailController.text.trim().isNotEmpty) {
                                  // Save profile
                                  ref.read(userStateProvider.notifier).setProfile(
                                        _nameController.text.trim(),
                                        _emailController.text.trim(),
                                      );
                                  Navigator.of(context).pop();
                                }
                              }
                            },
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
                            child: Text(
                              _currentPage == 0 ? 'Next' : 'Complete',
                              style: GoogleFonts.unbounded(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          );
                        },
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
        ),
      ],
    );
  }
}
