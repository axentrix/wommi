import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey.dart';
import '../providers/repository_provider.dart';
import '../providers/user_state_provider.dart';
import '../services/device_storage.dart';
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

    // Load profile data and navigate once ready (or after timeout)
    _loadProfileAndNavigate();
  }

  Future<void> _loadProfileAndNavigate() async {
    // Wait for animation (minimum 2.5s) and profile loading in parallel
    final animationDelay = Future.delayed(const Duration(milliseconds: 2500));
    final autoLoginSuccess = await _loadProfile();

    await animationDelay;

    if (mounted) {
      if (autoLoginSuccess) {
        // Device recognized - go directly to home screen
        print('[Splash] ✅ Auto-login successful, navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // New device or no profile - show landing screen
        print('[Splash] 📱 New device, navigating to landing');
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    }
  }

  Future<bool> _loadProfile() async {
    try {
      final repository = ref.read(repositoryProvider);

      // Check if device has a stored email (device memory)
      final storedEmail = await DeviceStorage.getEmail();

      if (storedEmail != null) {
        print('[Splash] Found stored email on device: $storedEmail');
        // Try to load profile for this email
        final profile = await repository.getUserProfileByEmail(storedEmail);

        if (profile != null) {
          print('[Splash] Auto-login with profile: ${profile.name}');
          return _hydrateFromProfile(profile.id, profile.name, profile.email);
        } else {
          print('[Splash] No profile found for stored email, clearing device storage');
          await DeviceStorage.clearEmail();
        }
      }

      // Fallback: check for any profile in database (legacy behavior)
      final profile = await repository.getUserProfile();
      if (profile != null) {
        print('[Splash] Found legacy profile: ${profile.name}');
        return _hydrateFromProfile(profile.id, profile.name, profile.email);
      }

      // No profile found
      return false;
    } catch (e, stackTrace) {
      print('[Splash] Error loading profile: $e');
      print('[Splash] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Restores everything tied to this profile: identity, completed journey
  /// history, and the currently in-progress journey's live day/gem count
  /// (which has no JourneyRecord of its own since it isn't finished yet).
  Future<bool> _hydrateFromProfile(int profileId, String name, String email) async {
    final repository = ref.read(repositoryProvider);
    final notifier = ref.read(userStateProvider.notifier);
    if (!mounted) return false;

    notifier.hydrateProfile(profileId, name, email);

    final records = await repository.getJourneyRecordsForUser(profileId);
    if (!mounted) return false;

    print('[Splash] Found ${records.length} journey records');
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

    final gemBalance = await repository.getCharmCount();
    final currentDay = await repository.calculateCurrentCycleDay();
    if (!mounted) return false;
    print('[Splash] Restoring active journey: day $currentDay, $gemBalance gems');
    notifier.hydrateActiveJourney(currentDay: currentDay, gemBalance: gemBalance);

    final completedDays = await repository.getDaysWithCharms();
    if (!mounted) return false;
    notifier.hydrateCompletedDays(completedDays);

    final inProgressDays = await repository.getDaysWithRitualProgress();
    if (!mounted) return false;
    notifier.hydrateInProgressDays(inProgressDays);

    return true;
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
