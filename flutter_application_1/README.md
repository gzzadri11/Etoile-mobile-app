# Etoile Mobile App

Application mobile de recrutement par video de 40 secondes.

## Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- iOS: Xcode 15+ (for iOS builds)
- Android: Android Studio with Android SDK

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Required environment variables:

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous key |

Optional variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `R2_BASE_URL` | Cloudflare R2 URL | - |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key | - |
| `ENVIRONMENT` | development/staging/production | development |
| `DEBUG_MODE` | Enable debug logging | true |

### 3. Supabase Setup

1. Create a Supabase project at https://supabase.com
2. Get your project URL and anon key from Settings > API
3. Apply the database schema:
   ```bash
   cd ../supabase
   supabase db push
   ```

### 4. Run the app

```bash
# Development
flutter run

# Release
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # MaterialApp configuration
├── core/                     # Shared infrastructure
│   ├── config/               # App configuration
│   ├── constants/            # Colors, strings
│   ├── errors/               # Failures and exceptions
│   ├── network/              # API client
│   ├── router/               # Navigation (GoRouter)
│   ├── services/             # Core services (Supabase)
│   └── theme/                # App theme
├── data/                     # Data layer
│   ├── datasources/          # Remote and local data sources
│   ├── models/               # DTOs
│   └── repositories/         # Repository implementations
├── domain/                   # Business logic
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository contracts
│   └── usecases/             # Use cases
├── presentation/             # UI layer
│   ├── blocs/                # BLoC state management
│   ├── pages/                # Screens
│   └── widgets/              # Reusable widgets
├── features/                 # Feature modules
│   ├── auth/                 # Authentication
│   ├── feed/                 # Video feed
│   ├── messages/             # Messaging
│   ├── profile/              # User profile
│   └── video/                # Video recording
├── shared/                   # Shared widgets
└── di/                       # Dependency injection
```

## Architecture

- **Clean Architecture**: Separation of concerns (data, domain, presentation)
- **BLoC Pattern**: State management with flutter_bloc
- **Repository Pattern**: Abstract data sources
- **Dependency Injection**: GetIt service locator

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend (Auth, DB, Realtime, Storage) |
| `flutter_bloc` | State management |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `hive_flutter` | Local cache |
| `flutter_dotenv` | Environment variables |
| `get_it` | Dependency injection |

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Troubleshooting

### "Configuration error" on startup

Check that your `.env` file exists and contains valid values for:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Supabase connection fails

1. Verify your Supabase project is running
2. Check that the URL and key are correct
3. Ensure your device has internet access

## Documentation

- [PRD](../_bmad-output/prd-etoile-draft.md)
- [Architecture](../_bmad-output/architecture-etoile.md)
- [UX Design](../_bmad-output/ux-design-etoile-draft.md)
- [Epics & Stories](../_bmad-output/epics.md)
