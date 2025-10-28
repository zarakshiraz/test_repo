# testing_repo

A new Flutter project with comprehensive Firebase security rules.

## Getting Started

This project is a starting point for a Flutter application with Firebase integration.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Security Rules

This project includes comprehensive security rules for Firestore and Cloud Storage with automated testing.

### Features

- **User-based access control** for all Firestore collections
- **Role-based permissions** for memberships (viewer, editor, admin)
- **Contact blocking** with enforcement across collections
- **Reminder ownership** with optional sharing
- **Storage rules** for avatars and audio files
- **58 automated tests** covering all security scenarios

### Running Security Tests

Install Node.js dependencies:
```bash
yarn install
# or
npm install
```

Run security tests:
```bash
yarn test:security
# or
npm run test:security
```

Alternatively, use the provided script:
```bash
./scripts/test-security.sh
```

### Documentation

See [docs/security-rules.md](docs/security-rules.md) for comprehensive documentation of the security model, including:
- Detailed permission rules for each collection
- Storage access patterns
- Testing guide
- Limitations and future enhancements
- Troubleshooting tips
