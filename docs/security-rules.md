# Security Rules Documentation

This document describes the comprehensive security model implemented for Firestore and Cloud Storage in this application.

## Overview

The security rules enforce strict user-based access control across all collections and storage paths. The rules are designed to:
- Protect user data privacy
- Enforce ownership permissions
- Support collaborative features with role-based access
- Prevent unauthorized access to sensitive data
- Block access between blocked users

## Firestore Security Rules

### Users Collection

**Path:** `/users/{userId}`

**Permissions:**
- **Read:** Users can only read their own user document
- **Create:** Users can create their own user document with required fields (`email`, `createdAt`)
- **Update:** Users can update their own data, but cannot modify the `createdAt` field
- **Delete:** Users can delete their own user document

**Required Fields on Create:**
- `email` (string)
- `createdAt` (timestamp)

**Validation:**
- The authenticated user's UID must match the document ID
- The `createdAt` field is immutable after creation

### Memberships Collection

**Path:** `/memberships/{membershipId}`

**Permissions:**
- **Read:** Owner or any member with a role (`viewer`, `editor`, `admin`)
- **Create:** Authenticated users can create memberships they own
- **Update:** 
  - Owner can update anything
  - Editors/admins can update content but not ownership or member permissions
- **Delete:** Only the owner can delete

**Required Fields on Create:**
- `userId` (string) - must match authenticated user's UID
- `createdAt` (timestamp)
- `members` (map) - object containing member roles

**Roles:**
- `viewer`: Read-only access
- `editor`: Can read and update content (not ownership)
- `admin`: Can read and update content (not ownership)

**Protected Fields:**
- `userId` - cannot be changed after creation
- `createdAt` - cannot be changed after creation

### Contacts Collection

**Path:** `/contacts/{userId}`

**Permissions:**
- **Read:** Owner only
- **Write:** Owner only

**Blocked Subcollection:**

**Path:** `/contacts/{userId}/blocked/{blockedUserId}`

**Permissions:**
- **Read:** Owner only (the user who blocked)
- **Create:** Owner can block any user with required `blockedAt` timestamp
- **Delete:** Owner can unblock users

**Required Fields on Create:**
- `blockedAt` (timestamp)

**Use Cases:**
- Users can maintain a private list of blocked contacts
- Blocked relationships are enforced in other collections (e.g., reminders)

### Reminders Collection

**Path:** `/reminders/{reminderId}`

**Permissions:**
- **Read:**
  - Owner can always read
  - Users in `sharedWith` array can read if:
    - They haven't been blocked by the owner
    - They haven't blocked the owner
- **Create:** Authenticated users can create reminders they own with required fields
- **Update:** Only owner can update (excluding protected fields)
- **Delete:** Only owner can delete

**Required Fields on Create:**
- `userId` (string) - must match authenticated user's UID
- `title` (string)
- `createdAt` (timestamp)

**Optional Fields:**
- `sharedWith` (array) - list of user IDs who can view the reminder

**Protected Fields:**
- `userId` - cannot be changed after creation
- `createdAt` - cannot be changed after creation

**Block Enforcement:**
- If user A blocks user B, B cannot read A's reminders even if shared
- If user B blocks user A, B cannot read A's shared reminders

## Cloud Storage Security Rules

### Avatar Storage

**Path:** `/avatars/{userId}/{fileName}`

**Permissions:**
- **Read:** Any authenticated user (avatars are publicly visible to logged-in users)
- **Write:** Only the owner (userId must match authenticated UID)
- **Delete:** Only the owner

**Validation:**
- Content type must be `image/*`
- Maximum file size: 5 MB

**Use Cases:**
- User profile pictures
- Public user avatars visible to other authenticated users

### Audio Storage

**Path:** `/audio/{userId}/{fileName}`

**Permissions:**
- **Read:** Only the owner
- **Write:** Only the owner (userId must match authenticated UID)
- **Delete:** Only the owner

**Validation:**
- Content type must be `audio/*`
- Maximum file size: 10 MB

**Use Cases:**
- Voice memos
- Audio recordings
- Private audio content

### Default Deny

All other storage paths are denied by default. Any files outside of `/avatars/{userId}/` and `/audio/{userId}/` cannot be accessed.

## Testing

### Running Tests

The security rules are tested using the Firebase Emulator Suite with comprehensive automated tests.

**Run all security tests:**
```bash
yarn test:security
```

**Start emulators manually:**
```bash
yarn emulators:start
```

### Test Coverage

The test suite covers:

1. **Users Collection (10 tests)**
   - Authentication requirements
   - Owner-only access
   - Field validation
   - Immutable field protection

