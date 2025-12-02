// lib/infrastructure/notes/providers/notes_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/domain/notes/repositories/notes_repository.dart';
import 'package:sport_tech_app/infrastructure/notes/supabase_notes_repository.dart';

/// Provider for notes repository
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseNotesRepository(supabaseClient);
});
