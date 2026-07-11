import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey.dart';
import '../providers/repository_provider.dart';
import '../providers/user_state_provider.dart';
import '../theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Restore a previously entered name/email, if any, so returning users
    // are never asked to enter their email again.
    _loadProfile();

    // Navigate to landing after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    });
  }

  Future<void> _loadProfile() async {
    final repository = ref.read(repositoryProvider);
    final profile = await repository.getUserProfile();
    if (!mounted || profile == null) return;

    final notifier = ref.read(userStateProvider.notifier);
    notifier.hydrateProfile(profile.id, profile.name, profile.email);

    final records = await repository.getJourneyRecordsForUser(profile.id);
    if (!mounted || records.isEmpty) return;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              WommiColors.lilac.withOpacity(0.3),
              WommiColors.bg,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo placeholder - replace with actual logo later
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        WommiColors.lilac,
                        WommiColors.rose.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: WommiColors.rose.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🫧',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Wommi',
                  style: TextStyle(
                    fontFamily: 'Unbounded',
                    fontWeight: FontWeight.w800,
                    fontSize: 42,
                    color: WommiColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your fertility companion',
                  style: TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 11,
                    letterSpacing: 2,
                    color: WommiColors.inkDim,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
