# Plan de Implementación: Sport Tech Flutter App

## Estado Actual

**✅ COMPLETADO:**
- Módulo 1: Arquitectura + Setup + Auth + Navegación (100%)
- Módulo 2: Organización + Usuarios (Sports/Clubs/Teams/Players/Invites) (100%)
- Módulo 3: Partidos, Convocatorias, Minutos, Cambios, Goles (100%)
- **Módulo 4: Entrenamientos y Asistencia (100%)**

**⚠️ PENDIENTE:**
- Módulo 5: Estadísticas + Campeonato
- Módulo 6: Evaluaciones de Jugadores
- Módulo 7: Cross-cutting (i18n completo, testing)

---

## FASE 1: Completar Cross-Cutting Concerns (Módulo 7)

### Sprint 1.1: Localization (i18n ES/EN)
**Objetivo:** Completar sistema de traducción ES/EN

**Tareas:**
1. **Task 1.1.1: Crear archivos ARB para ES/EN** [1h]
   - Crear `lib/l10n/app_es.arb` con traducciones en español
   - Crear `lib/l10n/app_en.arb` con traducciones en inglés
   - Incluir keys para: menús, botones, mensajes de error, labels
   - Test: Ejecutar `flutter gen-l10n` y verificar generación
   - Commit: "feat: add ES/EN ARB files for localization"

2. **Task 1.1.2: Integrar AppLocalizations en la app** [30min]
   - Descomentar configuración en `main.dart`
   - Agregar `localizationsDelegates` y `supportedLocales`
   - Test: Hot reload y verificar que no hay errores
   - Commit: "feat: integrate AppLocalizations in MaterialApp"

3. **Task 1.1.3: Agregar selector de idioma** [1h]
   - Crear `LocaleNotifier` en `application/locale/`
   - Agregar botón de idioma en `AppScaffold`
   - Persistir selección en SharedPreferences
   - Test: Cambiar idioma y verificar persistencia al reiniciar
   - Commit: "feat: add language selector with persistence"

4. **Task 1.1.4: Reemplazar strings hardcoded con traducciones** [2h]
   - Actualizar `LoginPage` con `context.l10n`
   - Actualizar menús de navegación
   - Actualizar formularios de org (Sports, Clubs, Teams, Players)
   - Test: Verificar ambos idiomas en cada pantalla
   - Commit: "feat: replace hardcoded strings with i18n"

### Sprint 1.2: Testing Setup
**Objetivo:** Establecer base de testing

**Tareas:**
5. **Task 1.2.1: Tests unitarios para repositorios** [2h]
   - Crear `test/infrastructure/auth/supabase_auth_repository_test.dart`
   - Mock SupabaseClient
   - Test casos: login success, login failure, signOut
   - Crear `test/infrastructure/profiles/supabase_profiles_repository_test.dart`
   - Test casos: getCurrentUserProfile success/failure
   - Test: `flutter test`
   - Commit: "test: add unit tests for auth repositories"

6. **Task 1.2.2: Widget tests para LoginPage** [1.5h]
   - Crear `test/presentation/auth/login_page_test.dart`
   - Test: renderizado de campos
   - Test: validación de formulario
   - Test: login exitoso
   - Test: manejo de errores
   - Test: `flutter test`
   - Commit: "test: add widget tests for LoginPage"

7. **Task 1.2.3: Widget tests para AppScaffold** [1h]
   - Crear `test/presentation/app/scaffold/app_scaffold_test.dart`
   - Test: navegación por rol (super_admin, admin, coach, player)
   - Test: mostrar/ocultar menús según rol
   - Test: `flutter test`
   - Commit: "test: add widget tests for AppScaffold"

### Sprint 1.3: Notes Page
**Objetivo:** Implementar página de notas básica

**Tareas:**
8. **Task 1.3.1: Implementar NotesPage funcional** [2h]
   - Diseñar schema simple: `notes (id, user_id, content, created_at)`
   - Crear domain entities y repository
   - Implementar SupabaseNotesRepository
   - Crear NotesNotifier
   - Crear UI: lista de notas + formulario crear/editar
   - Test: Crear, editar, eliminar notas
   - Commit: "feat: implement notes module"

**Git Tag:** `v0.3.0-cross-cutting-complete`

---

## FASE 2: Módulo 3 - Partidos (Matches)

