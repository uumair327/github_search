[![build](https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg)](https://github.com/felangel/bloc/actions)
[![Flutter Deploy](https://github.com/umairelyx/github_search/actions/workflows/deploy-flutter.yml/badge.svg)](https://github.com/umairelyx/github_search/actions/workflows/deploy-flutter.yml)
[![Angular Deploy](https://github.com/umairelyx/github_search/actions/workflows/deploy-angular.yml/badge.svg)](https://github.com/umairelyx/github_search/actions/workflows/deploy-angular.yml)

# Github Search

Sample project which illustrates how to setup a Flutter and AngularDart project with code sharing.

## 🚀 Live Demos

- **🌐 Landing Page**: [https://umairelyx.github.io/github_search/](https://umairelyx.github.io/github_search/)
- **📱 Flutter Version**: [https://umairelyx.github.io/github_search/flutter/](https://umairelyx.github.io/github_search/flutter/)
- **🅰️ Angular Version**: [https://umairelyx.github.io/github_search/angular/](https://umairelyx.github.io/github_search/angular/)



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
├── common_github_search/       # Shared Dart library
├── flutter_github_search/      # Flutter web app
├── angular_github_search/      # AngularDart web app
└── README.md
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run analysis: `dart analyze` or `flutter analyze`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).