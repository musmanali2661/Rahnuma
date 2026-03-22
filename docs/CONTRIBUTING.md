# Contributing to Rahnuma

Thank you for your interest in contributing to Rahnuma! This document outlines our contribution guidelines.

---

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork: `git clone https://github.com/<your-username>/Rahnuma.git`
3. Set up the development environment (see README.md)
4. Create a feature branch: `git checkout -b feature/my-feature`

---

## Development Workflow

### Backend

```bash
cd backend
npm install
npm run dev   # starts with nodemon hot-reload
npm test      # run Jest tests
```

### Web

```bash
cd web
npm install
npm run dev   # Vite dev server
npm test      # Vitest
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
flutter test
```

---

## Code Standards

### JavaScript / Node.js
- Use `'use strict'` at the top of all Node.js files
- Follow ESLint rules (run `npm run lint`)
- Use `async/await` over raw callbacks
- Handle errors with proper try/catch blocks

### Dart / Flutter
- Follow Dart effective style guide
- Use Riverpod for state management
- Use GoRouter for navigation
- Write widget tests for all screens

### Python
- Follow PEP 8
- Use type hints
- Write docstrings for all public functions

---

## Submitting a Pull Request

1. Ensure all tests pass: `npm test` / `flutter test`
2. Run linters: `npm run lint`
3. Write a clear PR description explaining what changed and why
4. Reference related issues: `Closes #123`
5. Wait for a review from a maintainer

---

## Reporting Issues

When filing a bug report, please include:
- Operating system and version
- Flutter/Node.js/Python version
- Steps to reproduce
- Expected vs actual behaviour
- Relevant logs

---

## Urdu Language Support

When adding user-facing strings:
1. Add the English string to `backend/src/utils/` or `web/src/utils/urduHelper.js`
2. Add the Urdu translation in the same file
3. For mobile, add to `mobile/lib/core/constants/strings.dart`

---

## Licence

By contributing, you agree that your contributions will be licensed under the MIT License.