### Sprint 2.1: Domain & Infrastructure Base
**Objetivo:** Crear entidades y repositorios base

**Tareas:**
9. **Task 2.1.1: Domain entities para Matches** [2h]
   - Crear `domain/matches/entities/match.dart`
   - Crear `domain/matches/entities/match_call_up.dart`
   - Crear `domain/matches/entities/match_player_period.dart` (con enum Fraction)
   - Crear `domain/matches/entities/match_substitution.dart`
   - Crear `domain/matches/entities/match_quarter_result.dart`
   - Crear `domain/matches/entities/match_goal.dart`
   - Test: Verificar entidades con Equatable
   - Commit: "feat(matches): add domain entities"

10. **Task 2.1.2: Repository interfaces** [1.5h]
    - Crear `domain/matches/repositories/matches_repository.dart`
    - Crear `domain/matches/repositories/match_call_ups_repository.dart`
    - Crear `domain/matches/repositories/match_player_periods_repository.dart`
    - Crear `domain/matches/repositories/match_substitutions_repository.dart`
    - Crear `domain/matches/repositories/match_quarter_results_repository.dart`
    - Crear `domain/matches/repositories/match_goals_repository.dart`
    - Crear `domain/matches/repositories/match_validation_repository.dart`
    - Commit: "feat(matches): add repository interfaces"

11. **Task 2.1.3: Supabase repositories - Part 1 (Basic CRUD)** [3h]
    - Implementar `SupabaseMatchesRepository` (CRUD + getByTeam)
    - Crear mappers en `infrastructure/matches/mappers/`
    - Test manual: Crear, listar, editar, eliminar partidos
    - Commit: "feat(matches): implement matches repository"

12. **Task 2.1.4: Supabase repositories - Part 2 (Call-ups)** [2h]
    - Implementar `SupabaseMatchCallUpsRepository`
    - Métodos: listByMatch, addPlayer, removePlayer
    - Test manual: Agregar/quitar jugadores de convocatoria
    - Commit: "feat(matches): implement call-ups repository"

13. **Task 2.1.5: Supabase repositories - Part 3 (Periods & Substitutions)** [3h]
    - Implementar `SupabaseMatchPlayerPeriodsRepository`
    - Implementar `SupabaseMatchSubstitutionsRepository`
    - Test manual: Registrar periodos y cambios
    - Commit: "feat(matches): implement periods and substitutions repositories"

14. **Task 2.1.6: Supabase repositories - Part 4 (Results & Goals)** [2h]
    - Implementar `SupabaseMatchQuarterResultsRepository`
    - Implementar `SupabaseMatchGoalsRepository`
    - Test manual: Registrar resultados por cuarto y goles
    - Commit: "feat(matches): implement results and goals repositories"

15. **Task 2.1.7: Match validation repository** [1h]
    - Implementar `SupabaseMatchValidationRepository`
    - Llamar función RPC `validate_match_minimum_periods(match_id)`
    - Test manual: Validar regla de 2 cuartos mínimos
    - Commit: "feat(matches): implement match validation"

### Sprint 2.2: State Management
**Objetivo:** Crear notifiers Riverpod

**Tareas:**
16. **Task 2.2.1: Matches state management** [2h]
    - Crear `MatchesNotifier` en `application/matches/`
    - Estados: loading, loaded, error
    - Métodos: loadMatches, createMatch, updateMatch, deleteMatch
    - Providers en `application/matches/matches_providers.dart`
    - Commit: "feat(matches): add matches state management"

17. **Task 2.2.2: Match lineup state management** [3h]
    - Crear `MatchLineupNotifier` para gestionar estado del lineup
    - Estados: fieldPlayers, benchPlayers, currentQuarter, substitutionMode
    - Métodos: selectQuarter, toggleSubstitutionMode, movePlayerToField, etc.
    - Commit: "feat(matches): add lineup state management"

### Sprint 2.3: UI - Matches List & Editor
**Objetivo:** CRUD básico de partidos

**Tareas:**
18. **Task 2.3.1: Reemplazar MatchesPage placeholder** [2h]
    - Eliminar placeholder de `presentation/matches/pages/matches_page.dart`
    - Mostrar lista de partidos del equipo seleccionado
    - Mostrar: oponente, fecha, resultado (calculado de quarters)
    - FAB para crear nuevo partido
    - Test: Navegar y ver lista
    - Commit: "feat(matches): implement matches list page"

