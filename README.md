[![build](https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg)](https://github.com/felangel/bloc/actions)
[![Flutter Deploy](https://github.com/uumair327/github_search/actions/workflows/deploy-flutter.yml/badge.svg)](https://github.com/uumair327/github_search/actions/workflows/deploy-flutter.yml)
[![Angular Deploy](https://github.com/uumair327/github_search/actions/workflows/deploy-angular.yml/badge.svg)](https://github.com/uumair327/github_search/actions/workflows/deploy-angular.yml)

# Github Search

Sample project demonstrating **Clean Architecture** implementation with Flutter and AngularDart, featuring shared business logic and proper separation of concerns.

## 🏗️ Architecture

This project showcases **Clean Architecture** principles with:

- **🎯 Domain Layer**: Pure business logic with entities, use cases, and repository interfaces
- **📊 Data Layer**: Repository implementations, data sources, and DTOs
- **🎨 Presentation Layer**: BLoC state management for UI logic
- **🔧 Core Layer**: Dependency injection and cross-cutting concerns

**Key Features**:
- ✅ Proper dependency inversion (dependencies flow inward)
- ✅ Framework-independent business logic
- ✅ Comprehensive error handling with domain exceptions
- ✅ Type-safe dependency injection container
- ✅ Caching strategy with fallback mechanisms
- ✅ Property-based testing and mocks

## 🚀 Live Demos

- **🌐 Landing Page**: [https://uumair327.github.io/github_search/](https://uumair327.github.io/github_search/)
- **📱 Flutter Version**: [https://uumair327.github.io/github_search/flutter/](https://uumair327.github.io/github_search/flutter/)
- **🅰️ Angular Version**: [https://uumair327.github.io/github_search/angular/](https://uumair327.github.io/github_search/angular/)



## Quick Start

_Make sure you have the [Dart SDK](https://dart.dev/tools/sdk) and [Flutter SDK](https://flutter.dev/docs/get-started/install) installed before proceeding._

Open this project in your editor of choice (VSCode is recommended).

### Setup

1. Install dependencies for `common_github_search`:

   ```bash
   # change directories into common_github_search
   cd common_github_search

   # install dependencies
   dart pub get

   # change directories back out to the root directory
   cd ../
   ```

2. Install dependencies for `flutter_github_search`

   ```bash
   # change directories into flutter_github_search
   cd flutter_github_search

   # install dependencies
   flutter pub get

   # change directories back out to the root directory
   cd ../
   ```

3. Install dependencies for `angular_github_search`

   ```bash
   # change directories into flutter_github_search
   cd angular_github_search

   # install dependencies
   dart pub get

   # change directories into flutter_github_search
   cd ../
   ```

### Run Flutter

```bash
# change directories into flutter_github_search
cd flutter_github_search

# run the flutter project
flutter run
```

### Run AngularDart

```bash

# change directories into angular_github_search
cd angular_github_search

# run the angular project
webdev serve
```

## 🔄 GitHub Actions & Deployment

This project includes automated CI/CD pipelines that:

- **Analyze & Test**: Run static analysis on all projects
- **Build**: Create production builds for both Flutter and Angular
- **Deploy**: Automatically deploy to GitHub Pages on push to main branch

### Workflows

1. **Flutter Deployment** (`.github/workflows/deploy-flutter.yml`)
   - Triggers on changes to `flutter_github_search/` or `common_github_search/`
   - Builds Flutter web app with proper base href
   - Deploys to `/flutter/` subdirectory

2. **Angular Deployment** (`.github/workflows/deploy-angular.yml`)
   - Triggers on changes to `angular_github_search/` or `common_github_search/`
   - Builds AngularDart web app
   - Deploys to `/angular/` subdirectory

3. **Landing Page** (`.github/workflows/deploy-landing.yml`)
   - Creates a beautiful landing page with links to both apps
   - Deploys to root directory

### Setting Up GitHub Pages

1. Go to your repository **Settings** → **Pages**
2. Set **Source** to "Deploy from a branch"
3. Select **Branch**: `gh-pages` and **Folder**: `/ (root)`
4. Save the settings

The workflows will automatically create and manage the `gh-pages` branch.

## 🛠️ Development Workflow

### Local Development
```bash
# Start Flutter app (port 8082)
cd flutter_github_search
flutter run -d web-server --web-port 8082

# Start Angular app (port 8083)
cd angular_github_search
dart run build_runner serve web:8083
```

### Making Changes
1. Make changes to any project
2. Commit and push to main branch
3. GitHub Actions will automatically build and deploy
4. Check the live demos to see your changes

## 📁 Project Structure

```
github_search/
├── .github/                    # GitHub workflows and templates
│   ├── workflows/             # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/        # Issue templates
│   └── pull_request_template.md
├── common_github_search/       # 🎯 Clean Architecture Shared Library
│   ├── lib/src/
│   │   ├── core/              # Cross-cutting concerns (DI, utilities)
│   │   ├── domain/            # Business logic (entities, use cases, interfaces)
│   │   ├── data/              # External data access (repositories, data sources, DTOs)
│   │   └── presentation/      # UI logic (BLoC, events, states)
│   └── test/                  # Comprehensive test suite
├── flutter_github_search/      # 📱 Flutter web app
├── angular_github_search/      # 🅰️ AngularDart web app
├── CLEAN_ARCHITECTURE_AUDIT_REPORT.md     # Architecture compliance report
├── CLEAN_ARCHITECTURE_BEST_PRACTICES.md   # Implementation guidelines
└── README.md
```

### Clean Architecture Layers

#### 🎯 Domain Layer (`common_github_search/lib/src/domain/`)
- **Entities**: `GitHubRepository`, `GitHubUser`, `SearchCriteria` with business logic
- **Use Cases**: `SearchRepositoriesUseCase` for business operations
- **Repository Interfaces**: Abstract contracts for data access
- **Exceptions**: Domain-specific error types with proper mapping

#### 📊 Data Layer (`common_github_search/lib/src/data/`)
- **Repository Implementations**: Concrete data access with caching
- **Data Sources**: Remote (GitHub API) and Local (In-memory cache)
- **DTOs**: Data transfer objects for JSON serialization
- **Error Mapping**: Convert API errors to domain exceptions

#### 🎨 Presentation Layer (`common_github_search/lib/src/presentation/`)
- **BLoC Components**: Type-safe state management
- **Events/States**: Sealed classes for UI interactions
- **Error Handling**: User-friendly error messages

#### 🔧 Core Layer (`common_github_search/lib/src/core/`)
- **Dependency Injection**: Type-safe container with proper lifecycles
- **Utilities**: Shared helper functions and constants

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following [Clean Architecture Best Practices](CLEAN_ARCHITECTURE_BEST_PRACTICES.md)
4. Run analysis: `dart analyze` or `flutter analyze`
5. Run tests: `dart test` (in common_github_search directory)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Architecture Guidelines

- Follow the established layer boundaries (domain ← data, presentation → domain)
- Add business logic to domain entities, not DTOs
- Use dependency injection for all service dependencies
- Write tests for each layer following the existing patterns
- Maintain backward compatibility in the shared library exports

See [CLEAN_ARCHITECTURE_AUDIT_REPORT.md](CLEAN_ARCHITECTURE_AUDIT_REPORT.md) for current architecture status.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).