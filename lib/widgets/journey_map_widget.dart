import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/user_state.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/challenges_screen.dart';
import 'cycle_day_info_dialog.dart';
import 'ovary_phase_dialog.dart';

/// Journey map laid out over the isometric womb illustration: a single
/// combined node for the ovary/follicular days (whose real-world length
/// varies and isn't known in advance) connected by the fallopian tube into
/// the uterus, then individual day markers for the rest of the cycle.
/// This is a placeholder background - it will be replaced with a Rive
/// animation. Tapping any marker previews the "zoom into this region"
/// camera move that the eventual Rive scene will own for real.
class JourneyMapWidget extends ConsumerStatefulWidget {
  const JourneyMapWidget({super.key});

  @override
  ConsumerState<JourneyMapWidget> createState() => _JourneyMapWidgetState();
}

class _JourneyMapWidgetState extends ConsumerState<JourneyMapWidget>
    with SingleTickerProviderStateMixin {
  // Matches the cropped background image's own pixel dimensions, so the
  // day path lines up with it at any screen size.
  static const double _bgWidth = 762;
  static const double _bgHeight = 849;

  // Days 1..ovaryDayCount are bundled into a single node near the ovary,
  // rather than plotted individually - ovulation timing varies, so we
  // don't know in advance exactly how many days that phase will last. Once
  // the user tells us ovulation started (UserState.ovulationDay), the day
  // *before* that becomes the real boundary instead of this default guess -
  // the marked day itself is when the egg enters the tube, so it should
  // read as day 1 of the tube phase, not the last day of the ovary phase.
  // Until it's marked, this default keeps growing to keep up with
  // currentDay - we don't know ovulation happened yet, so every day so far
  // still belongs in the ovary, not off on an assumed tube/uterus path.
  static const int defaultOvaryDayCount = 14;

  // Once ovulation is marked, the days from that point travel through the
  // fallopian tube on their way to the uterus - shown as up to this many
  // individual markers along the tube itself, rather than lumped into the
  // ovary node or jumping straight to the uterus path.
  static const int tubeStepSlots = 5;

  // The uterus phase defaults to this many days after the tube - together
  // with tubeStepSlots that's an 18-day post-ovulation journey by default
  // (5 tube + 13 uterus) - but, same idea as the ovary, keeps growing to
  // keep up with currentDay if the journey runs long, up to this cap.
  static const int defaultUterusDayCount = 13;
  static const int maxUterusDayCount = 15;

  // How far a tapped marker's region "zooms in" to preview the eventual
  // Rive camera move - purely a placeholder interaction.
  static const double _zoomScale = 2.6;

  late final AnimationController _zoomController;
  late final Animation<double> _zoomCurve;
  Alignment _zoomFocal = Alignment.center;

  // Which marker the map is currently zoomed into, so the reopen chip below
  // can bring its dialog back without re-triggering the zoom - and so the
  // back button knows there's something to zoom back out of. Closing the
  // dialog itself (X, tap-outside, "Not now"...) no longer un-zooms; only
  // the back button does.
  bool _zoomed = false;
  int? _activeDay;
  bool _activeIsOvary = false;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _zoomCurve = CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  /// Zooms the map in on [focal] (fractional 0..1 position of whatever was
  /// tapped) if it isn't already zoomed in, remembers it as the active
  /// marker, then shows its dialog. Does *not* zoom back out when the
  /// dialog closes - only [_exitZoom] does that.
  Future<void> _openZoomedMarker(
    Offset focal, {
    int? day,
    bool isOvary = false,
  }) async {
    setState(() {
      _activeDay = day;
      _activeIsOvary = isOvary;
    });
    if (!_zoomed) {
      setState(() {
        _zoomed = true;
        _zoomFocal = FractionalOffset(focal.dx, focal.dy);
      });
      await _zoomController.forward();
    }
    await _showActiveDialog();
  }

  /// Re-shows whichever dialog belongs to the currently zoomed-in marker,
  /// recomputing its state fresh - used by the reopen chip.
  Future<void> _showActiveDialog() async {
    final userState = ref.read(userStateProvider);
    if (_activeIsOvary) {
      await _showOvaryPhase(
        context,
        userState.currentDay,
        _ovaryDayCount(userState),
      );
    } else if (_activeDay != null) {
      final day = _activeDay!;
      final isCompleted = userState.completedDays.contains(day);
      await _showDayInfo(
        context,
        day,
        isCompleted: isCompleted,
        isInProgress: !isCompleted && userState.inProgressDays.contains(day),
        isCurrent: day == userState.currentDay,
        isFuture: day > userState.currentDay,
      );
    }
  }

  /// The only way back to the normal map view once zoomed in.
  Future<void> _exitZoom() async {
    await _zoomController.reverse();
    if (!mounted) return;
    setState(() {
      _zoomed = false;
      _activeDay = null;
      _activeIsOvary = false;
    });
  }

  // Clamped so there are always at least 2 individually-plotted days after
  // it - _getPositionForDay's t = 0/(individualDayCount - 1) would divide
  // by zero otherwise, if ovulation were ever marked on day 34 or later.
  // Fixed at defaultOvaryDayCount until ovulation is marked - it doesn't
  // grow with currentDay the way the uterus does, since the ovulation
  // toggle is always available (see CycleDayInfoDialog) as the way to
  // close it off, on any day, regardless of when the journey started.
  int _ovaryDayCount(UserState userState) {
    final ovulationDay = userState.ovulationDay;
    final base = ovulationDay != null ? ovulationDay - 1 : defaultOvaryDayCount;
    return base.clamp(1, 33);
  }

  /// A phase's day count, starting at [defaultCount] but growing to keep up
  /// with [currentDay] (capped at [maxCount]) as long as it hasn't been
  /// closed off by some other signal yet (ovulation marked, period/
  /// pregnancy marked, ...) - used for both the ovary and the uterus.
  static int _growableCount({
    required int defaultCount,
    required int maxCount,
    required int phaseStartDay,
    required int currentDay,
  }) {
    final daysSoFar = currentDay - phaseStartDay + 1;
    if (daysSoFar <= defaultCount) return defaultCount;
    return math.min(daysSoFar, maxCount);
  }

  /// How many of the tube's marker slots have a real day behind them.
  /// Once ovulation is marked, all tubeStepSlots are real. Before that we
  /// don't know for sure which days belong in the tube, but the user can
  /// still be well past the ovary bundle without having marked it yet -
  /// so, same as the ovary and uterus, this grows to keep up with
  /// currentDay instead of leaving every slot as a dead placeholder until
  /// the toggle is used.
  static int _tubeDayCount(UserState userState, int ovaryDayCount) {
    final capacity =
        math.min(tubeStepSlots, 35 - ovaryDayCount).clamp(0, tubeStepSlots);
    if (userState.ovulationDay != null) return capacity;

    final daysPastOvary = userState.currentDay - ovaryDayCount;
    if (daysPastOvary <= 0) return 0;
    return math.min(daysPastOvary, capacity);
  }

  /// The uterus phase's day count - defaults to [defaultUterusDayCount] but
  /// grows to keep up with currentDay (capped at [maxUterusDayCount]) if
  /// the journey runs long without the period/pregnancy toggle being used.
  static int _uterusDayCount(UserState userState, int uterusStartDay) {
    return _growableCount(
      defaultCount: defaultUterusDayCount,
      maxCount: maxUterusDayCount,
      phaseStartDay: uterusStartDay,
      currentDay: userState.currentDay,
    );
  }

  // Fallopian tube path (fractions of the background image's size),
  // starting at the ovary and ending where it opens into the uterus. Used
  // both to draw the connecting line and, further down, to place markers
  // evenly along it.
  static const List<Offset> _tubePoints = [
    Offset(0.1772, 0.3357),
    Offset(0.0984, 0.2650),
    Offset(0.0591, 0.1649),
    Offset(0.1247, 0.0884),
    Offset(0.2428, 0.0707),
    Offset(0.3281, 0.1060),
    Offset(0.3675, 0.1354),
  ];

  /// tubeStepSlots points spread evenly along the tube's curve (by arc
  /// length, not by the raw control points above, which aren't evenly
  /// spaced and whose first/last points already coincide with the ovary
  /// node and the uterus entry). Computed in the background image's own
  /// pixel space so spacing is stable regardless of the widget's actual
  /// rendered size, then expressed back as fractions of it.
  static List<Offset> _tubeStepFractions() {
    const refSize = Size(_bgWidth, _bgHeight);
    final scaled = _tubePoints
        .map((p) => Offset(p.dx * refSize.width, p.dy * refSize.height))
        .toList();
    final metric = _buildSmoothTubePath(scaled).computeMetrics().first;

    return List.generate(tubeStepSlots, (i) {
      final t = (i + 1) / (tubeStepSlots + 1);
      final tangent = metric.getTangentForOffset(metric.length * t);
      final position = tangent?.position ?? scaled.last;
      return Offset(position.dx / refSize.width, position.dy / refSize.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);
    final currentDay = userState.currentDay;
    final ovaryDayCount = _ovaryDayCount(userState);
    final tubeDayCount = _tubeDayCount(userState, ovaryDayCount);
    final tubeFractions = _tubeStepFractions();
    final uterusStartDay = ovaryDayCount + tubeDayCount + 1;
    final uterusDayCount = _uterusDayCount(userState, uterusStartDay);
    final uterusEndDay = uterusStartDay + uterusDayCount - 1;
    // The uterus path should continue smoothly from wherever the tube
    // markers actually ended - the last real tube marker if there is one,
    // otherwise the tube's raw geometric end point (its original anchor,
    // from before ovulation tracking existed).
    final uterusAnchor =
        tubeDayCount > 0 ? tubeFractions[tubeDayCount - 1] : _tubePoints.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AspectRatio(
            aspectRatio: _bgWidth / _bgHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildZoomableMap(
                    userState,
                    currentDay,
                    ovaryDayCount,
                    tubeDayCount,
                    tubeFractions,
                    uterusStartDay,
                    uterusEndDay,
                    uterusAnchor,
                  )),
                  if (_zoomed) ...[
                    _buildBackButton(),
                    _buildReopenChip(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomableMap(
    UserState userState,
    int currentDay,
    int ovaryDayCount,
    int tubeDayCount,
    List<Offset> tubeFractions,
    int uterusStartDay,
    int uterusEndDay,
    Offset uterusAnchor,
  ) {
    return LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final mapStack = Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/womb_journey_bg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TubePathPainter(points: _tubePoints),
                        ),
                      ),
                      _buildOvaryNode(
                          context, userState, currentDay, ovaryDayCount, size),
                      for (int i = 0; i < tubeStepSlots; i++)
                        i < tubeDayCount
                            ? _buildMapPosition(
                                context,
                                ovaryDayCount + 1 + i,
                                currentDay,
                                tubeFractions[i],
                                Offset(tubeFractions[i].dx * size.width,
                                    tubeFractions[i].dy * size.height),
                              )
                            : _buildTubeStepPlaceholder(
                                Offset(tubeFractions[i].dx * size.width,
                                    tubeFractions[i].dy * size.height),
                              ),
                      for (int day = uterusStartDay; day <= uterusEndDay; day++)
                        _buildMapPosition(
                          context,
                          day,
                          currentDay,
                          _getFractionForDay(
                              day, uterusStartDay, uterusEndDay, uterusAnchor),
                          _getPositionForDay(
                              day, uterusStartDay, uterusEndDay, uterusAnchor, size),
                        ),
                    ],
                  );

                  return AnimatedBuilder(
                    animation: _zoomCurve,
                    builder: (context, child) {
                      final scale =
                          1.0 + (_zoomScale - 1.0) * _zoomCurve.value;
                      return Transform.scale(
                        scale: scale,
                        alignment: _zoomFocal,
                        child: child,
                      );
                    },
                    child: mapStack,
                  );
                },
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 10,
      left: 10,
      child: GestureDetector(
        onTap: _exitZoom,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back, size: 18, color: WommiColors.ink),
        ),
      ),
    );
  }

  Widget _buildReopenChip() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _showActiveDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: WommiColors.cyan,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: WommiColors.cyan.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'View details',
                  style: GoogleFonts.unbounded(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The combined node standing in for days 1..ovaryDayCount.
  Widget _buildOvaryNode(
    BuildContext context,
    UserState userState,
    int currentDay,
    int ovaryDayCount,
    Size size,
  ) {
    final completedCount = List.generate(ovaryDayCount, (i) => i + 1)
        .where((d) => userState.completedDays.contains(d))
        .length;
    final hasProgress = List.generate(ovaryDayCount, (i) => i + 1)
        .any((d) => userState.inProgressDays.contains(d) ||
            userState.completedDays.contains(d));
    final isCurrentPhase = currentDay <= ovaryDayCount;
    final allCompleted = completedCount == ovaryDayCount;

    const nodeSize = 46.0;
    final position = _tubePoints.first;

    return Positioned(
      left: position.dx * size.width - nodeSize / 2,
      top: position.dy * size.height - nodeSize / 2,
      child: GestureDetector(
        onTap: () => _openZoomedMarker(position, isOvary: true),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentPhase
                    ? WommiColors.cyan
                    : allCompleted
                        ? WommiColors.gold.withOpacity(0.85)
                        : hasProgress
                            ? WommiColors.roseSoft
                            : Colors.white.withOpacity(0.85),
                border: Border.all(
                  color: isCurrentPhase
                      ? WommiColors.cyan
                      : allCompleted
                          ? WommiColors.gold
                          : hasProgress
                              ? WommiColors.rose
                              : WommiColors.line,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCurrentPhase ? WommiColors.cyan : Colors.black)
                        .withOpacity(isCurrentPhase ? 0.4 : 0.15),
                    blurRadius: isCurrentPhase ? 14 : 5,
                    spreadRadius: isCurrentPhase ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: allCompleted
                    ? Icon(Icons.check, size: 18, color: WommiColors.ink)
                    : Text(
                        '1-$ovaryDayCount',
                        style: GoogleFonts.unbounded(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCurrentPhase ? Colors.white : WommiColors.ink,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: WommiColors.bg.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ovary • tap to open',
                style: GoogleFonts.spaceMono(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  color: WommiColors.inkDim,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOvaryPhase(
    BuildContext context,
    int currentDay,
    int ovaryDayCount,
  ) {
    return showDialog(
      context: context,
      builder: (context) => OvaryPhaseDialog(
        dayCount: ovaryDayCount,
        onDayTap: (day) {
          Navigator.pop(context);
          setState(() {
            _activeIsOvary = false;
            _activeDay = day;
          });
          final userState = ref.read(userStateProvider);
          _showDayInfo(
            context,
            day,
            isCompleted: userState.completedDays.contains(day),
            isInProgress: !userState.completedDays.contains(day) &&
                userState.inProgressDays.contains(day),
            isCurrent: day == currentDay,
            isFuture: day > currentDay,
          );
        },
      ),
    );
  }

  /// A plain, non-interactive dot marking one of the tube's step slots that
  /// doesn't have a real day behind it yet - ovulation hasn't been marked,
  /// so we don't know which days (if any) will travel through the tube.
  Widget _buildTubeStepPlaceholder(Offset position) {
    const dotSize = 12.0;
    return Positioned(
      left: position.dx - dotSize / 2,
      top: position.dy - dotSize / 2,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.35),
          border: Border.all(color: WommiColors.line.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMapPosition(
    BuildContext context,
    int day,
    int currentDay,
    Offset fraction,
    Offset position,
  ) {
    final userState = ref.watch(userStateProvider);

    final isCurrent = day == currentDay;
    final isPast = day < currentDay;
    final isFuture = day > currentDay;

    // Check if this day's missions are completed
    final isCompleted = userState.completedDays.contains(day);
    // Started (at least one challenge done) but not all three yet - shown
    // with a rose accent instead of the plain "untouched" styling.
    final isInProgress = !isCompleted && userState.inProgressDays.contains(day);
    // A past day with zero progress - the calendar day happened, but no
    // rituals were ever done for it. Shown distinctly from both a future
    // (locked) day and a completed one, instead of blending into either.
    final isMissed = isPast && !isCompleted && !isInProgress;

    // A day's rituals can only be done once it's current or past - future
    // days stay locked - but every day is tappable to see its info popup,
    // future ones just can't offer to start missions from there.
    final isClickable = !isFuture;

    const markerSize = 19.0;

    return Positioned(
      left: position.dx - markerSize / 2,
      top: position.dy - markerSize / 2,
      child: GestureDetector(
        onTap: () => _openZoomedMarker(fraction, day: day),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position marker
            Container(
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? WommiColors.cyan
                    : isCompleted
                        ? WommiColors.gold.withOpacity(0.85)
                        : isInProgress
                            ? WommiColors.roseSoft
                            : isMissed
                                ? WommiColors.inkDim.withOpacity(0.18)
                                : Colors.white.withOpacity(0.55),
                border: Border.all(
                  color: isCurrent
                      ? WommiColors.cyan
                      : isCompleted
                          ? WommiColors.gold
                          : isInProgress
                              ? WommiColors.rose
                              : isMissed
                                  ? WommiColors.inkDim.withOpacity(0.55)
                                  : WommiColors.line.withOpacity(0.5),
                  width: isCurrent || isInProgress ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCurrent ? WommiColors.cyan : Colors.black)
                        .withOpacity(isCurrent ? 0.4 : 0.15),
                    blurRadius: isCurrent ? 12 : 4,
                    spreadRadius: isCurrent ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isClickable
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: GoogleFonts.unbounded(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : isCompleted
                                      ? WommiColors.ink
                                      : WommiColors.inkDim,
                            ),
                          ),
                          if (isCompleted)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: WommiColors.gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (isInProgress)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: WommiColors.rose,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            )
                          else if (isMissed)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: WommiColors.inkDim,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Icon(
                        Icons.lock,
                        size: 10,
                        color: WommiColors.inkDim.withOpacity(0.5),
                      ),
              ),
            ),
            // Day label
            if (isCurrent) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: WommiColors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'YOU',
                  style: GoogleFonts.spaceMono(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tapping a day shows a summary of what's typically happening in the
  /// cycle on that day, and - if it isn't fully completed yet and isn't in
  /// the future - offers to open its rituals from there.
  Future<void> _showDayInfo(
    BuildContext context,
    int day, {
    required bool isCompleted,
    required bool isInProgress,
    required bool isCurrent,
    required bool isFuture,
  }) {
    final conceptionStatus = ref.read(onboardingProvider).conceptionStatus;
    return showDialog(
      context: context,
      builder: (context) => CycleDayInfoDialog(
        day: day,
        conceptionStatus: conceptionStatus,
        isCompleted: isCompleted,
        isInProgress: isInProgress,
        isCurrent: isCurrent,
        isFuture: isFuture,
        onOpenMissions: () {
          Navigator.pop(context);
          _openDayChallenges(context, day);
        },
      ),
    );
  }

  void _openDayChallenges(BuildContext context, int day) {
    // Same 3 daily missions/rituals as the Challenges tab, just scoped to
    // this specific day and pushed as its own screen with a back button.
    // Awards exactly 1 gem, same as any other day, only once all 3 are
    // complete.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChallengesScreen(day: day)),
    );
  }

  /// Same t/curve math as [_getPositionForDay], stopping short of the
  /// final size multiplication - used as the zoom's focal point, which
  /// needs a 0..1 fraction rather than a pixel offset.
  Offset _getFractionForDay(
    int day,
    int uterusStartDay,
    int uterusEndDay,
    Offset anchor,
  ) {
    // t=0 would put "pull" at its max (1.0) below, collapsing this day's
    // position onto the tube's last real marker (anchor) exactly - drawn
    // on top of it in the stack, that hid the tube day completely instead
    // of continuing the path forward from it (the reported "day 19 just
    // vanishes" bug). Numerating from 1 instead keeps the first uterus day
    // a step away from the anchor, while day uterusEndDay still lands on
    // t=1 as before.
    final individualDayCount = uterusEndDay - uterusStartDay + 1;
    final t = (day - uterusStartDay + 1) / individualDayCount;

    final baseY = 0.16 + t * 0.70;
    final baseX = 0.5 + 0.175 * math.sin(t * 2.2 * math.pi);

    final baseAtStart = Offset(0.5, 0.16);
    final pull = math.pow(1 - t, 3).toDouble().clamp(0.0, 1.0);
    final xFrac = baseX + (anchor.dx - baseAtStart.dx) * pull;
    final yFrac = baseY + (anchor.dy - baseAtStart.dy) * pull;

    return Offset(xFrac, yFrac);
  }

  /// Traces a winding S-curve down the river/stepping-stone path visible
  /// in the background illustration, starting where [uterusStartDay]'s
  /// marker should sit (right after the ovary/tube phases end) and ending
  /// near the bottom heart marker.
  Offset _getPositionForDay(
    int day,
    int uterusStartDay,
    int uterusEndDay,
    Offset anchor,
    Size size,
  ) {
    final fraction =
        _getFractionForDay(day, uterusStartDay, uterusEndDay, anchor);
    return Offset(fraction.dx * size.width, fraction.dy * size.height);
  }
}

/// Builds the same smoothed curve through a list of (already screen-scaled)
/// points, used both to draw the tube's connecting line and to place
/// markers evenly along it.
Path _buildSmoothTubePath(List<Offset> scaledPoints) {
  final path = Path()..moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
  for (int i = 0; i < scaledPoints.length - 1; i++) {
    final current = scaledPoints[i];
    final next = scaledPoints[i + 1];
    final mid = Offset(
      (current.dx + next.dx) / 2,
      (current.dy + next.dy) / 2,
    );
    path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
  }
  path.lineTo(scaledPoints.last.dx, scaledPoints.last.dy);
  return path;
}

/// Draws a soft line tracing the fallopian tube from the ovary node into
/// the uterus, smoothed through the given fractional points.
class _TubePathPainter extends CustomPainter {
  final List<Offset> points;

  _TubePathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final scaled = points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = _buildSmoothTubePath(scaled);

    final paint = Paint()
      ..color = WommiColors.rose.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TubePathPainter oldDelegate) => false;
}
