1️⃣ Módulo: Arquitectura + Setup + Auth + Navegación
You are an expert Flutter engineer and software architect, with experience in:
- Clean Architecture / Hexagonal Architecture
- Supabase (REST + Auth) as backend
- Flutter for mobile + web

CONTEXT
- I’m migrating an existing React + TypeScript + Supabase app (Team Sport Management) to Flutter.
- Backend & database are already implemented in Supabase (PostgreSQL) and MUST NOT be changed.
- Flutter app must target: Android, iOS and Web.
- Roles: super_admin, admin, coach, player.
- I prefer a clean / hexagonal architecture with domain, application, infrastructure and presentation layers.

DATABASE (AUTH SIDE, HIGH LEVEL)
- auth.users (managed by Supabase)
- public.profiles: id (UUID, FK → auth.users.id), role (super_admin | admin | coach | player), display_name, created_at, updated_at.
- public.user_team_roles: user_id, team_id, role ('coach' | 'admin'), created_at.
- Helper functions (used by RLS): is_superadmin(), is_coach_of_team(team_id BIGINT).

TASK
Design and implement the **core architecture + auth + navigation** of the Flutter app.

TASK 1 – ARCHITECTURE & PROJECT SETUP
1. Propose a clean/hexagonal folder structure under lib/, for example:

lib/
  core/          (errors, result types, constants)
  config/        (env, Supabase url/keys)
  theme/         (Material 3 theme, dark/light)
  localization/  (i18n ES/EN)
  domain/
    auth/
    profiles/
    org/         (sports, clubs, teams)
    ...
  application/
    auth/
    profiles/
    ...
  infrastructure/
    supabase/
    auth/
    profiles/
    ...
  presentation/
    app/         (main.dart, router, DI)
    widgets/
    auth/
    dashboard/
    ...

2. Choose and justify:
   - State management (Riverpod, Bloc, etc.) – pick ONE and stick to it.
   - Routing (e.g. go_router).
   - Supabase client (supabase_flutter vs generic http against PostgREST).
   - Localization (intl or similar).

3. Provide:
   - pubspec.yaml dependencies section.
   - Example of environment config (base URL, anon key) and how it’s injected.

TASK 2 – AUTH DOMAIN & REPOSITORIES
1. Define domain entities / value objects:
   - AuthUser (id, email).
   - UserProfile (userId, role, displayName).

2. Define repository interfaces in the domain layer:
   - AuthRepository:
     - Future<AuthUser> login(String email, String password)
     - Future<void> logout()
     - Future<AuthUser?> getCurrentUser()
   - ProfilesRepository:
     - Future<UserProfile> getCurrentUserProfile()

3. Implement infrastructure adapters using Supabase:
   - SupabaseAuthRepository implements AuthRepository.
   - SupabaseProfilesRepository implements ProfilesRepository.
   - Use supabase_flutter (or your chosen client) and map JSON to domain entities.

Provide concrete Dart code, with file names at the top of each snippet, e.g.:
// lib/domain/auth/auth_user.dart
// lib/domain/auth/auth_repository.dart
// lib/infrastructure/auth/supabase_auth_repository.dart
// lib/infrastructure/profiles/supabase_profiles_repository.dart

TASK 3 – AUTH STATE & ROLE-BASED NAVIGATION
1. Implement an AuthController/AuthNotifier using the chosen state management tool with states:
   - unauthenticated
   - loading
   - authenticated(user: AuthUser, profile: UserProfile)
   - error(message)

2. Router setup (for go_router or chosen router):
   - /login
   - /dashboard
   - /matches
   - /trainings
   - /championship
   - /evaluations
   - /notes
   - /profile

   On app start:
   - If no Supabase session → go to /login.
   - If there is a session → fetch profile and go to /dashboard.

