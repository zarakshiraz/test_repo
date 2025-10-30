# Contributing to Grocli

Thank you for your interest in contributing to Grocli! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all.

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2+
- Git
- Firebase account
- Code editor (VS Code or Android Studio recommended)

### Setup Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/yourusername/grocli.git
   cd grocli
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Follow instructions in [SETUP_GUIDE.md](SETUP_GUIDE.md)

4. **Generate Code**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## Development Process

### Branching Strategy

We use a simplified Git Flow:

- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

### Creating a Branch

```bash
# Feature
git checkout -b feature/your-feature-name

# Bug fix
git checkout -b bugfix/issue-123

# Hotfix
git checkout -b hotfix/critical-bug
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(lists): add voice input for list creation
fix(auth): resolve Google sign-in crash on Android
docs(readme): update setup instructions
```

## Pull Request Process

### Before Submitting

1. **Update Your Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout your-branch
   git rebase develop
   ```

2. **Run Tests**
   ```bash
   flutter test
   flutter analyze
   ```

3. **Check Code Style**
   ```bash
   flutter format .
   ```

### Submitting a PR

1. **Push Your Branch**
   ```bash
   git push origin your-branch
   ```

2. **Create Pull Request**
   - Go to GitHub and create a PR
   - Use descriptive title and description
   - Link related issues
   - Add screenshots/videos if UI changes

3. **PR Template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   Describe testing done
   
   ## Screenshots
   (if applicable)
   
   ## Checklist
   - [ ] Tests pass
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] No breaking changes
   ```

### Review Process

- At least one approval required
- All CI checks must pass
- Address all review comments
- Keep PR scope focused

## Coding Standards

### Dart/Flutter

1. **Follow Effective Dart**
   - [Style Guide](https://dart.dev/guides/language/effective-dart/style)
   - [Documentation Guide](https://dart.dev/guides/language/effective-dart/documentation)
   - [Usage Guide](https://dart.dev/guides/language/effective-dart/usage)

2. **File Organization**
   ```dart
   // Imports
   import 'package:flutter/material.dart';  // Flutter
   import 'package:provider/provider.dart';  // Packages
   import '../models/user.dart';             // Relative
   
   // Constants
   const String kAppName = 'Grocli';
   
   // Classes
   class MyWidget extends StatelessWidget {
     // Public fields
     final String title;
     
     // Constructor
     const MyWidget({required this.title});
     
     // Public methods
     @override
     Widget build(BuildContext context) {
       return Container();
     }
     
     // Private methods
     void _helperMethod() {}
   }
   ```

3. **Naming Conventions**
   - Classes: `PascalCase`
   - Variables/methods: `camelCase`
   - Constants: `lowerCamelCase` with `k` prefix
   - Private members: prefix with `_`

4. **Widget Best Practices**
   - Extract widgets for reusability
   - Use `const` constructors when possible
   - Prefer `StatelessWidget` over `StatefulWidget`
   - Keep `build` methods small

5. **State Management**
   - Use Provider for dependency injection
   - Follow single responsibility principle
   - Avoid god objects
   - Keep business logic in providers

### Code Quality

1. **Comments**
   ```dart
   /// Document public APIs with triple-slash comments
   /// 
   /// This method does something important.
   void publicMethod() {}
   
   // Regular comments for implementation details
   void _privateMethod() {
     // Explain complex logic
   }
   ```

2. **Error Handling**
   ```dart
   try {
     await riskyOperation();
   } catch (e) {
     debugPrint('Error: $e');
     // Handle gracefully
   }
   ```

3. **Null Safety**
   - Use null-safe Dart
   - Avoid `!` operator when possible
   - Use null-aware operators (`??`, `?.`)

## Testing Guidelines

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates valid user', () {
      final json = {'id': '1', 'name': 'Test'};
      final user = User.fromJson(json);
      
      expect(user.id, '1');
      expect(user.name, 'Test');
    });
  });
}
```

### Widget Tests

```dart
testWidgets('Login button works', (tester) async {
  await tester.pumpWidget(MyApp());
  
  final button = find.byType(ElevatedButton);
  expect(button, findsOneWidget);
  
  await tester.tap(button);
  await tester.pump();
  
  // Verify result
});
```

### Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow', (tester) async {
    // Test full user journey
  });
}
```

### Test Coverage

- Aim for >80% coverage
- Test edge cases
- Test error scenarios
- Mock external dependencies

## Documentation

### Code Documentation

1. **Public APIs**
   - All public classes, methods, properties
   - Include usage examples
   - Describe parameters and return values

2. **README Files**
   - Each feature module should have a README
   - Explain architecture decisions
   - Include diagrams if helpful

3. **Changelog**
   - Update CHANGELOG.md for all changes
   - Follow semantic versioning

### Comments

- Explain **why**, not **what**
- Keep comments up-to-date
- Remove commented-out code
- Use TODOs sparingly with issue numbers

```dart
// TODO(#123): Implement error retry logic
```

## Feature Development

### Adding a New Feature

1. **Create Issue**
   - Describe feature
   - Add acceptance criteria
   - Label appropriately

2. **Design**
   - UI mockups (if applicable)
   - Architecture design
   - Data models

3. **Implementation**
   - Create feature branch
   - Write tests first (TDD)
   - Implement feature
   - Update documentation

4. **Review**
   - Self-review code
   - Run all tests
   - Submit PR

### Adding Dependencies

1. **Evaluate Need**
   - Is it necessary?
   - Is it maintained?
   - License compatible?

2. **Add to pubspec.yaml**
   ```yaml
   dependencies:
     package_name: ^version
   ```

3. **Document Usage**
   - Update README
   - Add usage examples

## Reporting Bugs

### Bug Report Template

```markdown
**Describe the bug**
Clear description

**To Reproduce**
Steps to reproduce

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Device Info**
- Device:
- OS:
- App Version:

**Additional context**
Any other info
```

## Feature Requests

### Feature Request Template

```markdown
**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives Considered**
Other approaches

**Additional Context**
Mockups, examples, etc.
```

## Getting Help

- **Discord**: Join our community
- **GitHub Discussions**: Ask questions
- **Email**: dev@grocli.app

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Featured on our website

Thank you for contributing! 🎉
