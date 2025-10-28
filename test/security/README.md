# Firebase Security Rules Tests

This directory contains automated tests for Firebase Firestore and Cloud Storage security rules.

## Overview

The tests use the Firebase Emulator Suite and the `@firebase/rules-unit-testing` package to verify that security rules are correctly enforced.

## Test Files

- `test-helpers.js` - Utility functions for setting up test environment and running tests
- `run-tests.js` - Main test runner that executes all test suites
- `firestore-users.test.js` - Tests for Users collection rules (10 tests)
- `firestore-memberships.test.js` - Tests for Memberships collection rules (10 tests)
- `firestore-contacts.test.js` - Tests for Contacts/Blocking collection rules (10 tests)
- `firestore-reminders.test.js` - Tests for Reminders collection rules (14 tests)
- `storage.test.js` - Tests for Storage rules (14 tests)

## Running Tests

### Prerequisites

1. Install Node.js (>= 18.0.0)
2. Install dependencies:
   ```bash
   yarn install
   # or
   npm install
   ```

### Run All Tests

```bash
yarn test:security
```

This will:
1. Start the Firebase emulators
2. Run all test suites
3. Display results
4. Stop the emulators
5. Exit with appropriate status code

### Run Individual Test Files

You can also run individual test files while the emulators are running:

```bash
# Start emulators in one terminal
yarn emulators:start

# In another terminal, run specific tests
node test/security/firestore-users.test.js
node test/security/firestore-memberships.test.js
node test/security/firestore-contacts.test.js
node test/security/firestore-reminders.test.js
node test/security/storage.test.js
```

## Test Structure

Each test file follows this pattern:

1. Import test helpers
2. Set up test environment
3. Run test cases using `runTest()` helper
4. Track pass/fail counts
5. Clean up environment
6. Exit with appropriate status

Example test:
```javascript
if (await runTest('User can read their own data', async () => {
  await clearFirestore();
  const db = getAuthenticatedContext('user1').firestore();
  await db.collection('users').doc('user1').set({
    email: 'user1@example.com',
    createdAt: serverTimestamp()
  });
  
  await assertSucceeds(db.collection('users').doc('user1').get());
})) passedTests++;
```

## Test Coverage

### Firestore Users Collection (10 tests)
- ✓ Authentication requirements
- ✓ Owner-only read/write access
- ✓ Field validation on create
- ✓ Immutable field protection
- ✓ Cross-user access denial

### Firestore Memberships Collection (10 tests)
- ✓ Role-based access (viewer, editor, admin)
- ✓ Owner permissions
- ✓ Member read permissions
- ✓ Editor update restrictions
- ✓ Owner-only deletion

### Firestore Contacts Collection (10 tests)
- ✓ Owner-only access to contacts
- ✓ Blocking functionality
- ✓ Unblocking functionality
- ✓ Privacy protection
- ✓ Field validation

### Firestore Reminders Collection (14 tests)
- ✓ Owner read/write/delete
- ✓ Shared user read access
- ✓ Block enforcement (both directions)
- ✓ Field validation
- ✓ Immutable field protection
- ✓ Unauthenticated access denial

### Storage Rules (14 tests)
- ✓ Avatar upload/read/delete permissions
- ✓ Audio upload/read/delete permissions
- ✓ Content type validation
- ✓ File size limits
- ✓ Cross-user access restrictions
- ✓ Default deny for unknown paths

## Adding New Tests

To add new tests:

1. Create a new test file (e.g., `firestore-newcollection.test.js`)
2. Follow the existing test file structure
3. Add the test file to `run-tests.js` in the `testFiles` array
4. Run tests to verify

## Debugging Tests

### Enable Verbose Logging

You can add debug logging to tests:
```javascript
console.log('Test data:', testData);
```

### Use Firebase Emulator UI

When running emulators manually (`yarn emulators:start`), access the UI at:
http://localhost:4000

This allows you to:
- Inspect Firestore data
- View Storage files
- Monitor Auth users
- Debug rule evaluation

### Common Issues

**Port Already in Use:**
- Kill processes using ports 8080, 9099, 9199, 4000
- Or modify ports in `firebase.json`

**Tests Hanging:**
- Ensure `cleanupTestEnvironment()` is called
- Check for unhandled promises
- Verify emulators are running

**Permission Errors:**
- Verify rules files are present (`firestore.rules`, `storage.rules`)
- Check that test users have correct authentication context
- Review rule logic for the failing scenario

## CI Integration

These tests are designed to run in CI environments:

1. Install dependencies
2. Run `yarn test:security`
3. Tests will start/stop emulators automatically
4. Exit code 0 = success, 1 = failure

Example GitHub Actions workflow:
```yaml
- name: Install dependencies
  run: yarn install

- name: Run security tests
  run: yarn test:security
```

## Best Practices

1. **Clean up between tests:** Use `clearFirestore()` or `clearStorage()`
2. **Use unique IDs:** Avoid test data collisions
3. **Test both success and failure:** Use `assertSucceeds()` and `assertFails()`
4. **Test edge cases:** Blocked users, unauthenticated access, etc.
5. **Keep tests focused:** One concept per test
6. **Use descriptive test names:** Make failures easy to understand

## Resources

- [Firebase Rules Unit Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
