FindEasy App Architecture
Overview
The FindEasy app is a cross-platform mobile application for indoor navigation, designed to help users locate their cars, shops, or other points of interest (POIs) in large indoor spaces like shopping malls, airports, and exhibition centers. The app is built using Dart/Flutter to support both iOS and Android with a single codebase, ensuring cost-effective development for a startup with limited resources. The architecture is modular, scalable, and supports offline functionality, map data encryption, and extensibility for future features like 3D rendering and Bluetooth/WiFi localization.
The app follows a Clean Architecture approach, separating concerns into layers (Presentation, Domain, Data) to ensure maintainability and testability. It uses Riverpod for state management and dependency injection, and go_router for navigation, integrating with a backend for map data, user management, and OTA updates, while prioritizing offline capabilities and data security.
Architecture Layers
1. Presentation Layer
Handles UI components, user interactions, and navigation rendering.

Tech Stack: Flutter, Riverpod (for state management and dependency injection), go_router (for navigation), FlutterMap (for 2D map rendering), Material Design (for UI components).
Responsibilities:
Display indoor maps with zoomable POIs and routes.
Render navigation instructions with voice (TTS) and text feedback.
Handle user inputs (text, voice via ASR, or POI taps).
Manage splash screen, settings, and feedback forms.


Key Features:
Map rendering with dynamic zoom (show/hide POI labels based on zoom level).
Voice assistant integration for hands-free navigation.
Offline map rendering using cached .osm.gz files.
User feedback submission for map errors or app suggestions.



2. Domain Layer
Contains business logic, use cases, and core entities.

Responsibilities:
Define entities like Place, POI, Route, and User.
Implement use cases for routing, localization, and map parsing.
Integrate with easyroute for on-device routing and deviation detection.
Manage voice assistant logic (ASR parsing, TTS instructions).


Key Features:
Routing logic using easyroute for shortest path generation.
Deviation detection and path replanning.
POI-based localization with compass/IMU integration.
Encryption/decryption logic for map data.



3. Data Layer
Manages data access, storage, and network interactions.

Tech Stack: SharedPreferences (for local storage), Dio (for HTTP requests), PathProvider (for file system access), Encrypt (for encryption).
Responsibilities:
Fetch and cache encrypted .osm.gz map files from the backend.
Store user preferences, configurations, and offline ASR models.
Handle API calls for place queries, user authentication, and feedback submission.
Collect and upload Bluetooth/WiFi signal data for crowdsourcing.


Key Features:
Offline map storage with encryption.
Single Sign-On (SSO) with Weixin/Google and SMS-based login.
Crowdsourced signal data collection for future localization.



Dependency Injection with Riverpod
Riverpod serves as the primary dependency injection mechanism, eliminating the need for a separate global injector (e.g., get_it). Dependencies like repositories, services, and use cases are defined as Riverpod providers:

Global Providers: Shared services (e.g., ApiService, StorageService) are defined in core/services/providers and accessible app-wide via ProviderScope.
Feature-Specific Providers: Each feature (e.g., map, navigation) defines its own providers in features/<feature>/presentation/providers for state and dependencies specific to that feature.
Benefits:
Type-safe dependency injection.
Easy mocking for unit and integration tests.
Scoped dependencies to avoid unnecessary global access.
No singleton-related issues, unlike traditional global injectors.



Example global provider (in core/services/providers/api_service_provider.dart):
final apiServiceProvider = Provider<ApiService>((ref) => ApiServiceImpl());

Example feature-specific provider (in map/presentation/providers/map_provider.dart):
final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final mapRepository = ref.watch(mapRepositoryProvider);
  return MapNotifier(mapRepository);
});

Scalability Considerations

Modular Design: Components are organized into independent packages (e.g., map, navigation, auth) to allow easy addition of features like 3D rendering or Bluetooth localization.
Offline First: Maps and routing logic run on-device to minimize cloud dependency, crucial for a tight budget and initial small-scale deployment.
Extensibility: The architecture supports future integration with 3rd-party car-finding systems and advanced localization (Bluetooth/WiFi).
Performance: Map data is cached locally, and easyroute runs on-device to reduce latency and server costs.
Growth: The codebase is structured to support a growing team, with Riverpod’s type-safe providers ensuring maintainability.

Security

Map Data Encryption: .osm.gz files are encrypted using AES (via the encrypt package) before storage and during transfer. Decryption occurs only in memory during app runtime.
Secure Storage: User data and configurations are stored securely using SharedPreferences with encryption.
Network Security: API calls use HTTPS, and sensitive endpoints (e.g., map downloads) require authentication tokens.

