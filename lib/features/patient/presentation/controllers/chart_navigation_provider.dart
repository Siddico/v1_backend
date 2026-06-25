import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the active/expanded chart section on the Patient Charts tab.
/// Can be set from the home dashboard cards to auto-expand a section upon navigation.
final activeChartSectionProvider = StateProvider<String?>((ref) => null);
