# Bet Out App — Architecture Kickoff

This document describes how to structure **bet_out_app** using the same architecture and library stack as **Safemind**. Use it as a blueprint while building from scratch — do **not** copy files or product code from Safemind.

Safemind’s shape in one line: **feature modules (BLoC + use cases) + shared `api/` / `core/` / `design_system/` / `di/`**, with **Injectable + GetIt**, **no repository layer**.

---

## Goals

- Same layering and naming conventions as Safemind
- Same core libraries and DI / state-management approach
- Greenfield code owned by bet_out_app
- Easy to grow features without inventing a new pattern each time

---

## Recommended folder structure

Create this under `lib/` as you kick off:

```
lib/
├── main.dart
├── api/
│   ├── providers/          # HTTP / local data sources (*Provider)
│   ├── model/              # Request/response DTOs (fromJson / toJson)
│   └── mappers/            # API models → UI / view objects
├── core/
│   ├── localization/       # Manual i18n maps + delegate
│   ├── services/           # Cross-cutting services (HTTP auth, tokens, analytics, …)
│   └── utils/              # Shared helpers
├── design_system/
│   ├── model/              # UI view objects
│   └── widget/             # Reusable widgets (prefix with Bo* or similar)
├── di/
│   ├── injection.dart      # getIt + configureDependencies()
│   ├── injection.config.dart  # generated — do not edit by hand
│   ├── http_module.dart    # @module for http.Client, authenticated client
│   └── firebase_module.dart   # @module only if/when you add Firebase
├── features/
│   └── <feature_name>/
│       ├── domain/         # Use cases (abstract + Impl)
│       └── presentation/
│           ├── <feature>_screen.dart
│           └── bloc/
│               ├── <feature>_bloc.dart
│               ├── <feature>_event.dart
│               └── <feature>_state.dart
└── assets/                 # App images (also declare in pubspec.yaml)
```

Mirror tests under `test/`:

```
test/
├── api/
│   ├── mappers/
│   └── providers/
├── core/
└── features/
    └── <feature_name>/
        └── domain/
```

Optional (only when needed): `packages/` for local path packages, `scripts/` for coverage helpers.

**What we intentionally skip (same as Safemind):** no root `data/`, `domain/`, or `repository/` layers. Providers *are* the data sources.

---

## Data & call flow

```
UI (Screen)
  → Bloc (events / states)
    → UseCase.invoke(...)
      → Provider (HTTP / SharedPreferences / …)
        → Mapper (optional)
          → UI model / ViewObject
            → emit State
```

Rules:

1. Screens talk to **Blocs**, not Providers.
2. Blocs talk to **UseCases**, not raw HTTP.
3. UseCases orchestrate Providers (+ Mappers).
4. Keep DTOs in `api/model/`; keep UI-facing models in `design_system/model/` when they differ from API shapes.

---

## Library stack

Align versions with Safemind’s current stack. Start lean; add Firebase / media only when the product needs them.

### Must-have (core architecture)

| Package | Role |
|---------|------|
| `flutter_bloc` + `bloc` + `equatable` | State management |
| `injectable` + `get_it` | DI |
| `http` | Networking |
| `shared_preferences` | Local persistence |
| `provider` | Declared for compatibility; **do not** drive app state with `ChangeNotifierProvider` |
| `intl` + `flutter_localizations` | Localization helpers |
| `flutter_lints` | Analysis |
| `injectable_generator` + `build_runner` | Codegen |
| `bloc_test` + `mocktail` (and/or `mockito`) | Tests |

### Add when needed

| Package | When |
|---------|------|
| `firebase_core` + Auth / Firestore / Messaging / Analytics / Remote Config / Storage | Backend or push / flags / analytics |
| `flutter_local_notifications` + `timezone` | Local reminders |
| `url_launcher`, `webview_flutter`, `image_picker`, … | Feature-specific |

### Suggested `pubspec.yaml` starter (core only)

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.2
  injectable: ^3.0.0
  get_it: ^9.2.1
  flutter_bloc: ^9.1.1
  bloc: ^9.2.1
  equatable: ^2.0.5
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  injectable_generator: ^3.0.2
  build_runner: ^2.4.8
  bloc_test: ^10.0.0
  mockito: ^5.4.4
  mocktail: ^1.0.5
