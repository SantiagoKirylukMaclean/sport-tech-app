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

## CI/CD with Vercel and GitHub Actions

This project uses GitHub Actions for automated deployment to Vercel with environment-specific Supabase configurations.

### Deployment Architecture

- **Branch: `stage`** → Deploys to **Vercel Preview** with **Supabase STAGE** environment
- **Branch: `main`** → Deploys to **Vercel Production** with **Supabase PROD** environment
- **Vercel Project ID**: `prj_WJvw9LJiZZ8gda7EdsdsCWFjBifw`

### Prerequisites

#### 1. Vercel Setup

**Create a Vercel Access Token:**
1. Go to [Vercel Account Settings > Tokens](https://vercel.com/account/tokens)
2. Click "Create Token"
3. Give it a name (e.g., "GitHub Actions CI/CD")
4. Copy the token (you'll only see it once)

**Get your Vercel Organization ID and Project ID:**

Option 1: Use Vercel CLI
```bash
npm install -g vercel@latest
vercel login
cd /path/to/your/project
vercel link
```

This creates a `.vercel/project.json` file with:
```json
{
  "orgId": "your-org-id",
  "projectId": "prj_WJvw9LJiZZ8gda7EdsdsCWFjBifw"
}
```

Option 2: Get from Vercel Dashboard
- **Org ID**: Found in your Vercel team settings URL: `vercel.com/<team-name>/settings`
- **Project ID**: Found in project settings or use the one provided: `prj_WJvw9LJiZZ8gda7EdsdsCWFjBifw`

**Important**: `.vercel/` directory is already in `.gitignore` and should NOT be committed.

#### 2. GitHub Secrets Configuration

Go to your GitHub repository → Settings → Secrets and variables → Actions

**Repository Secrets** (available to all branches):

| Secret Name | Description | Example |
|------------|-------------|---------|
| `VERCEL_TOKEN` | Vercel access token | `abc123...` |
| `VERCEL_ORG_ID` | Your Vercel organization/team ID | `team_abc123...` |
| `VERCEL_PROJECT_ID` | Vercel project ID | `prj_WJvw9LJiZZ8gda7EdsdsCWFjBifw` |

**Environment: `stage`**

Go to Settings → Environments → Create environment "stage"

| Secret Name | Description | Example |
|------------|-------------|---------|
| `SUPABASE_URL` | Supabase staging project URL | `https://xxxstage.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase staging anon key | `eyJhbGc...` |

**Environment: `production`**

Go to Settings → Environments → Create environment "production"

| Secret Name | Description | Example |
|------------|-------------|---------|
| `SUPABASE_URL` | Supabase production project URL | `https://xxxprod.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase production anon key | `eyJhbGc...` |

### How It Works

#### Development Workflow

1. **Feature Development**
   ```bash
   git checkout -b feature/my-feature
   # Make changes
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/my-feature
   ```
   Create a PR to merge into `stage`

2. **Deploy to Staging**
   ```bash
   git checkout stage
   git merge feature/my-feature
   git push origin stage
   ```
   This triggers [.github/workflows/deploy_stage.yml](.github/workflows/deploy_stage.yml):
   - Runs tests
   - Builds Flutter web with STAGE Supabase config
   - Deploys to Vercel Preview
   - URL: `https://sport-tech-app-<unique-id>.vercel.app`

3. **Deploy to Production**
   ```bash
   git checkout main
   git merge stage
   git push origin main
   ```
   This triggers [.github/workflows/deploy_prod.yml](.github/workflows/deploy_prod.yml):
   - Runs tests
   - Builds Flutter web with PROD Supabase config
   - Deploys to Vercel Production
   - URL: Your production domain (e.g., `sport-tech-app.vercel.app`)

#### CI/CD Pipeline Steps

Both workflows perform the same steps with environment-specific configurations:

1. **Checkout Code**: Downloads the repository
2. **Setup Flutter**: Installs Flutter SDK (stable channel with caching)
3. **Install Dependencies**: Runs `flutter pub get`
4. **Run Tests**: Executes `flutter test` (build fails if tests fail)
5. **Build Web App**:
   ```bash
   flutter build web --release \
     --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
     --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
   ```
6. **Install Vercel CLI**: Installs latest Vercel CLI globally
7. **Deploy to Vercel**:
   - **Stage**: `vercel deploy build/web --yes --token=$VERCEL_TOKEN --target=preview`
   - **Prod**: `vercel deploy build/web --yes --token=$VERCEL_TOKEN --prod`

### Environment Configuration in Code

The app uses compile-time environment variables via `--dart-define`.

**[lib/config/env_config.dart](lib/config/env_config.dart):**
```dart
class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Validates that all required environment variables are set
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not configured.');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not configured.');
    }
  }
}
```

**[lib/config/supabase_config.dart](lib/config/supabase_config.dart:16-35):**
```dart
Future<void> initializeSupabase() async {
  // Validate environment configuration
  EnvConfig.validate();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
    debug: kDebugMode,
  );
}
```

**[lib/main.dart](lib/main.dart:13-18):**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with environment-specific config
  await initializeSupabase();

  runApp(const ProviderScope(child: SportTechApp()));
}
```

### Local Development

For local development, you have two options:

**Option 1: Using `--dart-define`** (Recommended)
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-dev-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-dev-anon-key
```

**Option 2: VS Code Launch Configuration**

Create/edit `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://your-dev-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-dev-anon-key"
      ]
    }
  ]
}
```

### Security Best Practices

1. **Never commit credentials**: `.env*` files are in `.gitignore`
2. **Never commit `.vercel/` directory**: Already in `.gitignore`
3. **Use GitHub Environments**: Secrets are scoped to specific branches
4. **Rotate tokens periodically**: Regenerate Vercel tokens and GitHub secrets regularly
5. **Use different Supabase projects**: Separate STAGE and PROD databases

### Troubleshooting

**Build fails with "SUPABASE_URL is not configured":**
- Check that GitHub Environment secrets are correctly set
- Ensure the environment name matches exactly (`stage` or `production`)
- Verify workflow is using the correct `environment:` key

**Vercel deployment fails:**
- Verify `VERCEL_TOKEN` is valid (tokens can expire)
- Check `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` are correct
- Ensure Vercel project exists and is linked to the organization

**Tests fail in CI but pass locally:**
- Run `flutter test` locally to reproduce
- Check if tests depend on environment variables
- Ensure all dependencies are in `pubspec.yaml`

**Web app shows blank screen:**
- Check browser console for errors
- Verify Supabase URL and anon key are correct
- Ensure CORS is configured in Supabase for your Vercel domain

### Monitoring Deployments

- **GitHub Actions**: Check Actions tab in your repository for build logs
- **Vercel Dashboard**: View deployments at [vercel.com/dashboard](https://vercel.com/dashboard)
- **Vercel CLI**: Check deployment status with `vercel ls`

### Next Steps

- [ ] Implement remaining domain entities (Sports, Clubs, Teams, etc.)
- [ ] Add matches management features
- [ ] Add training session management
- [ ] Implement championship/tournament features
- [ ] Add player evaluation system
- [ ] Implement notes/comments features
- [ ] Add comprehensive tests
- [x] Set up CI/CD pipeline
- [ ] Add error tracking (e.g., Sentry)
- [ ] Implement analytics

## License

[Your License Here]