3. Create:
   - LoginPage:
     - Email + password fields
     - “Login” button that calls AuthController.login
     - Shows loading/error states
   - AppScaffold:
     - For logged-in users: a layout with:
       - For web: left navigation rail with items (Dashboard, Partidos, Entrenamiento, Campeonato, Mis Evaluaciones, Notes, Profile, Logout).
       - For mobile: bottom navigation bar or drawer.
       - Dark/light theme toggle button.
     - Role-based filtering:
       - super_admin: can see all admin/super admin sections.
       - admin, coach: see management sections limited to their club/teams (we’ll implement later).
       - player: hide admin/coach items; show only player-facing items.

Provide full Dart code for:
- main.dart (initialization, Supabase client, router)
- app_router.dart (or routes.dart)
- auth_controller.dart / auth_notifier.dart
- presentation/auth/login_page.dart
- presentation/app/app_scaffold.dart

Use null-safety, idiomatic Dart, and keep domain/application/infrastructure/presentation layers clearly separated.
Start by describing the folder structure and dependencies, then implement the auth flow end to end.

2️⃣ Módulo: Organización + Usuarios (Sports/Clubs/Teams/Players/Invites)
You are the same expert Flutter + Supabase engineer as before.

CONTEXT
- Flutter app using clean/hexagonal architecture is already set up.
- Auth + profiles + basic role-based navigation are implemented (login, session, profile with role).
- I now want to implement the **organizational and user management module**:
  - Sports
  - Clubs
  - Teams
  - Players
  - User-team roles
  - Pending invites

DATABASE (ORG & USERS)
Relevant tables:

- sports (id, name, created_at)
- clubs (id, sport_id, name, created_at)
- teams (id, club_id, name, created_at)
- user_team_roles (id, user_id, team_id, role 'coach' | 'admin', created_at)
- players (id, team_id, optional user_id, full_name, jersey_number, position_id, created_at)
- positions (id, sport_id, name, abbreviation, field_zone, created_at)
- pending_invites (id UUID, email, team_id, role, player_name, jersey_number,
  invited_by, invite_token, accepted, created_at, expires_at)

Roles:
- super_admin: can manage sports/clubs/teams globally.
- admin: can manage teams, coaches, players within their club.
- coach: can manage players in their teams.
- player: read-only.

TASK 1 – DOMAIN & REPOSITORIES
1. Define or refine domain entities for:
   - Sport
   - Club
   - Team
   - UserTeamRole
   - Player
   - Position
   - PendingInvite

2. Define repository interfaces in the domain/application layer:
   - SportsRepository: list/create/update/delete sports (for super_admin).
   - ClubsRepository: list clubs by sport, CRUD (super_admin/admin).
   - TeamsRepository: list teams by club, CRUD.
   - PlayersRepository: list players by team, CRUD.
   - UserTeamRolesRepository: assign/unassign coaches/admins to teams.
   - PendingInvitesRepository: create/list/mark accepted invites.

3. Implement Supabase-based repositories in infrastructure layer, using REST or supabase client.