19. **Task 2.3.2: Match editor form** [2h]
    - Crear `presentation/matches/widgets/match_form_dialog.dart`
    - Campos: opponent, match_date (DatePicker), location, notes
    - Validación
    - Test: Crear y editar partido
    - Commit: "feat(matches): add match editor form"

20. **Task 2.3.3: Navegación a lineup page** [30min]
    - Agregar botón "Gestionar Lineup" en cada partido
    - Crear ruta `/matches/:matchId/lineup`
    - Test: Navegar a página (mostrar "en construcción" temporalmente)
    - Commit: "feat(matches): add navigation to lineup page"

### Sprint 2.4: UI - Convocatoria
**Objetivo:** Gestión de jugadores convocados

**Tareas:**
21. **Task 2.4.1: Convocatoria dialog** [3h]
    - Crear `presentation/matches/widgets/convocatoria_dialog.dart`
    - Listar jugadores del equipo con checkboxes
    - Guardar/remover call-ups
    - Validación: mínimo 7 jugadores
    - Warning rojo si <7 jugadores
    - Test: Seleccionar jugadores y guardar
    - Commit: "feat(matches): implement convocatoria dialog"

22. **Task 2.4.2: Integrar convocatoria en MatchLineupPage** [1h]
    - Crear esqueleto de `MatchLineupAndResultsPage`
    - Agregar botón "Gestionar Convocatoria"
    - Deshabilitar controles si <7 jugadores convocados
    - Test: Abrir convocatoria, verificar validación
    - Commit: "feat(matches): integrate convocatoria in lineup page"

### Sprint 2.5: UI - Match Lineup (Drag & Drop)
**Objetivo:** Gestión de alineación por cuarto

**Tareas:**
23. **Task 2.5.1: Quarter selector** [1h]
    - Agregar selector Q1-Q4 en MatchLineupPage
    - Cargar datos del cuarto seleccionado
    - Test: Cambiar entre cuartos
    - Commit: "feat(matches): add quarter selector"

24. **Task 2.5.2: Pitch widget (básico)** [3h]
    - Crear `presentation/matches/widgets/pitch_widget.dart`
    - Layout con 7 slots para jugadores en cancha
    - Mostrar jugadores con posición (draggable o tappable)
    - Versión inicial: tap-based en lugar de drag & drop (más simple)
    - Test: Ver jugadores en cancha
    - Commit: "feat(matches): add basic pitch widget"

25. **Task 2.5.3: Bench widget** [2h]
    - Crear `presentation/matches/widgets/bench_widget.dart`
    - Listar jugadores del banco
    - Permitir tap para agregar a cancha
    - Test: Ver banco y mover jugadores
    - Commit: "feat(matches): add bench widget"

26. **Task 2.5.4: Lógica de movimiento jugadores** [4h]
    - Implementar tap en banco → seleccionar posición → agregar a cancha (FULL)
    - Implementar tap en cancha → remover jugador
    - Validar: máximo 7 jugadores en cancha
    - Persistir en match_player_periods
    - Test: Mover jugadores y verificar en DB
    - Commit: "feat(matches): implement player movement logic"

27. **Task 2.5.5: Substitution mode** [3h]
    - Agregar botón "Modo Cambio" (toggle)
    - En modo cambio: tap jugador cancha → tap jugador banco → crear substitution
    - Registrar en match_substitutions
    - Actualizar ambos jugadores a HALF en match_player_periods
    - Test: Realizar cambio
    - Commit: "feat(matches): implement substitution mode"

28. **Task 2.5.6: Minutes table** [2h]
    - Crear tabla de minutos (jugadores × Q1-Q4)
    - Mostrar FULL, HALF, o vacío
    - Actualizar en tiempo real cuando se modifica lineup
    - Test: Verificar tabla actualizada
    - Commit: "feat(matches): add minutes tracking table"

### Sprint 2.6: UI - Quarter Results & Goals
**Objetivo:** Registrar resultados y goles

**Tareas:**
29. **Task 2.6.1: Quarter results form** [2h]
    - Crear formulario en panel derecho
    - Campos: team_goals, opponent_goals (int inputs)
    - Guardar en match_quarter_results
    - Test: Registrar resultado de un cuarto
    - Commit: "feat(matches): add quarter results form"