Folder Structure
The folder structure is designed for clarity, scalability, and ease of maintenance, following Flutter conventions with modular organization. Riverpod providers are used for state management and dependency injection, with global services in core/services/providers.
findeasy/
├── test/                      # Unit and integration tests
│   ├── features/             # Feature-specific tests
│   ├── widgets/              # UI widget tests
│   └── utils/                # Utility function tests
├── assets/                    # Static assets
│   ├── fonts/                # Custom fonts for TTS language support
│   ├── images/               # Splash screen and app icons
│   └── models/               # Offline ASR models
├── lib/                       # Source code
│   ├── features/             # Feature-specific modules
│   │   ├── map/              # Map rendering and management
│   │   │   ├── presentation/ # UI components
│   │   │   │   ├── providers/ # Riverpod providers
│   │   │   │   │   ├── map_provider.dart # Map state
│   │   │   │   │   └── place_provider.dart # Place fetching
│   │   │   │   ├── widgets/  # Reusable map widgets
│   │   │   │   │   ├── map_view.dart # Map rendering widget
│   │   │   │   │   └── poi_label.dart # POI label widget
│   │   │   │   └── screens/  # Map-related screens
│   │   │   │       └── home_screen.dart # Main map screen
│   │   │   ├── domain/       # Business logic
│   │   │   │   ├── entities/ # Map entities
│   │   │   │   │   ├── place.dart # Place entity
│   │   │   │   │   └── poi.dart   # POI entity
│   │   │   │   └── usecases/ # Map use cases
│   │   │   │       └── get_place.dart # Fetch place by lat/lon
│   │   │   └── data/         # Data access
│   │   │       ├── repositories/ # Map data access
│   │   │       │   └── map_repository.dart
│   │   │       └── models/   # Data models
│   │   │           └── place_model.dart
│   │   ├── navigation/       # Navigation and routing
│   │   │   ├── presentation/ # UI components
│   │   │   │   ├── providers/ # Riverpod providers
│   │   │   │   │   ├── navigation_provider.dart # Navigation state
│   │   │   │   │   └── route_provider.dart # Route generation
│   │   │   │   ├── widgets/  # Navigation widgets
│   │   │   │   │   ├── nav_bar.dart # Navigation controls
│   │   │   │   │   └── instruction_view.dart # Instruction display
│   │   │   │   └── screens/  # Navigation screens
│   │   │   │       └── navigation_screen.dart
│   │   │   ├── domain/       # Business logic
│   │   │   │   ├── entities/ # Navigation entities
│   │   │   │   │   └── route.dart # Route entity
│   │   │   │   └── usecases/ # Navigation use cases
│   │   │   │       ├── generate_route.dart # Generate route
│   │   │   │       └── detect_deviation.dart # Detect deviation
│   │   │   └── data/         # Data access
│   │   │       └── repositories/ # Navigation data access
│   │   │           └── navigation_repository.dart
│   │   ├── auth/             # User authentication
│   │   │   ├── presentation/ # UI components
│   │   │   │   ├── providers/ # Riverpod providers
│   │   │   │   │   └── auth_provider.dart # Auth state
│   │   │   │   └── screens/  # Auth screens
│   │   │   │       └── settings_screen.dart # User settings
│   │   │   ├── domain/       # Business logic
│   │   │   │   ├── entities/ # Auth entities
│   │   │   │   │   └── user.dart # User entity
│   │   │   │   └── usecases/ # Auth use cases
│   │   │   │       └── login.dart # Login use case
│   │   │   └── data/         # Data access
│   │   │       ├── repositories/ # Auth data access
│   │   │       │   └── auth_repository.dart
│   │   │       └── models/   # Data models
│   │   │           └── user_model.dart
│   │   ├── voice_assistant/  # Voice input/output
│   │   │   ├── presentation/ # UI components
│   │   │   │   ├── providers/ # Riverpod providers
│   │   │   │   │   └── voice_provider.dart # Voice state
│   │   │   │   ├── widgets/  # Voice widgets
│   │   │   │   │   └── voice_input.dart # Voice input UI
│   │   │   │   └── screens/  # Voice screens
│   │   │   │       └── voice_screen.dart
│   │   │   ├── domain/       # Business logic
│   │   │   │   └── usecases/ # Voice use cases
│   │   │   │       └── handle_voice_input.dart # Process ASR
│   │   │   └── data/         # Data access
│   │   │       └── repositories/ # Voice data access
│   │   │           └── voice_repository.dart
│   │   └── feedback/         # User feedback
│   │       ├── presentation/ # UI components
│   │       │   ├── providers/ # Riverpod providers
│   │       │   │   └── feedback_provider.dart # Feedback state
│   │       │   └── screens/  # Feedback screens
│   │       │       └── feedback_screen.dart
│   │       ├── domain/       # Business logic
│   │       │   └── usecases/ # Feedback use cases
│   │       │       └── submit_feedback.dart
│   │       └── data/         # Data access
│   │           ├── repositories/ # Feedback data access
│   │           │   └── feedback_repository.dart
│   │           └── models/   # Data models
│   │               └── feedback_model.dart
│   ├── core/                 # Shared utilities and configs
│   │   ├── navigation/       # Navigation setup
│   │   │   └── app_router.dart # go_router configuration
│   │   ├── utils/            # Utility functions
│   │   │   ├── encryption.dart # AES encryption for map data
│   │   │   ├── easyroute.dart  # Wrapper for easyroute library
│   │   │   ├── compass.dart    # Compass/IMU utilities
│   │   │   └── logger.dart     # Logging for debugging
│   │   ├── constants/        # App-wide constants
│   │   │   ├── api.dart      # API endpoints
│   │   │   └── config.dart   # App configurations
│   │   └── services/         # Shared services
│   │       ├── providers/    # Global Riverpod providers
│   │       │   ├── api_service_provider.dart # HTTP client
│   │       │   ├── storage_service_provider.dart # Local storage
│   │       │   └── file_service_provider.dart # File system access
│   │       ├── api_service.dart # HTTP client interface
│   │       ├── storage_service.dart # Storage interface
│   │       └── file_service.dart # File system interface
│   ├── app.dart              # App entry point
│   └── main.dart             # Main entry point
├── docs/                     # Documentation
│   ├── findeasy_app_arch.md  # This architecture document
│   └── PRD.md                # Product requirements document
├── pubspec.yaml              # Project dependencies and configs
├── analysis_options.yaml     # Dart linting rules
└── scripts/                  # Build and deployment scripts
    ├── setup.sh              # Initial setup script
    └── test.sh               # Test runner script