Provide concrete Dart code for:
- lib/domain/org/entities/*.dart
- lib/domain/org/repositories/*.dart
- lib/infrastructure/org/supabase_*.dart

TASK 2 – SUPER ADMIN & ADMIN UI SCREENS
Implement the following presentation-layer screens + logic:

1. SuperAdminSportsPage:
   - Shows list of sports with actions: create, edit, delete.
   - Simple form dialog for create/edit (name).

2. SuperAdminClubsPage:
   - For a selected sport, show list of clubs.
   - CRUD operations with simple forms.

3. AdminTeamsPage:
   - For the current admin (based on profile and user_team_roles), show their club(s).
   - For a selected club, show list of teams with CRUD support.

4. TeamPlayersPage:
   - For a given team:
     - List players: full_name, jersey_number, position (from positions table).
     - Actions: create player, edit player, delete player.
     - When creating a player, optionally set jersey_number and position (dropdown from positions table).

TASK 3 – INVITATION FLOW
Goal: allow admin/coach to invite players and staff.

1. For role 'player':
   - UI: “Invite Player” button on TeamPlayersPage.
   - Dialog asks: email, full_name, jersey_number (optional).
   - Insert a row into pending_invites with:
     - email
     - team_id
     - role = 'player'
     - player_name = full_name
     - jersey_number
     - invited_by = current user id
     - expires_at = now + 7 days (or configurable)

2. For role 'coach' or 'admin':
   - Similar “Invite Staff” UI on team/club admin screen.
   - Fields: email, role ('coach'|'admin'), optional team_id.
   - Insert into pending_invites.

3. Assume there is already a backend process (function or edge function) that:
   - Sends an email with invite_token.
   - On sign up + set password, links the auth user with pending_invites to create user_team_roles or players.

4. Implement a SetPasswordPage (web/mobile) which:
   - Receives a token parameter (e.g. from a deep link / route parameter).
   - Lets the user set a password.
   - Calls Supabase auth to complete the signup and relies on backend triggers to apply the invite.

Provide:
- UI and controller code for “Invite Player” and “Invite Staff” flows.
- Repository methods to insert into pending_invites.
- Basic SetPasswordPage with form and call to Supabase.

Follow the existing architecture: domain/application/infrastructure/presentation, Riverpod/Bloc, go_router, etc.

3️⃣ Módulo: Partidos, Convocatorias, Minutos, Cambios, Goles
You are the same expert Flutter + Supabase engineer.

CONTEXT
- Core architecture, auth and org modules are implemented.
- Now we focus on the **Matches module**, which is the most complex UX part.

BUSINESS FUNCTIONALITY (from existing app)
- CRUD of matches (opponent, date, location, notes).
- Convocatoria (match_call_ups): select which players are called up for a given match.
- Rule: at least 7 players must be called up before managing minutes/lineups.
- A unified “Match Lineup and Results” page with:
  - Left side: pitch/field view + bench with drag & drop or tap interactions:
    - Drag/tap players from bench to field to mark them as FULL for a quarter.
    - Drag/tap from field to bench with “substitution mode” to record HALF for each of the two players.
    - Max 7 players on the field simultaneously.
    - Players can be repositioned freely on the pitch.
  - Right side:
    - Table of minutes per player & quarter (Q1–Q4) using FULL/HALF fractions.
    - Quarter selector.
    - Form to register goals and assists per quarter.
    - Form to register score per quarter (team_goals, opponent_goals).
- Validation rule: every called-up player must play at least 2 quarters (2.0). There is a Supabase function validate_match_minimum_periods(match_id) that returns players that fail this rule.

DATABASE TABLES (MATCHES)
- matches (id, team_id, opponent, match_date, location, notes, created_at)
- match_call_ups (match_id, player_id, created_at)
- match_player_periods (match_id, player_id, period 1-4, fraction ENUM('FULL','HALF'))
- match_substitutions (id, match_id, period 1-4, player_out, player_in, created_at)
- match_quarter_results (id, match_id, quarter 1-4, team_goals, opponent_goals, created_at, updated_at)
- match_goals (id, match_id, quarter 1-4, scorer_id, assister_id, created_at)
- view: match_call_ups_with_periods (match_id, player_id, called_up_at, periods_played)
- function: validate_match_minimum_periods(match_id BIGINT)
  - returns: player_id, full_name, periods_played for players with < 2 periods.

TASK 1 – DOMAIN MODEL & REPOSITORIES
1. Define or refine domain entities:
   - Match
   - MatchCallUp
   - MatchPlayerPeriod (for a single quarter)
   - MatchSubstitution
   - MatchQuarterResult
   - MatchGoal
   - MatchLineupState (aggregate for UI use: fieldPlayers, benchPlayers, quarter, etc.)

2. Define repository interfaces:
   - MatchesRepository: list matches by team, create/update/delete, getMatchById.
   - MatchCallUpsRepository: list call-ups by match, add/remove players.
   - MatchPlayerPeriodsRepository: get/set participation per player & quarter.
   - MatchSubstitutionsRepository: list/create/delete substitutions.
   - MatchQuarterResultsRepository: get/set quarter results.
   - MatchGoalsRepository: list/create/delete goals.
   - MatchValidationRepository:
     - callValidateMinimumPeriods(matchId): returns list of players that fail the min 2 periods rule.

3. Implement Supabase repositories in the infrastructure layer.

TASK 2 – MATCHES LIST & EDITOR
1. Implement MatchesListPage:
   - Filter by current team.
   - Show list with opponent, date, result summary if available (we will get the final score from quarter results).
   - Actions: create, edit, delete, go to “Lineup & Results”.

2. Implement MatchEditorPage:
   - Form for opponent, match_date, location, notes.
   - Used for create and edit.

TASK 3 – CONVOCATORIA UI
1. On MatchLineupAndResultsPage, include a “Convocatoria” dialog or sub-page:
   - Shows list of team players with checkboxes.
   - Allows selecting/deselecting players to call up.
   - Enforces that at least 7 players are selected. If less than 7, show red warning and disable lineup controls.

2. Use match_call_ups table via MatchCallUpsRepository.

TASK 4 – MATCH LINEUP & MINUTES UI
1. Design the state model for the lineup for a given quarter:
   - For the selected quarter Q1–Q4:
     - fieldPlayers: list of players on field with their position (from positions table) and fraction (FULL or HALF).
     - benchPlayers: list of remaining called-up players.
     - substitutions: list for that quarter.

2. Implement MatchLineupAndResultsPage:
   - Left area:
     - Pitch widget with 7 slots and draggable/tappable player tokens.
     - Bench list at the bottom or side.
     - Buttons:
       - “Change mode” toggle (substitution mode).
       - “Reset quarter lineup” if necessary.

   - Behavior:
     - When you move a player from bench to field:
       - If not in change mode: create or update match_player_periods to FULL for that player and quarter.
       - Show dialog to choose position (list from positions table).
     - In change mode:
       - Tap/click player on field (player_out) and player on bench (player_in) → create substitution record:
         - Insert into match_substitutions (match_id, period, player_out, player_in).
         - Set both players’ fraction to HALF in match_player_periods for that quarter.
     - Removing a player from field to bench outside change mode:
       - Can clear their period record or mark HALF depending on your chosen UX; explain and implement one clear behavior.

3. Right area:
   - Quarter selector (Q1–Q4).
   - Table of minutes:
     - Rows: called-up players.
     - Columns: Q1, Q2, Q3, Q4 with values: FULL, HALF, or empty.
   - At bottom: a section for quarter results and goals (Task 5).

TASK 5 – QUARTER RESULTS & GOALS
1. Quarter results:
   - For selected quarter, form with:
     - team_goals (int)
     - opponent_goals (int)
   - Save to match_quarter_results (insert or update).

2. Goals & assists:
   - List of existing goals for current quarter (scorer, assister).
   - Button “Add goal” opens dialog:
     - scorer: select from called-up players.
     - assister (optional): select from called-up players or “None”.
   - Save to match_goals.

TASK 6 – VALIDATIONS & WARNINGS
1. After saving lineups and player periods, provide a button:
   - “Validate minimum 2 quarters per player”.
   - This calls Supabase function validate_match_minimum_periods(match_id).
   - If any player fails the rule, show:
     - red banner with message
     - list of players with their periods_played.

2. On Convocatoria step, if < 7 players selected:
   - Show red warning and disable quarter selector and lineup controls.

DELIVERABLES
- Domain entities + repositories (interfaces + Supabase implementations).
- MatchesListPage + MatchEditorPage.
- MatchLineupAndResultsPage with:
  - Convocatoria UI
  - Lineup/bench/substitution logic
  - Quarter results + goals form
  - Validation integration.

Provide concrete Dart code snippets with file names and respect the existing clean architecture structure.
If drag & drop is too verbose, you may implement tap-based selection but keep widgets modular for future evolution.

4️⃣ Módulo: Entrenamientos y Asistencia
You are the same expert Flutter + Supabase engineer.

CONTEXT
- Auth, org, and matches modules are implemented.
- Now we implement **trainings + attendance**.

DATABASE TABLES (TRAININGS)
- training_sessions (id, team_id, session_date, notes, created_at)
- training_attendance (training_id, player_id, status ENUM('on_time','late','absent'))

BUSINESS FUNCTIONALITY
- Coaches/admins can:
  - Create training sessions for a team (date + optional notes).
  - See a list of training sessions per team.
  - For each session, mark attendance status per player:
    - on_time
    - late
    - absent

TASK 1 – DOMAIN & REPOSITORIES
1. Define domain entities:
   - TrainingSession
   - TrainingAttendanceRecord (trainingId, playerId, status)

2. Define repository interfaces:
   - TrainingSessionsRepository:
     - listByTeam(teamId)
     - create/update/delete
   - TrainingAttendanceRepository:
     - getAttendance(trainingId)
     - setAttendance(trainingId, playerId, status)

3. Implement Supabase repositories using REST/Supabase client.

TASK 2 – UI SCREENS
1. TrainingSessionsListPage:
   - For a given team, show list of sessions ordered by date (future + past).
   - Actions:
     - Create training session (date picker + notes).
     - Edit notes or date.
     - Delete session.
     - Navigate to “Attendance” for a specific session.

2. TrainingSessionDetailPage (Attendance):
   - Shows list of players in the team (name, jersey number).
   - For each player, show a 3-state selector or segmented control:
     - On Time
     - Late
     - Absent
   - Fetch current attendance from training_attendance and allow updates.
   - Save changes via repository on user interaction or on “Save” button.

3. Make UI mobile-friendly but also usable on web (table layout is fine on web).

DELIVERABLES
- Domain classes + repositories.
- TrainingSessionsListPage.
- TrainingSessionDetailPage with attendance editing.

Provide Dart code snippets with file names following the existing architecture.

5️⃣ Módulo: Estadísticas + Campeonato
You are the same expert Flutter + Supabase engineer.

CONTEXT
- Core, matches and trainings modules are implemented.
- We now implement **Statistics** and **Championship** views.

DATABASE (STATS-RELATED)
- View: player_statistics
  - player_id, team_id, full_name, jersey_number,
  - total_trainings, trainings_attended, training_attendance_pct,
  - total_matches, matches_called_up, match_attendance_pct,
  - avg_periods_played.
- Function: get_team_player_statistics(team_id BIGINT)
  - returns same columns as player_statistics filtered by team.
- Matches + match_quarter_results + match_goals are already used in matches module.

BUSINESS FUNCTIONALITY (from existing app)
- Statistics page (/estadisticas) with tabs:
  - Players:
    - Show attendance %, avg periods played, etc.
  - Goals:
    - Ranking of goal scorers and assisters.
  - Matches:
    - List of matches with final results.
  - Quarters:
    - Performance by quarter (goals for/against, W-D-L by quarter).
  - Formations:
    - Effectiveness by formation (this can be simplified if needed).
  - Training attendance:
    - Ranking by training_attendance with colors:
      - green ≥ 90%
      - grey ≥ 75%
      - red < 75%.
- Championship page (/campeonato):
  - Table of matches with final result and W/D/L indicators.
  - Filter by team.
  - Ability to open details dialog showing results per quarter and goals per quarter.

TASK 1 – DOMAIN & STATS REPOSITORY
1. Define domain entity:
   - PlayerStatistics (mapping from player_statistics view).
2. Define StatsRepository with methods:
   - Future<List<PlayerStatistics>> getTeamPlayerStatistics(teamId)
     - either call get_team_player_statistics(teamId) or select from player_statistics.
   - Methods to compute:
     - scorers ranking (from match_goals grouped by scorer_id).
     - assisters ranking (from match_goals grouped by assister_id).
     - match results summary (W/D/L and goals for/against) from matches + match_quarter_results.
     - performance by quarter (for each quarter: goals for/against, W/D/L).
   - You can compute some of these client-side using data from match_quarter_results & match_goals, or use RPCs if you prefer (but please outline your approach).

Implement Supabase-based StatsRepository in infrastructure layer.

TASK 2 – STATISTICS PAGE UI
Implement StatisticsPage with:
- Team selector (for coach/admin; for player, automatically select his team).
- Tabs:
  1) Players tab:
     - Table/list of PlayerStatistics with:
       - full_name, jersey_number
       - training_attendance_pct
       - match_attendance_pct
       - avg_periods_played
     - Apply color coding for attendance similar to:
       - green ≥ 90%
       - grey ≥ 75%
       - red < 75%.
  2) Goals tab:
     - Two rankings:
       - Top scorers
       - Top assisters
     - Show small stats per player (goals, assists).
  3) Matches tab:
     - List of matches with final result, W/D/L indicator.
  4) Quarters tab:
     - Summary per quarter: goals for, goals against, W/D/L for that quarter.
  5) Training attendance tab:
     - Reuse player_statistics to show ranking by training_attendance_pct.

Use a tabbed layout appropriate for mobile + web.

TASK 3 – CHAMPIONSHIP PAGE UI
Implement ChampionshipPage:
- Team selector (if needed).
- Table of matches with:
  - opponent, match_date
  - final result (e.g. 3–1)
  - W (win), D (draw), L (loss) indicator using colors.
- “Details” button for each match:
  - Opens dialog/page showing:
    - Per-quarter scores (team_goals vs opponent_goals).
    - List of goals per quarter (scorer, assister).

DELIVERABLES
- Domain entity PlayerStatistics.
- StatsRepository interface + Supabase implementation.
- StatisticsPage with tabs.
- ChampionshipPage with details view.

Provide Dart code snippets with file names following the existing architecture.

6️⃣ Módulo: Evaluaciones de Jugadores
You are the same expert Flutter + Supabase engineer.

CONTEXT
- We now implement the **player evaluations** module.

DATABASE (EVALUATIONS)
- evaluation_categories (id UUID, name, description, order_index, created_at)
- evaluation_criteria (id UUID, category_id, name, description, max_score, order_index, evaluation_method, example_video_url, created_at)
- player_evaluations (id UUID, player_id, coach_id, evaluation_date, notes, created_at, updated_at)
- evaluation_scores (id UUID, evaluation_id, criterion_id, score, notes, example_video_url, created_at, UNIQUE(evaluation_id, criterion_id))

BUSINESS FUNCTIONALITY
- Coaches can:
  - Create a new evaluation for a player.
  - For each category (e.g., Coordination, Technique, Decision making, Attitude, etc.) and its criteria, assign a score 0–10 and notes.
- Players can:
  - See their latest evaluation with a radar chart summarizing categories.
  - See a history of evaluations and optional progress over time.

TASK 1 – DOMAIN & REPOSITORIES
1. Define domain entities:
   - EvaluationCategory
   - EvaluationCriterion
   - PlayerEvaluation
   - EvaluationScore
   - PlayerEvaluationSummary (aggregate for UI).

2. Define repositories:
   - EvaluationCategoriesRepository:
     - listCategories()
     - listCriteriaByCategory(categoryId)
   - PlayerEvaluationsRepository:
     - listEvaluationsByPlayer(playerId)
     - getEvaluationById(evaluationId)
     - createEvaluation(playerId, evaluationDate, notes, Map<criterionId, score/notes>)
   - EvaluationScoresRepository:
     - mainly used internally by PlayerEvaluationsRepository to persist scores.

Implement Supabase-based repositories.

TASK 2 – COACH EVALUATION UI
Implement CoachEvaluationsPage with flows:

1. Select player:
   - Show list of players in coach’s teams.
   - When selecting a player, show:
     - Button “New Evaluation”.
     - List of previous evaluations (date + brief summary).

2. NewEvaluationPage:
   - Load evaluation_categories and evaluation_criteria grouped by category.
   - For each criterion:
     - Slider or input 0–10 for score.
     - Optional notes text field.
   - At the bottom:
     - General notes.
     - Save button → calls PlayerEvaluationsRepository.createEvaluation.

3. After saving:
   - Return to CoachEvaluationsPage and show new evaluation in history.

TASK 3 – PLAYER-FACING EVALUATIONS UI
Implement PlayerEvaluationsPage (for role player):

1. Latest evaluation:
   - Load the most recent evaluation for the current player.
   - Aggregate scores per category (e.g., average of criteria scores per category).
   - Display them in a radar/spider chart.
     - Use a chart package compatible with Flutter or custom painter if needed.
   - Show general notes.

2. History:
   - List previous evaluations.
   - For each, show date + small summary per category (or a mini chart).

3. Optionally:
   - Show progress indicators (e.g., arrows up/down per category compared to previous evaluation).

DELIVERABLES
- Domain entities and repositories.
- CoachEvaluationsPage, NewEvaluationPage.
- PlayerEvaluationsPage with radar chart.

Provide Dart code snippets with file names following the existing architecture and using the same state management and routing already chosen.

7️⃣ Módulo: Cross-cutting (Tema, i18n, errores) + Roadmap
You are the same expert Flutter + Supabase engineer.

CONTEXT
- The previous modules define major features.
- Now focus on cross-cutting concerns and a migration roadmap.

TASK 1 – THEME (DARK/LIGHT) FOR SPORTS APP
1. Implement Material 3 theming with:
   - Dark theme as default.
   - Light theme as alternative.
   - Color palette suitable for sports analytics (dark backgrounds, bright accent color).
2. Provide:
   - theme/app_theme.dart with ThemeData for light and dark.
   - ThemeController/ThemeNotifier to toggle between themes.
   - Integration with AppScaffold: theme toggle button stored in local preferences.

TASK 2 – LOCALIZATION (ES/EN)
1. Implement localization using intl (or similar):
   - Generate ARB (or JSON) files for at least ES and EN.
   - Include common keys: menu items, buttons, validation messages.
2. Provide:
   - localization/app_localizations.dart (or equivalent).
   - Integration into main.dart and widgets.
   - Example of a language selector (e.g., in AppScaffold header) and storing the chosen language.

TASK 3 – ERROR HANDLING & LOADING
1. In core/ define:
   - A Result<E, T> or Either type to handle success/error.
   - Common AppError type (e.g., networkError, unauthorized, validationError).
2. Show:
   - How repositories return Result<AppError, DomainType>.
   - How controllers/notifiers expose loading/error states.
   - How UI shows:
     - Progress indicators while loading.
     - Snackbars or dialogs for errors.

TASK 4 – TESTING EXAMPLES
1. Provide examples of:
   - Unit test for a repository (mocking Supabase client, testing mapping and error handling).
   - Widget test for:
     - LoginPage (successful login + error case).
     - A simple statistics widget (e.g., players table with colored attendance).

TASK 5 – MIGRATION ROADMAP
1. Based on all modules, propose a practical migration roadmap from the existing React app to Flutter, in phases. Example:
   - Phase 1: Architecture, auth, basic dashboard.
   - Phase 2: Org & user management.
   - Phase 3: Matches core features.
   - Phase 4: Trainings.
   - Phase 5: Statistics and championship.
   - Phase 6: Evaluations.
   - Phase 7: Polishing, theming, i18n, tests.
2. For each phase:
   - List which screens/repositories must be completed.
   - Define acceptance criteria.

DELIVERABLES
- theme/app_theme.dart and ThemeController.
- i18n setup with example strings.
- Result/AppError pattern.
- One repository test and one widget test example.
- Detailed migration roadmap.

Provide Dart code snippets with file names and short explanations for each part.
