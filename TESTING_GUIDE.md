# Security Rules Testing Guide

## Quick Start

### Install Dependencies
```bash
yarn install
```
or
```bash
npm install
```

### Run All Security Tests
```bash
yarn test:security
```
or
```bash
npm run test:security
```
or
```bash
./scripts/test-security.sh
```

## Test Suites

The test suite consists of 58 automated tests across 5 test files:

### 1. Users Collection Tests (10 tests)
**File:** `test/security/firestore-users.test.js`

Tests user-based access control:
- ✓ Authentication requirements
- ✓ Owner-only read/write
- ✓ Field validation
- ✓ Immutable fields
- ✓ Cross-user access denial

### 2. Memberships Collection Tests (10 tests)
**File:** `test/security/firestore-memberships.test.js`

Tests role-based permissions:
- ✓ Owner permissions
- ✓ Viewer role (read-only)
- ✓ Editor role (read + limited write)
- ✓ Admin role permissions
- ✓ Ownership protection

### 3. Contacts/Blocking Tests (10 tests)
**File:** `test/security/firestore-contacts.test.js`

Tests contact management and blocking:
- ✓ Owner-only access
- ✓ Blocking functionality
- ✓ Unblocking functionality
- ✓ Privacy protection
- ✓ Subcollection access

### 4. Reminders Collection Tests (14 tests)
**File:** `test/security/firestore-reminders.test.js`

Tests reminder ownership and sharing:
- ✓ Owner access
- ✓ Shared user access
- ✓ Block enforcement (both directions)
- ✓ Field validation
- ✓ Update restrictions

### 5. Storage Rules Tests (14 tests)
**File:** `test/security/storage.test.js`

Tests file storage permissions:
- ✓ Avatar upload/read/delete
- ✓ Audio upload/read/delete
- ✓ Content type validation
- ✓ File size limits
- ✓ Cross-user restrictions

## Manual Testing

### Start Emulators
```bash
yarn emulators:start
```

This starts:
- Firestore Emulator (port 8080)
- Storage Emulator (port 9199)
- Auth Emulator (port 9099)
- Emulator UI (port 4000)

Visit http://localhost:4000 to use the Emulator UI.

### Run Individual Tests

With emulators running, you can run individual test files:

```bash
node test/security/firestore-users.test.js
node test/security/firestore-memberships.test.js
node test/security/firestore-contacts.test.js
node test/security/firestore-reminders.test.js
node test/security/storage.test.js
```

## Verification

Verify all components are in place:

```bash
./scripts/verify-implementation.sh
```

This checks:
- Required files exist
- No TODO placeholders in rules
- Documentation is comprehensive
- Test files are present
- NPM scripts are configured

## Test Output

Successful test run will show:

```
🔒 Running Firebase Security Rules Tests...

📝 Running firestore-users.test.js...

🔐 Testing Users Collection Rules...
  ✓ Unauthenticated users cannot read user data
  ✓ Users can read their own data
  ✓ Users cannot read other users' data
  ... (more tests)

10/10 tests passed
✅ firestore-users.test.js passed

... (more test files)

==================================================
✅ All security rules tests passed!
```

## Debugging Failed Tests

### Enable Verbose Logging

Edit test files to add logging:
```javascript
console.log('Test data:', testData);
```

### Check Emulator UI

1. Start emulators: `yarn emulators:start`
2. Open http://localhost:4000
3. Navigate to Firestore or Storage tabs
4. Inspect data and check rule evaluations

### Check Emulator Logs

Look for detailed error messages in:
- `firebase-debug.log`
- `firestore-debug.log`
- Terminal output

### Common Issues

**Issue: Port already in use**
```bash
# Kill processes on required ports
lsof -ti:8080,9099,9199,4000 | xargs kill
```

**Issue: Tests hang**
- Ensure emulators are running
- Check for syntax errors in rules files
- Verify test cleanup functions are called

**Issue: Permission denied**
- Check authentication context in test
- Verify rule logic for the scenario
- Review field names and data structure

## CI Integration

### GitHub Actions

Add to `.github/workflows/test.yml`:

```yaml
- name: Run security tests
  run: yarn test:security
```

### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
security-tests:
  script:
    - yarn install
    - yarn test:security
```

### Other CI Systems

The tests work with any CI system that supports:
- Node.js >= 18.0.0
- Ability to run npm/yarn commands
- No special Firebase credentials needed (uses emulators)

## Expected Results

When all tests pass, you'll see:

- ✅ All 58 tests passing
- ✅ No rule violations
- ✅ All scenarios covered
- ✅ Exit code 0

This confirms that:
1. Rules are syntactically correct
2. Permissions are properly enforced
3. All access patterns work as documented
4. Security model is production-ready

## Further Reading

- Full security documentation: `docs/security-rules.md`
- Test implementation details: `test/security/README.md`
- Implementation summary: `SECURITY_IMPLEMENTATION.md`
- Completion checklist: `IMPLEMENTATION_COMPLETE.md`

## Support

For questions or issues:
1. Review the documentation in `docs/security-rules.md`
2. Check test output for specific error messages
3. Use Emulator UI for manual verification
4. Review Firebase Security Rules documentation