```

SDK constraint and major versions should stay in the same ballpark as Safemind so upgrades stay predictable.

---

## Dependency injection

### Setup

1. `lib/di/injection.dart` — `GetIt` instance + `@InjectableInit()` → `configureDependencies()`.
2. Annotate classes with `@injectable`, `@singleton`, or `@lazySingleton`.
3. Register third-party types in `@module` classes (`HttpModule`, later `FirebaseModule`).
4. Bind interfaces with `@Injectable(as: SomeUseCase)`.
5. Generate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Patterns to follow

| Annotation | Use for |
|------------|---------|
| `@injectable` | Blocs, providers, mappers, most use cases |
| `@lazySingleton` | `http.Client`, authenticated HTTP wrapper |
| `@singleton` | Long-lived services (notifications, remote config, …) |
| `@Injectable(as: X)` | Abstract use case → `*Impl` |
| `@Named(...)` | Multiple bindings of the same type |

### Boot order in `main.dart`

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Platform init (e.g. `Firebase.initializeApp()` if used)
3. `configureDependencies()`
4. Initialize injectable services that need a one-shot `initialize()`
5. `runApp(...)` with `MultiBlocProvider` for app-scoped blocs from `getIt<>()`

---

## State management (BLoC)

- One feature → one bloc folder under `presentation/bloc/`.
- Prefer **`part of`** for event/state files (same pattern as most Safemind features):

```dart
// login_bloc.dart
part 'login_event.dart';
part 'login_state.dart';
```

- Events and states extend `Equatable`.
- Resolve blocs via `getIt` in `BlocProvider(create: (_) => getIt<XBloc>())`.
- App-wide blocs (auth, home, settings-like shells) live in root `MultiBlocProvider`.
- Feature-only blocs are created on the route / screen.

**Do not** use Provider/`ChangeNotifier` for app UI state even if some data classes extend `ChangeNotifier` for historical reasons.

---

## Networking / API layer

### Providers

- Live in `lib/api/providers/`.
- Own HTTP calls and local storage reads/writes.
- Naming: `*_provider.dart` → class `SomethingProvider`.
- Login / public endpoints may use raw `http.Client`; authenticated endpoints should go through a wrapper that:
  - attaches `Authorization: Bearer <token>`
  - on 401/403 clears session and redirects to login via a navigator key service

### Models & mappers

- `api/model/` — wire DTOs only.
- `api/mappers/` — map DTOs → design-system / UI objects.
- Prefer small, focused mappers (`LoginMapper`, `OddsMapper`, …).

### Auth session (Safemind-style)

- Custom API JWT (or similar) stored via a token storage service + SharedPreferences.
- User snapshot stored locally if needed for the shell UI.
- Firebase Auth is optional and **not required** for session if your backend issues tokens.

---

## Features

Each product area is a folder under `features/`:

```
features/<name>/
  domain/          # *Usecase abstract + *UsecaseImpl, method often invoke(...)
  presentation/    # screens + bloc/
```

### Naming

| Kind | Convention |
|------|------------|
| Folders | `snake_case` (or kebab only if you have a strong reason) |
| Screens | `*_screen.dart`, class `*Screen` |
| Blocs | `*_bloc.dart` / `*_event.dart` / `*_state.dart` |
| Use cases | `verb_noun_usecase.dart` → `GetFooUsecase` / `GetFooUsecaseImpl` |
| Design system | prefix widgets (`BoPrimaryButton`, `BoAppBar`, …) — pick one prefix and stick to it |
| Routes | `static const routeName = '...'` on the screen |

### Starter features for bet_out_app (suggested)

Pick product-real names; structure only:

- `onboarding` — first-run gate
- `auth` / `login` / `signup` — session
- `home` — main shell content
- `settings` — preferences / logout
- Plus bet-domain features as you define them (markets, slips, results, …)

Keep domain thin: use cases orchestrate; business rules can grow later without introducing repositories unless you deliberately choose to.

---

## Navigation

- `MaterialApp` named routes for primary screens.
- Tab / shell screen for the logged-in home.
- Imperative `Navigator.push` / `pushNamed` for secondary flows.
- Global `navigatorKey` on a small `NavigationService` for redirects from the HTTP layer (logout on expired token).

Initial route pattern: onboarding/auth gate → shell.

---

## Localization

Follow Safemind’s **manual map** approach (not ARB / gen-l10n) unless you later decide to migrate:

- `core/localization/app_localizations.dart` — string maps per locale
- Delegate + `supportedLocales` on `MaterialApp`
- Access via `AppLocalizations.of(context)?.key`

Start with `en` (and `pt` if you need parity with Safemind).

---

## Design system

- Reusable widgets under `design_system/widget/...`
- Theme tokens (colors, text styles) owned here, not scattered in features
- Screens compose design-system widgets; avoid one-off styled buttons in every feature

---

## Testing strategy

Prioritize the same layers Safemind tests:

1. **Providers** — HTTP with mocked client / helpers
2. **Mappers** — pure unit tests
3. **Use cases** — mock providers with mocktail or mockito

`bloc_test` is available for bloc specs; add them when flows get non-trivial. Prefer unit tests over widget tests early.

---

## Kickoff checklist

Work through this in order:

1. **Deps** — add core packages above; run `flutter pub get`.
2. **Folders** — create empty `api/`, `core/`, `design_system/`, `di/`, `features/` trees.
3. **DI** — `injection.dart` + `HttpModule`; run build_runner once.
4. **Core services** — token storage, authenticated HTTP client, navigation service.
5. **Localization stub** — en (and pt if needed) + wire into `MaterialApp`.
6. **Shell** — `main.dart` boot order + empty home / login routes.
7. **First vertical slice** — e.g. login: model → provider → mapper → use case → bloc → screen.
8. **Tests** — one mapper + one use case + one provider test to lock the pattern.
9. **Firebase / notifications** — only when a real requirement lands; then add `FirebaseModule` and services the Safemind way.
10. **Design system** — 3–5 base widgets before building many screens.

---

## What *not* to do

- Do not copy Safemind source, assets, API URLs, Firebase projects, or secrets.
- Do not introduce a repository layer “for cleanliness” unless the team explicitly decides to evolve past this pattern.
- Do not put HTTP calls in Blocs or Screens.
- Do not use Provider for app state when Blocs already own it.
- Do not edit `injection.config.dart` by hand.

---

## Mental model vs Clean Architecture

| Clean Architecture | This stack |
|--------------------|------------|
| Repository | **Provider** (`api/providers`) |
| Use case / interactor | **UseCase** (`features/*/domain`) |
| Presentation | **BLoC + Screen** |
| Entities / DTOs | **api/model** + optional **design_system/model** |
| DI container | **GetIt + Injectable** |

This is a pragmatic hybrid: feature folders + shared horizontal layers. Stay consistent; consistency beats purity here.

---

## Quick reference — regenerate & analyze

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

## Source of truth

Patterns above are derived from the Safemind app layout (`lib/api`, `lib/core`, `lib/design_system`, `lib/di`, `lib/features`, BLoC + Injectable). Re-check Safemind’s `pubspec.yaml` when bumping majors so bet_out_app stays on a compatible stack.