30. **Task 2.6.2: Goals & assists form** [3h]
    - Crear lista de goles del cuarto actual
    - Botón "Agregar Gol"
    - Dialog: selector de scorer, selector de assister (opcional)
    - Guardar en match_goals
    - Mostrar lista con formato: "J. Pérez (asistencia: M. López)"
    - Test: Agregar goles con y sin asistencia
    - Commit: "feat(matches): add goals and assists tracking"

### Sprint 2.7: Validation & Polish
**Objetivo:** Validaciones finales

**Tareas:**
31. **Task 2.7.1: Minimum periods validation** [2h]
    - Botón "Validar Minimos" en MatchLineupPage
    - Llamar a validate_match_minimum_periods RPC
    - Mostrar banner rojo con jugadores que no cumplen
    - Listar: "jugador X jugó Y cuartos (mínimo: 2)"
    - Test: Validar con jugadores <2 cuartos
    - Commit: "feat(matches): add minimum periods validation"

32. **Task 2.7.2: Match summary & stats** [2h]
    - Calcular resultado final del partido (suma de quarters)
    - Mostrar W/D/L indicator
    - Mostrar top scorers del partido
    - Test: Verificar cálculos
    - Commit: "feat(matches): add match summary and stats"

33. **Task 2.7.3: Testing matches module** [3h]
    - Tests unitarios para MatchesRepository
    - Widget tests para MatchesPage
    - Widget tests para ConvocatoriaDialog
    - Integration test: flujo completo de crear partido y lineup
    - Test: `flutter test`
    - Commit: "test(matches): add comprehensive tests"

**Git Tag:** `v0.4.0-matches-complete`

---

## FASE 3: Módulo 4 - Entrenamientos y Asistencia

### Sprint 3.1: Domain & Infrastructure
**Objetivo:** Setup base de entrenamientos

**Tareas:**
34. **Task 3.1.1: Domain entities** [1h]
    - Crear `domain/trainings/entities/training_session.dart`
    - Crear `domain/trainings/entities/training_attendance.dart` (con enum Status)
    - Commit: "feat(trainings): add domain entities"

35. **Task 3.1.2: Repository interfaces & implementations** [2h]
    - Crear `TrainingSessionsRepository` interface
    - Crear `TrainingAttendanceRepository` interface
    - Implementar `SupabaseTrainingSessionsRepository`
    - Implementar `SupabaseTrainingAttendanceRepository`
    - Test manual: CRUD entrenamientos
    - Commit: "feat(trainings): add repositories"

36. **Task 3.1.3: State management** [1.5h]
    - Crear `TrainingSessionsNotifier`
    - Crear `TrainingAttendanceNotifier`
    - Providers
    - Commit: "feat(trainings): add state management"

### Sprint 3.2: UI Implementation
**Objetivo:** Pantallas de entrenamientos

**Tareas:**
37. **Task 3.2.1: Training sessions list** [2h]
    - Reemplazar placeholder de TrainingsPage
    - Listar entrenamientos del equipo (ordenados por fecha)
    - FAB para crear sesión
    - Botón "Asistencia" por sesión
    - Test: Ver lista y crear sesión
    - Commit: "feat(trainings): implement sessions list"

38. **Task 3.2.2: Training session form** [1.5h]
    - Dialog crear/editar sesión
    - Campos: session_date (DateTimePicker), notes
    - Test: Crear y editar sesión
    - Commit: "feat(trainings): add session form"

39. **Task 3.2.3: Attendance detail page** [3h]
    - Crear `TrainingAttendanceDetailPage`
    - Listar jugadores del equipo
    - Para cada jugador: segmented control (On Time / Late / Absent)
    - Guardar cambios automáticamente o con botón "Guardar"
    - Test: Marcar asistencia y verificar en DB
    - Commit: "feat(trainings): implement attendance tracking"

40. **Task 3.2.4: Training stats preview** [1h]
    - En TrainingsPage, mostrar estadísticas básicas
    - Total entrenamientos, % asistencia promedio
    - Test: Verificar cálculos
    - Commit: "feat(trainings): add stats preview"

41. **Task 3.2.5: Testing trainings module** [2h]
    - Tests unitarios para repositories
    - Widget tests para TrainingsPage
    - Widget tests para AttendanceDetailPage
    - Test: `flutter test`
    - Commit: "test(trainings): add tests"

**Git Tag:** `v0.5.0-trainings-complete`

---

## FASE 4: Módulo 5 - Estadísticas + Campeonato

