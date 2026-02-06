# CLAUDE.md - Cargo-GO

## Project Overview

Cargo-GO is a mobile logistics/cargo tracking application built with **React Native** targeting **Android** (and potentially iOS). The Android package name is `com.cargogoapp`.

## Tech Stack

- **Framework**: React Native
- **Platform**: Android (primary), iOS (planned/secondary)
- **Build System**: Gradle 8.13 (Android)
- **Language**: JavaScript/TypeScript (React Native), Java/Kotlin (Android native)
- **Package Manager**: npm or yarn (check for `yarn.lock` vs `package-lock.json`)

## Project Structure (Expected)

```
Cargo-GO/
├── android/                 # Android native project (Gradle-based)
│   ├── app/                 # Main Android app module
│   │   ├── src/main/        # Java/Kotlin source, AndroidManifest.xml
│   │   └── build.gradle     # App-level Gradle config
│   ├── build.gradle         # Project-level Gradle config
│   └── gradle.properties    # Gradle settings
├── ios/                     # iOS native project (if applicable)
├── src/                     # React Native JavaScript/TypeScript source
│   ├── components/          # Reusable UI components
│   ├── screens/             # Screen-level components
│   ├── navigation/          # Navigation configuration
│   ├── services/            # API calls, business logic
│   ├── store/               # State management
│   └── utils/               # Utility functions
├── __tests__/               # Test files
├── package.json             # Node.js dependencies and scripts
├── metro.config.js          # Metro bundler configuration
├── babel.config.js          # Babel transpiler configuration
├── app.json                 # React Native app configuration
├── index.js                 # App entry point
└── CLAUDE.md                # This file
```

## Development Commands

### Install Dependencies
```bash
npm install
# or
yarn install
```

### Run Android (Development)
```bash
npx react-native run-android
# or
npm run android
```

### Run iOS (Development)
```bash
npx react-native run-ios
# or
npm run ios
```

### Start Metro Bundler
```bash
npx react-native start
```

### Run Tests
```bash
npm test
# or
npx jest
```

### Lint
```bash
npm run lint
# or
npx eslint .
```

### Android Build (Release)
```bash
cd android && ./gradlew assembleRelease
```

## Key Conventions

### Code Style
- Follow standard React Native / JavaScript conventions
- Use functional components with hooks (preferred over class components)
- Keep components small and focused on a single responsibility
- Name component files in PascalCase (e.g., `CargoTracker.js`)
- Name utility/service files in camelCase (e.g., `apiService.js`)

### Git Workflow
- Work on feature branches, not directly on `main`
- Write clear, descriptive commit messages
- Keep commits atomic - one logical change per commit

### Android-Specific Notes
- Main Activity: `com.cargogoapp.MainActivity`
- Gradle version: 8.13 (deprecation warnings exist for Gradle 9.0 compatibility - these are non-blocking)
- Use `--warning-mode all` with Gradle to inspect individual deprecation warnings
- Android builds output reports to `android/build/reports/`

## Known Issues

- **Gradle deprecation warnings**: The build uses deprecated Gradle features incompatible with Gradle 9.0. Run with `--warning-mode all` to identify specific warnings. These come from plugins/dependencies and do not block builds currently.

## AI Assistant Guidelines

1. **Read before modifying** - Always read a file before suggesting changes to it.
2. **Preserve existing patterns** - Match the code style and conventions already used in the project.
3. **Minimal changes** - Only make changes directly relevant to the task. Avoid unnecessary refactoring.
4. **Test impact** - Consider whether changes need new tests or affect existing ones.
5. **Platform awareness** - Changes to native modules may require different handling on Android vs iOS.
6. **Dependencies** - Do not add new dependencies without justification. Prefer built-in React Native APIs when possible.
