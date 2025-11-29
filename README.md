# Sport Tech App - Flutter

A Flutter application for team sport management with Supabase backend, built using Clean Architecture principles.

## Architecture

This project follows **Clean Architecture / Hexagonal Architecture** with clear separation of concerns:

```
lib/
├── core/              # Core utilities (errors, results, constants)
├── config/            # Configuration (environment, Supabase, theme)
├── l10n/              # Localization (ES/EN)
├── domain/            # Domain layer (entities, repository interfaces)
│   ├── auth/
│   └── profiles/
├── application/       # Application layer (state management, use cases)
│   └── auth/
├── infrastructure/    # Infrastructure layer (external services)
│   ├── auth/
│   └── profiles/
└── presentation/      # Presentation layer (UI)
    ├── app/           # App-level (router, scaffold)
    ├── auth/          # Authentication pages
    ├── dashboard/
    ├── matches/
    ├── trainings/
    ├── championship/
    ├── evaluations/
    ├── notes/
    └── profile/
```

### Technology Stack

- **State Management**: Riverpod (flutter_riverpod)
- **Routing**: go_router with auth guards
- **Backend**: Supabase (supabase_flutter)
- **Localization**: flutter_localizations + intl
- **UI**: Material 3 (light/dark theme support)

### Platforms

- ✅ Android
- ✅ iOS
- ✅ Web

## Features

### Authentication
- Email/password login via Supabase Auth
- Auto session management and refresh
- Auth state persistence
- Role-based access control

### User Roles
- **super_admin**: Full system access
- **admin**: Club/team management
- **coach**: Team management
- **player**: Player-facing features

### Navigation
- **Web**: Navigation rail (left sidebar)
- **Mobile**: Bottom navigation bar
- Role-based menu filtering
- Dark/light theme toggle
- Logout functionality

### Pages
- **Dashboard**: User overview
- **Partidos** (Matches): Match management (admin/coach)
- **Entrenamiento** (Trainings): Training management (admin/coach)
- **Campeonato** (Championship): Championship management (admin/coach)
- **Mis Evaluaciones**: Player evaluations (all users)
- **Notes**: Notes management (all users)
- **Profile**: User profile and settings

## Setup

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Supabase account with project created

### 1. Clone and Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Copy the example environment file and add your Supabase credentials:

```bash
cp .env.example .env.local
```

Edit `.env.local` with your Supabase URL and anon key.

### 3. Run the App

You can run the app with environment variables in two ways:

**Option 1: Using --dart-define**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

**Option 2: Modify `lib/config/env_config.dart`**

For development, you can temporarily hardcode values in `env_config.dart`:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

⚠️ **Important**: Never commit hardcoded credentials to version control.

### 4. Database Setup

Ensure your Supabase database has the following tables:

**auth.users** (managed by Supabase)

**public.profiles**
```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin', 'coach', 'player')),
  display_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own profile
CREATE POLICY "Users can read own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
```

**public.user_team_roles** (for multi-team access)
```sql
CREATE TABLE public.user_team_roles (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  team_id BIGINT REFERENCES public.teams(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('coach', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, team_id)
);
```

## Development

### Code Generation

Some packages use code generation (Riverpod, Freezed, JSON Serializable). Run the build runner when needed:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or watch for changes:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running on Different Platforms

**Android/iOS**
```bash
flutter run
```

**Web**
```bash
flutter run -d chrome
```

**Specific device**
```bash
flutter devices
flutter run -d <device-id>
```

### Build

**Android APK**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

## Project Structure Details

### Domain Layer
- **Entities**: Pure business objects (AuthUser, UserProfile)
- **Repository Interfaces**: Contracts for data access
- **No dependencies** on other layers

### Application Layer
- **State Management**: Riverpod StateNotifiers
- **Business Logic**: Auth flows, data transformations
- Depends on: Domain layer only

### Infrastructure Layer
- **Repository Implementations**: Supabase adapters
- **Mappers**: Convert between domain entities and external models
- Depends on: Domain layer + external packages

### Presentation Layer
- **UI Components**: Pages, widgets
- **Routing**: go_router configuration
- **Theme**: Material 3 theming
- Depends on: Application layer (via providers)

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## Localization

The app supports English and Spanish. To add or modify translations:

1. Edit `lib/l10n/app_en.arb` (English)
2. Edit `lib/l10n/app_es.arb` (Spanish)
3. Run code generation:
   ```bash
   flutter gen-l10n
   ```

## Contributing

1. Follow the established architecture
2. Keep domain layer pure (no external dependencies)
3. Use Riverpod for state management
4. Write tests for business logic
5. Follow Dart style guide

## Next Steps

- [ ] Implement remaining domain entities (Sports, Clubs, Teams, etc.)
- [ ] Add matches management features
- [ ] Add training session management
- [ ] Implement championship/tournament features
- [ ] Add player evaluation system
- [ ] Implement notes/comments features
- [ ] Add comprehensive tests
- [ ] Set up CI/CD pipeline
- [ ] Add error tracking (e.g., Sentry)
- [ ] Implement analytics

## License

[Your License Here]