2. **Memberships Collection (10 tests)**
   - Role-based access (viewer, editor, admin)
   - Ownership validation
   - Update restrictions per role
   - Deletion permissions

3. **Contacts Collection (10 tests)**
   - Owner-only access
   - Blocking/unblocking
   - Privacy protection
   - Field validation

4. **Reminders Collection (14 tests)**
   - Owner access
   - Shared access with block enforcement
   - Field validation
   - Update and delete permissions

5. **Storage Rules (14 tests)**
   - Avatar upload/download/delete
   - Audio upload/download/delete
   - Content type validation
   - File size limits
   - Cross-user access restrictions

**Total: 58 automated tests**

## CI Integration

Security tests are integrated into the development workflow:

1. Tests run locally via `yarn test:security`
2. Firebase emulators are started automatically
3. All test suites run sequentially
4. Tests exit with proper status codes for CI integration

## Security Model Architecture

```
┌─────────────────────────────────────────────┐
│          Authentication Layer                │
│  (Firebase Auth - Required for all access)  │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐    ┌────────▼──────┐
│   Firestore    │    │    Storage    │
│     Rules      │    │     Rules     │
└───────┬────────┘    └────────┬──────┘
        │                      │
  ┌─────┴──────┬──────────┐   │
  │            │          │   │
  ▼            ▼          ▼   ▼
Users    Memberships  Reminders  Avatars/Audio
(Owner)  (Role-based) (Owner+    (Owner-based)
                       Shared)
```

## Limitations and Considerations

### Current Limitations

1. **Shared Reminders Read-Only:**
   - Users in the `sharedWith` array can only read reminders, not edit them
   - Future enhancement: Add `sharedWithPermissions` map for granular sharing

2. **Block Checks:**
   - Block checks in reminders require additional Firestore reads
   - This may impact read costs for shared reminders
   - Consider caching block status in client application

3. **Membership Roles:**
   - Current implementation has basic role distinction (viewer vs editor)
   - Future enhancement: More granular permissions per role

4. **Storage Quotas:**
   - File size limits are enforced (5MB avatars, 10MB audio)
   - No per-user total storage quota enforcement
   - Consider implementing usage tracking

5. **No Admin Override:**
   - No built-in admin user capability to access all data
   - Future enhancement: Add admin role support

### Best Practices

1. **Authentication First:**
   - Always ensure users are authenticated before accessing any data
   - Handle authentication state changes gracefully in the app

2. **Client-Side Validation:**
   - Implement client-side validation matching server rules
   - Provide user feedback before rule violations occur

3. **Error Handling:**
   - Handle permission denied errors gracefully
   - Provide appropriate user feedback

4. **Block Status Caching:**
   - Cache block relationships on the client to reduce reads
   - Refresh cache periodically or on user action

5. **Testing:**
   - Run security tests before deploying rules
   - Test edge cases in your application code

## Future Enhancements

- [ ] Add support for organization/team-level permissions
- [ ] Implement admin role with elevated permissions
- [ ] Add audit logging for sensitive operations
- [ ] Support for temporary access links with expiration
- [ ] Granular sharing permissions (read/write) for reminders
- [ ] Storage usage quotas per user
- [ ] Rate limiting for sensitive operations
- [ ] Support for file type validation beyond content type checks
- [ ] Automated security rule testing in CI/CD pipeline
- [ ] Performance monitoring for rule evaluation

## Deployment

**Deploy Firestore rules:**
```bash
firebase deploy --only firestore:rules
```

**Deploy Storage rules:**
```bash
firebase deploy --only storage
```

**Deploy all rules:**
```bash
firebase deploy --only firestore:rules,storage
```

## Support and Troubleshooting

### Common Issues

**Issue: "Permission denied" errors**
- Verify the user is authenticated
- Check that the user ID matches the document/path being accessed
- Ensure required fields are present on create/update

**Issue: Tests failing**
- Ensure Firebase emulators are running
- Check that emulator ports are not in use (8080, 9099, 9199)
- Clear emulator data and retry

**Issue: Rules not applying**
- Ensure rules are deployed: `firebase deploy --only firestore:rules,storage`
- Check Firebase console for rule deployment status
- Verify you're testing against the correct Firebase project

### Getting Help

- Review Firebase Security Rules documentation
- Check test output for specific failure reasons
- Use Firebase emulator UI (http://localhost:4000) to inspect data
- Enable debug logging in tests for detailed rule evaluation

## Version History

- **v1.0.0** - Initial implementation with comprehensive user-based access control
  - Users, Memberships, Contacts, Reminders collections
  - Avatar and Audio storage
  - 58 automated tests
  - Full documentation
