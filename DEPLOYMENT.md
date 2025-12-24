# 🚀 Deployment Guide

This guide explains how to set up GitHub Pages deployment for the GitHub Search project.

## 📋 Prerequisites

- GitHub repository with the project code
- GitHub account with repository admin access
- Git installed locally

## 🔧 Setup Instructions

### 1. Repository Setup

1. **Fork or Clone** this repository to your GitHub account
2. **Update URLs** in the following files with your GitHub username:
   - `README.md` - Replace `YOUR_USERNAME` with your actual GitHub username
   - `.github/workflows/deploy-landing.yml` - Update the source code link

### 2. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select "Deploy from a branch"
4. Choose **Branch**: `gh-pages` and **Folder**: `/ (root)`
5. Click **Save**

### 3. Configure Repository Secrets (Optional)

The workflows use `GITHUB_TOKEN` which is automatically provided by GitHub Actions. No additional secrets are required.

### 4. Trigger First Deployment

1. Make any small change to the code (e.g., update README.md)
2. Commit and push to the `main` or `master` branch:
   ```bash
   git add .
   git commit -m "Initial deployment setup"
   git push origin main
   ```

3. Check the **Actions** tab in your GitHub repository to monitor the deployment progress

## 📁 Deployment Structure

After successful deployment, your GitHub Pages site will have:

```
https://YOUR_USERNAME.github.io/github_search/
├── index.html                 # Landing page
├── flutter/                   # Flutter app
│   ├── index.html
│   ├── main.dart.js
│   └── ...
└── angular/                   # Angular app
    ├── index.html
    ├── main.dart.js
    └── ...
```

## 🔄 Automatic Deployments

The project includes three GitHub Actions workflows:

### 1. **Landing Page Deployment** (`.github/workflows/deploy-landing.yml`)
- **Triggers**: On every push to main/master
- **Creates**: Beautiful landing page with links to both apps
- **Deploys to**: Root directory (`/`)

### 2. **Flutter Deployment** (`.github/workflows/deploy-flutter.yml`)
- **Triggers**: On changes to `flutter_github_search/` or `common_github_search/`
- **Builds**: Flutter web app with proper base href
- **Deploys to**: `/flutter/` subdirectory

### 3. **Angular Deployment** (`.github/workflows/deploy-angular.yml`)
- **Triggers**: On changes to `angular_github_search/` or `common_github_search/`
- **Builds**: AngularDart web app
- **Deploys to**: `/angular/` subdirectory

### 4. **Test & Analysis** (`.github/workflows/test.yml`)
- **Triggers**: On all pushes and pull requests
- **Runs**: Static analysis and formatting checks
- **Purpose**: Ensures code quality before deployment

## 🛠️ Local Testing

Before pushing changes, test locally:

### Flutter App
```bash
cd flutter_github_search
flutter run -d web-server --web-port 8080
```

### Angular App
```bash
cd angular_github_search
dart run build_runner serve web:8081
```

### Build Testing
```bash
# Test Flutter build
cd flutter_github_search
flutter build web --release

# Test Angular build (may take a while)
cd angular_github_search
dart run build_runner build web --release --output web:build --delete-conflicting-outputs
```

## 🐛 Troubleshooting

### Common Issues

1. **Deployment Failed**
   - Check the Actions tab for error details
   - Ensure all dependencies are properly specified in pubspec.yaml files
   - Verify that the base href is correctly set

2. **Apps Not Loading**
   - Check browser console for errors
   - Verify that the base href matches your repository structure
   - Ensure all assets are properly referenced

3. **Build Timeout (Angular)**
   - Angular builds can take 5-10 minutes
   - If builds consistently fail, check for dependency conflicts
   - Consider using `--delete-conflicting-outputs` flag

### Debug Steps

1. **Check Workflow Logs**
   ```
   GitHub Repository → Actions → Select failed workflow → View logs
   ```

2. **Test Locally**
   ```bash
   # Run analysis
   dart analyze
   flutter analyze
   
   # Check formatting
   dart format --set-exit-if-changed .
   ```

3. **Manual Build Test**
   ```bash
   # Test the exact commands used in CI
   cd flutter_github_search
   flutter build web --release --base-href="/github_search/flutter/"
   ```

## 🔄 Updating Deployments

### Automatic Updates
- Push changes to `main`/`master` branch
- Workflows automatically detect changes and redeploy affected apps

### Manual Deployment
- Go to **Actions** tab in GitHub
- Select the workflow you want to run
- Click **Run workflow** → **Run workflow**

## 📊 Monitoring

### Deployment Status
- **GitHub Actions**: Monitor build and deployment status
- **GitHub Pages**: Check deployment status in repository settings

### Live Sites
- **Landing Page**: `https://YOUR_USERNAME.github.io/github_search/`
- **Flutter App**: `https://YOUR_USERNAME.github.io/github_search/flutter/`
- **Angular App**: `https://YOUR_USERNAME.github.io/github_search/angular/`

## 🎯 Performance Tips

1. **Optimize Build Times**
   - Use dependency caching in workflows
   - Only trigger builds when relevant files change

2. **Reduce Bundle Size**
   - Use `--release` flag for production builds
   - Enable tree-shaking and minification

3. **Monitor Resource Usage**
   - GitHub Actions has usage limits
   - Optimize workflows to reduce build time

## 📝 Customization

### Modify Landing Page
Edit `.github/workflows/deploy-landing.yml` to customize the landing page HTML.

### Add New Workflows
Create additional `.yml` files in `.github/workflows/` for custom deployment scenarios.

### Update Base URLs
Modify the base href values in:
- `flutter_github_search/web/index.html`
- `angular_github_search/web/index.html`
- Workflow files for build commands

---

🎉 **Congratulations!** Your GitHub Search project is now set up for automatic deployment to GitHub Pages!