### Sprint 4.1: Stats Infrastructure
**Objetivo:** Acceso a datos estadísticos

**Tareas:**
42. **Task 4.1.1: Domain entities** [1h]
    - Crear `domain/stats/entities/player_statistics.dart`
    - Crear `domain/stats/entities/match_summary.dart`
    - Crear `domain/stats/entities/quarter_performance.dart`
    - Commit: "feat(stats): add domain entities"

43. **Task 4.1.2: StatsRepository** [3h]
    - Crear interface `StatsRepository`
    - Métodos: getTeamPlayerStatistics, getScorersRanking, getAssistersRanking
    - Métodos: getMatchesSummary, getQuarterPerformance
    - Implementar `SupabaseStatsRepository`
    - Usar view `player_statistics` y función `get_team_player_statistics`
    - Test manual: Consultar stats
    - Commit: "feat(stats): implement stats repository"

44. **Task 4.1.3: Stats state management** [1h]
    - Crear `StatsNotifier`
    - Providers
    - Commit: "feat(stats): add state management"

### Sprint 4.2: Statistics Page
**Objetivo:** Dashboard de estadísticas

**Tareas:**
45. **Task 4.2.1: Statistics page scaffold** [1h]
    - Crear estructura con TabBar
    - Tabs: Players, Goals, Matches, Quarters, Training
    - Team selector
    - Commit: "feat(stats): add statistics page scaffold"

46. **Task 4.2.2: Players tab** [2h]
    - Tabla con player_statistics
    - Columnas: nombre, jersey, % asistencia entrenamientos, % asistencia partidos, promedio periodos
    - Color coding: verde ≥90%, gris ≥75%, rojo <75%
    - Test: Verificar colores
    - Commit: "feat(stats): implement players statistics tab"

47. **Task 4.2.3: Goals tab** [2h]
    - Dos rankings: goleadores y asistentes
    - Top 10 de cada uno
    - Mostrar: nombre, jersey, cantidad
    - Test: Verificar rankings
    - Commit: "feat(stats): implement goals tab"

48. **Task 4.2.4: Matches tab** [1.5h]
    - Lista de partidos con resultado final
    - W/D/L indicator con colores
    - Test: Verificar indicadores
    - Commit: "feat(stats): implement matches tab"

49. **Task 4.2.5: Quarters tab** [2h]
    - Tabla: Q1-Q4 con goles a favor, goles en contra, W/D/L
    - Calcular efectividad por cuarto
    - Test: Verificar cálculos
    - Commit: "feat(stats): implement quarters analysis tab"

50. **Task 4.2.6: Training attendance tab** [1h]
    - Ranking por % asistencia entrenamientos
    - Reuso de player_statistics
    - Color coding
    - Test: Verificar ranking
    - Commit: "feat(stats): implement training attendance tab"

### Sprint 4.3: Championship Page
**Objetivo:** Vista de campeonato

**Tareas:**
51. **Task 4.3.1: Championship page base** [2h]
    - Reemplazar placeholder de ChampionshipPage
    - Tabla de partidos: oponente, fecha, resultado
    - W/D/L indicator
    - Test: Ver tabla
    - Commit: "feat(championship): implement championship page"

52. **Task 4.3.2: Match details dialog** [2h]
    - Botón "Detalles" por partido
    - Dialog mostrando:
      - Resultados por cuarto
      - Goles por cuarto (scorer + assister)
    - Test: Ver detalles
    - Commit: "feat(championship): add match details dialog"

53. **Task 4.3.3: Testing stats module** [2h]
    - Tests unitarios para StatsRepository
    - Widget tests para StatisticsPage tabs
    - Widget tests para ChampionshipPage
    - Test: `flutter test`
    - Commit: "test(stats): add tests"

**Git Tag:** `v0.6.0-stats-complete`

---

## FASE 5: Módulo 6 - Evaluaciones de Jugadores

### Sprint 5.1: Evaluations Infrastructure
**Objetivo:** Setup base de evaluaciones

**Tareas:**
54. **Task 5.1.1: Domain entities** [1.5h]
    - Crear `domain/evaluations/entities/evaluation_category.dart`
    - Crear `domain/evaluations/entities/evaluation_criterion.dart`
    - Crear `domain/evaluations/entities/player_evaluation.dart`
    - Crear `domain/evaluations/entities/evaluation_score.dart`
    - Commit: "feat(evaluations): add domain entities"

