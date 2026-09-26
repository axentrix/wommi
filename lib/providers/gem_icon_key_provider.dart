import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A stable handle onto the header's gem-count icon (see AppHeaderBar) so a
/// reward popup elsewhere in the tree - which has no direct reference to the
/// header - can still find its exact on-screen position and animate an
/// earned gem flying there (see WinStateDialog/showFlyingGem).
final gemIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());
