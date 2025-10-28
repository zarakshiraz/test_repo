const {
  setupTestEnvironment,
  cleanupTestEnvironment,
  getAuthenticatedContext,
  getUnauthenticatedContext,
  runTest,
  clearFirestore,
  assertFails,
  assertSucceeds
} = require('./test-helpers');

const { serverTimestamp } = require('firebase/firestore');

async function runRemindersTests() {
  console.log('\n⏰ Testing Reminders Collection Rules...');
  
  await setupTestEnvironment();
  
  let passedTests = 0;
  let totalTests = 0;
  
  // Test 1: Owner can read their own reminder
  totalTests++;
  if (await runTest('Owner can read their own reminder', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(db.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  // Test 2: Non-owner cannot read reminder
  totalTests++;
  if (await runTest('Non-owner cannot read reminder', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  // Test 3: Shared user can read reminder
  totalTests++;
  if (await runTest('Shared user can read reminder', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp(),
      sharedWith: ['user2']
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertSucceeds(db2.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  // Test 4: Blocked user cannot read shared reminder
  totalTests++;
  if (await runTest('Blocked user cannot read shared reminder', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
      blockedAt: serverTimestamp()
    });
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp(),
      sharedWith: ['user2']
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  // Test 5: User who blocked owner cannot read shared reminder
  totalTests++;
  if (await runTest('User who blocked owner cannot read shared reminder', async () => {
    await clearFirestore();
    const db2 = getAuthenticatedContext('user2').firestore();
    await db2.collection('contacts').doc('user2').collection('blocked').doc('user1').set({
      blockedAt: serverTimestamp()
    });
    
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp(),
      sharedWith: ['user2']
    });
    
    await assertFails(db2.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  // Test 6: User can create reminder with required fields
  totalTests++;
  if (await runTest('User can create reminder with required fields', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertSucceeds(
      db.collection('reminders').doc('reminder1').set({
        userId: 'user1',
        title: 'Test Reminder',
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 7: User cannot create reminder without required fields
  totalTests++;
  if (await runTest('User cannot create reminder without required fields', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('reminders').doc('reminder1').set({
        userId: 'user1',
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 8: User cannot create reminder for another user
  totalTests++;
  if (await runTest('User cannot create reminder for another user', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('reminders').doc('reminder1').set({
        userId: 'user2',
        title: 'Test Reminder',
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 9: Owner can update their reminder
  totalTests++;
  if (await runTest('Owner can update their reminder', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(
      db.collection('reminders').doc('reminder1').update({
        title: 'Updated Reminder'
      })
    );
  })) passedTests++;
  
  // Test 10: Owner cannot update userId or createdAt
  totalTests++;
  if (await runTest('Owner cannot update userId or createdAt', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    await assertFails(
      db.collection('reminders').doc('reminder1').update({
        userId: 'user2'
      })
    );
  })) passedTests++;
  
  // Test 11: Shared user cannot update reminder
  totalTests++;
  if (await runTest('Shared user cannot update reminder', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp(),
      sharedWith: ['user2']
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(
      db2.collection('reminders').doc('reminder1').update({
        title: 'Updated by shared user'
      })
    );
  })) passedTests++;
  
  // Test 12: Owner can delete their reminder
  totalTests++;
  if (await runTest('Owner can delete their reminder', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(db.collection('reminders').doc('reminder1').delete());
  })) passedTests++;
  
  // Test 13: Non-owner cannot delete reminder
  totalTests++;
  if (await runTest('Non-owner cannot delete reminder', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('reminders').doc('reminder1').delete());
  })) passedTests++;
  
  // Test 14: Unauthenticated user cannot read reminders
  totalTests++;
  if (await runTest('Unauthenticated user cannot read reminders', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('reminders').doc('reminder1').set({
      userId: 'user1',
      title: 'Test Reminder',
      createdAt: serverTimestamp()
    });
    
    const unauthDb = getUnauthenticatedContext().firestore();
    await assertFails(unauthDb.collection('reminders').doc('reminder1').get());
  })) passedTests++;
  
  console.log(`\n${passedTests}/${totalTests} tests passed`);
  
  await cleanupTestEnvironment();
  
  if (passedTests !== totalTests) {
    throw new Error('Some tests failed');
  }
}

runRemindersTests().catch(error => {
  console.error('Tests failed:', error);
  process.exit(1);
});