55. **Task 5.1.2: Repository interfaces & implementations** [3h]
    - Crear `EvaluationCategoriesRepository`
    - Crear `PlayerEvaluationsRepository`
    - Implementar repositorios Supabase
    - Test manual: CRUD evaluaciones
    - Commit: "feat(evaluations): add repositories"

56. **Task 5.1.3: State management** [1.5h]
    - Crear `EvaluationCategoriesNotifier`
    - Crear `PlayerEvaluationsNotifier`
    - Providers
    - Commit: "feat(evaluations): add state management"

### Sprint 5.2: Coach Evaluations UI
**Objetivo:** Interfaz para entrenadores

**Tareas:**
57. **Task 5.2.1: Coach evaluations page** [2h]
    - Crear `CoachEvaluationsPage`
    - Selector de jugador
    - Listar evaluaciones previas del jugador
    - Botón "Nueva Evaluación"
    - Test: Navegar y seleccionar jugador
    - Commit: "feat(evaluations): implement coach evaluations page"

58. **Task 5.2.2: New evaluation page - structure** [2h]
    - Crear `NewEvaluationPage`
    - Cargar categorías y criterios desde DB
    - Agrupar por categoría
    - Test: Ver estructura
    - Commit: "feat(evaluations): add evaluation form structure"

59. **Task 5.2.3: Evaluation scoring UI** [3h]
    - Para cada criterio: slider 0-10
    - Campo de notas opcional
    - Campo de notas generales
    - Validación: todos los criterios deben tener score
    - Test: Completar evaluación
    - Commit: "feat(evaluations): implement scoring UI"

60. **Task 5.2.4: Save evaluation** [2h]
    - Guardar player_evaluation + evaluation_scores
    - Manejo de errores
    - Confirmación y navegación de regreso
    - Test: Guardar y verificar en DB
    - Commit: "feat(evaluations): implement save evaluation"

### Sprint 5.3: Player Evaluations UI
**Objetivo:** Vista para jugadores

**Tareas:**
61. **Task 5.3.1: Player evaluations page - latest** [2h]
    - Reemplazar placeholder de EvaluationsPage
    - Cargar última evaluación del jugador
    - Mostrar notas generales
    - Test: Ver última evaluación
    - Commit: "feat(evaluations): show latest player evaluation"

62. **Task 5.3.2: Radar chart** [3h]
    - Agregar package `fl_chart` o `charts_flutter`
    - Calcular promedio por categoría
    - Crear widget de radar chart
    - Test: Visualizar gráfico
    - Commit: "feat(evaluations): add radar chart"

63. **Task 5.3.3: Evaluation history** [2h]
    - Lista de evaluaciones previas
    - Mostrar fecha + mini-resumen por categoría
    - Tap para ver detalle
    - Test: Navegar historial
    - Commit: "feat(evaluations): add evaluation history"

64. **Task 5.3.4: Progress indicators** [2h]
    - Comparar con evaluación anterior
    - Flechas arriba/abajo por categoría
    - Porcentaje de mejora/decline
    - Test: Verificar indicadores
    - Commit: "feat(evaluations): add progress indicators"

65. **Task 5.3.5: Testing evaluations module** [2h]
    - Tests unitarios para repositories
    - Widget tests para CoachEvaluationsPage
    - Widget tests para PlayerEvaluationsPage
    - Test: `flutter test`
    - Commit: "test(evaluations): add tests"

**Git Tag:** `v0.7.0-evaluations-complete`

---

## FASE 6: Polish & Production Readiness

### Sprint 6.1: Performance & UX
**Objetivo:** Optimizaciones

**Tareas:**
66. **Task 6.1.1: Loading skeletons** [2h]
    - Agregar Shimmer/skeleton loaders en listas
    - Mejor feedback visual durante carga
    - Commit: "feat: add loading skeletons"

67. **Task 6.1.2: Error recovery** [2h]
    - Botones "Reintentar" en errores de red
    - Mensajes de error más descriptivos
    - Offline mode indicators
    - Commit: "feat: improve error handling UX"

68. **Task 6.1.3: Pull to refresh** [1h]
    - Agregar pull-to-refresh en listas principales
    - Matches, Trainings, Stats
    - Commit: "feat: add pull to refresh"

69. **Task 6.1.4: Optimistic updates** [2h]
    - Updates locales antes de confirmar con servidor
    - En formularios y toggles
    - Rollback en caso de error
    - Commit: "feat: add optimistic updates"

