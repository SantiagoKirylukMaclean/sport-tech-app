// lib/application/notes/notes_count_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/notes/notes_notifier.dart';
import 'package:sport_tech_app/application/notes/notes_state.dart';

/// Provider for counting total notes
final notesCountProvider = Provider<int>((ref) {
  final notesState = ref.watch(notesNotifierProvider);

  if (notesState is NotesStateLoaded) {
    return notesState.notes.length;
  }

  return 0;
});
