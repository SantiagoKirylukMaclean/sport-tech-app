// lib/infrastructure/org/providers/org_repositories_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/domain/org/repositories/clubs_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/pending_invites_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/positions_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/sports_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/teams_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/user_team_roles_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_members_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_attendance_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_clubs_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_pending_invites_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_players_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_positions_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_sports_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_teams_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_user_team_roles_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_staff_members_repository.dart';
import 'package:sport_tech_app/infrastructure/org/supabase_staff_attendance_repository.dart';

/// Provider for Sports Repository
final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSportsRepository(client);
});

/// Provider for Clubs Repository
final clubsRepositoryProvider = Provider<ClubsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseClubsRepository(client);
});

/// Provider for Teams Repository
final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTeamsRepository(client);
});

/// Provider for Players Repository
final playersRepositoryProvider = Provider<PlayersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePlayersRepository(client);
});

/// Provider for Positions Repository
final positionsRepositoryProvider = Provider<PositionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePositionsRepository(client);
});

/// Provider for User Team Roles Repository
final userTeamRolesRepositoryProvider = Provider<UserTeamRolesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseUserTeamRolesRepository(client);
});

/// Provider for Pending Invites Repository
final pendingInvitesRepositoryProvider = Provider<PendingInvitesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePendingInvitesRepository(client);
});

/// Provider for Staff Members Repository
final staffMembersRepositoryProvider = Provider<StaffMembersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStaffMembersRepository(client);
});

/// Provider for Staff Attendance Repository
final staffAttendanceRepositoryProvider = Provider<StaffAttendanceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStaffAttendanceRepository(client);
});