### Sprint 6.2: Documentation & Deployment
**Objetivo:** Preparar para producción

**Tareas:**
70. **Task 6.2.1: README update** [1h]
    - Documentar arquitectura
    - Setup instructions
    - Env variables
    - Commit: "docs: update README with architecture and setup"

71. **Task 6.2.2: Environment configs** [1h]
    - Crear `.env.example` completo
    - Documentar variables necesarias
    - CI/CD setup básico
    - Commit: "chore: add environment configs"

72. **Task 6.2.3: Build configurations** [2h]
    - Android: signing configs, build variants
    - iOS: provisioning profiles
    - Web: deployment config
    - Commit: "chore: add build configurations"

73. **Task 6.2.4: Analytics & logging** [2h]
    - Integrar Firebase Analytics (opcional)
    - Logging estructurado
    - Error reporting (Sentry/Crashlytics)
    - Commit: "feat: add analytics and logging"

**Git Tag:** `v1.0.0-production-ready`

---

## Estrategia de Trabajo

### Por cada tarea:
1. **Desarrollar**: Implementar la feature según especificación
2. **Test Manual**: Verificar funcionamiento en emulador/dispositivo
3. **Test Automatizado**: Escribir tests cuando corresponda
4. **Commit**: Git commit con mensaje convencional
5. **Push**: Subir a rama feature o directamente a main

### Formato de commits:
```
feat(module): description
fix(module): description
test(module): description
docs: description
chore: description
refactor(module): description
```

### Testing incremental:
- Después de cada sprint, ejecutar `flutter test`
- Verificar que no haya regresiones
- Mantener coverage >70%

### Code review:
- Opcional: crear PR para features grandes (Matches, Evaluations)
- Requerido: peer review antes de merge a main

---

## Estimaciones

| Fase | Sprints | Tareas | Tiempo Estimado |
|------|---------|--------|-----------------|
| Fase 1: Cross-cutting | 3 | 8 | ~12h |
| Fase 2: Matches | 7 | 25 | ~50h |
| Fase 3: Trainings | 2 | 8 | ~14h |
| Fase 4: Stats | 3 | 12 | ~20h |
| Fase 5: Evaluations | 3 | 12 | ~24h |
| Fase 6: Polish | 2 | 8 | ~12h |
| **TOTAL** | **20** | **73** | **~132h** |

**Ritmo sugerido:** 15-20h/semana = 7-9 semanas

---

## Priorización Alternativa

Si se necesita MVP más rápido:

### MVP Phase 1 (Core Features):
1. Completar Fase 1 (i18n + testing básico)
2. Implementar Matches (básico, sin drag & drop sofisticado)
3. Implementar Trainings
4. Deploy MVP

### MVP Phase 2 (Analytics):
5. Implementar Stats + Championship
6. Mejorar UX de Matches (drag & drop avanzado)

### MVP Phase 3 (Advanced):
7. Implementar Evaluations
8. Polish final

---

## Notas Importantes

1. **Testing**: No saltar tests, mantener cobertura alta desde el inicio
2. **Commits frecuentes**: Mejor 3 commits pequeños que 1 grande
3. **Hot Reload**: Aprovechar hot reload para iterar rápido
4. **State Management**: Seguir patrón Riverpod establecido consistentemente
5. **UI Components**: Reusar widgets cuando sea posible (DRY)
6. **Performance**: Profile regularmente en modo release
7. **Accessibility**: Considerar accesibilidad desde el inicio (semantic labels)
8. **Responsive**: Probar en tablet/web regularmente, no solo móvil

---

## Recursos & Ayuda

### Packages clave ya incluidos:
- `riverpod` - State management
- `go_router` - Routing
- `supabase_flutter` - Backend
- `intl` - Localization
- `equatable` - Value equality
- `freezed` - Immutable classes

### Por agregar según necesidad:
- `fl_chart` - Para radar charts (Evaluations)
- `shimmer` - Loading skeletons
- `cached_network_image` - Image caching
- `firebase_analytics` - Analytics
- `sentry_flutter` - Error reporting

### Documentación de referencia:
- Flutter docs: https://docs.flutter.dev
- Riverpod docs: https://riverpod.dev
- Supabase docs: https://supabase.com/docs
- Material 3 design: https://m3.material.io
