# GitHub Workflows for HabitFlow

This directory contains GitHub Actions workflows for the HabitFlow Flutter application.

## 📋 Workflow Overview

### 1. **flutter_ci.yml** - Main CI/CD Pipeline
**Triggers:** Push to main/develop, Pull Requests

**Jobs:**
- ✅ **Test**: Code analysis, unit tests, integration tests
- 📱 **Build Android**: APK and App Bundle builds
- 🍎 **Build iOS**: iOS app build (macOS runner)
- 🌐 **Build Web**: Web application build
- 🔒 **Security Scan**: Dependency vulnerability checks
- 🚀 **Deploy Preview**: GitHub Pages deployment for PRs
- 📦 **Release**: Automatic GitHub releases
- 📢 **Notify**: Success/failure notifications

### 2. **flutter-test.yml** - Testing & Quality Focus
**Triggers:** Push to main/develop/feature/*, Pull Requests

**Jobs:**
- 🔍 **Quality Check**: Code analysis, formatting, unused imports
- 🧪 **Unit Tests**: Test execution with coverage
- 🔗 **Integration Tests**: End-to-end testing
- ⚡ **Performance Tests**: Performance benchmarking
- 🛡️ **Security Audit**: Security vulnerability scanning
- 📊 **Test Report**: Comprehensive test results summary

### 3. **flutter-deploy.yml** - Deployment Pipeline
**Triggers:** Tags (v*), Manual dispatch

**Jobs:**
- 🔢 **Version Bump**: Automatic version management
- 📱 **Build Android Release**: Production Android builds
- 🍎 **Build iOS Release**: Production iOS builds
- 🌐 **Build Web Release**: Production web builds
- 🔥 **Deploy Firebase**: Firebase Hosting deployment
- 📱 **Deploy App Store**: App Store Connect upload
- 📱 **Deploy Play Store**: Google Play Store upload
- 📦 **Create Release**: GitHub release with artifacts
- 📢 **Notify Deployment**: Deployment status notifications

### 4. **flutter-nightly.yml** - Nightly Builds
**Triggers:** Daily at 2 AM UTC, Manual dispatch

**Jobs:**
- 🧪 **Nightly Test Suite**: Full test execution with coverage
- 📦 **Nightly Build**: Multi-platform builds
- 📦 **Dependency Check**: Outdated package detection
- ⚡ **Performance Benchmark**: Performance testing
- 📊 **Nightly Report**: Daily build summary

## 🚀 Quick Start

### Prerequisites

1. **Repository Setup**
   ```bash
   # Ensure your repository has the correct branch structure
   git checkout -b main
   git push -u origin main
   ```

2. **Required Secrets**
   Add these secrets to your repository settings:
   
   **For Firebase Deployment:**
   - `FIREBASE_SERVICE_ACCOUNT`: Firebase service account JSON
   
   **For App Store Deployment:**
   - `APP_STORE_CONNECT_API_KEY`: App Store Connect API key
   - `APP_STORE_CONNECT_API_KEY_ID`: API key ID
   - `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID
   
   **For Play Store Deployment:**
   - `PLAY_STORE_SERVICE_ACCOUNT`: Google Play service account JSON

### Manual Deployment

1. **Create a Release**
   ```bash
   # Create and push a tag
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Manual Workflow Dispatch**
   - Go to Actions tab in GitHub
   - Select "Flutter Deploy" workflow
   - Click "Run workflow"
   - Choose release type and target platforms

## 📊 Workflow Features

### 🔄 Automated Testing
- **Code Analysis**: Flutter analyze with strict rules
- **Unit Tests**: Comprehensive test coverage
- **Integration Tests**: End-to-end functionality testing
- **Performance Tests**: App performance benchmarking
- **Security Audits**: Dependency vulnerability scanning

### 🏗️ Multi-Platform Builds
- **Android**: APK and App Bundle (.aab) files
- **iOS**: Xcode archive for App Store
- **Web**: Optimized web build for deployment

### 🚀 Deployment Options
- **Firebase Hosting**: Web app deployment
- **App Store Connect**: iOS app distribution
- **Google Play Store**: Android app distribution
- **GitHub Releases**: Artifact distribution

### 📈 Monitoring & Reporting
- **Coverage Reports**: Test coverage analysis
- **Performance Metrics**: App performance tracking
- **Security Reports**: Vulnerability assessments
- **Build Reports**: Comprehensive build summaries

## 🔧 Configuration

### Environment Variables
```yaml
env:
  FLUTTER_VERSION: '3.24.5'  # Flutter SDK version
```

### Branch Protection
Recommended branch protection rules:
- Require status checks to pass
- Require branches to be up to date
- Require pull request reviews
- Restrict pushes to matching branches

### Workflow Permissions
```yaml
permissions:
  contents: write      # For releases
  pages: write         # For GitHub Pages
  id-token: write      # For OIDC
```

## 📝 Customization

### Adding New Jobs
1. Create a new job in the appropriate workflow file
2. Define the runner and steps
3. Add dependencies using `needs:`
4. Configure triggers and conditions

### Modifying Build Steps
```yaml
- name: Custom Build Step
  run: |
    flutter build apk --release
    # Add custom post-processing
    cp build/app/outputs/flutter-apk/app-release.apk custom-name.apk
```

### Adding New Platforms
1. Add platform-specific build job
2. Configure appropriate runner (ubuntu/macos/windows)
3. Add deployment steps for the platform
4. Update release job to include new artifacts

## 🐛 Troubleshooting

### Common Issues

**Build Failures:**
- Check Flutter version compatibility
- Verify all dependencies are properly declared
- Review error logs for specific issues

**Deployment Failures:**
- Verify secrets are correctly configured
- Check platform-specific requirements
- Review deployment permissions

**Test Failures:**
- Run tests locally to reproduce issues
- Check for flaky tests
- Review test coverage reports

### Debug Workflows
1. Enable debug logging in workflow runs
2. Check artifact uploads/downloads
3. Verify runner environment
4. Review step-by-step execution logs

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/ci)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [App Store Connect](https://developer.apple.com/app-store-connect/)
- [Google Play Console](https://play.google.com/console)

## 🤝 Contributing

When contributing to workflows:
1. Test changes locally first
2. Use feature branches for modifications
3. Update documentation for new features
4. Follow existing naming conventions
5. Add appropriate error handling

---

**Last Updated:** $(date)
**Version:** 1.0.0 