Key Modules and Responsibilities
The module responsibilities remain the same as in the previous artifact, with Riverpod handling both state and dependency injection:

Map Module: Uses map_provider.dart and place_provider.dart to manage map state and fetch places via MapRepository.
Navigation Module: Uses navigation_provider.dart and route_provider.dart to manage route state and interact with easyroute.
Voice Assistant Module: Uses voice_provider.dart to handle ASR/TTS state.
Auth Module: Uses auth_provider.dart for login state and SSO.
Feedback Module: Uses feedback_provider.dart for feedback submission state.

Deployment Roadmap
Unchanged from the previous artifact:

Phase 1 (0-6 months, 1 engineer): Core features with manual builds.
Phase 2 (6-24 months, small team): Add voice assistant, feedback, SSO; introduce CI/CD.
Phase 3 (24+ months, medium team): Add 3D rendering, Bluetooth localization; use Fastlane.

Development Practices

Version Control: Git with main and feature branches.
Code Quality: Dart analysis with flutter_lints.
Testing: flutter_test for unit/widget tests, integration_test for E2E tests.
CI/CD: Manual builds initially, GitHub Actions in Phase 2.
Documentation: Maintain docs/ for architecture and PRD.

Dependencies

Flutter: Cross-platform framework.
Riverpod: State management and dependency injection.
go_router: Navigation.
FlutterMap: 2D map rendering.
Dio: HTTP requests.
Encrypt: AES encryption.
SharedPreferences: Local storage.
PathProvider: File system access.
SensorsPlus: Compass/IMU.
FlutterTts: Text-to-speech.
SpeechToText: ASR (or custom offline solution).
Test: Unit and widget testing.

Notes

No Global Injector Needed: Riverpod’s provider system handles dependency injection, with global providers in core/services/providers and feature-specific providers in features/<feature>/presentation/providers.
Riverpod Benefits: Type-safe, testable, and scoped DI; avoids singleton issues.
Extensibility: The structure supports adding 3D rendering or Bluetooth localization via new providers.
Budget: On-device routing and Riverpod’s lightweight DI minimize cloud costs.
Security: Map data encryption and secure storage remain unchanged.

This architecture leverages Riverpod’s dependency injection to provide a scalable, maintainable solution for the FindEasy app without requiring a separate global injector.