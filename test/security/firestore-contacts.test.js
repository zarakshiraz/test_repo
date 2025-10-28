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

async function runContactsTests() {
  console.log('\n🚫 Testing Contacts/Blocking Collection Rules...');
  
  await setupTestEnvironment();
  
  let passedTests = 0;
  let totalTests = 0;
  
  // Test 1: User can read their own contacts document
  totalTests++;
  if (await runTest('User can read their own contacts document', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('contacts').doc('user1').set({
      contactCount: 0
    });
    
    await assertSucceeds(db.collection('contacts').doc('user1').get());
  })) passedTests++;
  
  // Test 2: User cannot read other users\' contacts
  totalTests++;
  if (await runTest('User cannot read other users\' contacts', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('contacts').doc('user1').set({
      contactCount: 0
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('contacts').doc('user1').get());
  })) passedTests++;
  
  // Test 3: User can write to their own contacts document
  totalTests++;
  if (await runTest('User can write to their own contacts document', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertSucceeds(
      db.collection('contacts').doc('user1').set({
        contactCount: 0
      })
    );
  })) passedTests++;
  
  // Test 4: User can read their own blocked contacts
  totalTests++;
  if (await runTest('User can read their own blocked contacts', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
      blockedAt: serverTimestamp()
    });
    
    await assertSucceeds(
      db.collection('contacts').doc('user1').collection('blocked').doc('user2').get()
    );
  })) passedTests++;
  
  // Test 5: User cannot read other users\' blocked contacts
  totalTests++;
  if (await runTest('User cannot read other users\' blocked contacts', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
      blockedAt: serverTimestamp()
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(
      db2.collection('contacts').doc('user1').collection('blocked').doc('user2').get()
    );
  })) passedTests++;
  
  // Test 6: User can block another user
  totalTests++;
  if (await runTest('User can block another user', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertSucceeds(
      db.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
        blockedAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 7: User cannot create block record without blockedAt field
  totalTests++;
  if (await runTest('User cannot create block record without blockedAt field', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
        reason: 'spam'
      })
    );
  })) passedTests++;
  
  // Test 8: User cannot block someone in another user\'s contacts
  totalTests++;
  if (await runTest('User cannot block someone in another user\'s contacts', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('contacts').doc('user2').collection('blocked').doc('user3').set({
        blockedAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 9: User can unblock another user
  totalTests++;
  if (await runTest('User can unblock another user', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('contacts').doc('user1').collection('blocked').doc('user2').set({
      blockedAt: serverTimestamp()
    });
    
    await assertSucceeds(
      db.collection('contacts').doc('user1').collection('blocked').doc('user2').delete()
    );
  })) passedTests++;
  
  // Test 10: Unauthenticated user cannot access contacts
  totalTests++;
  if (await runTest('Unauthenticated user cannot access contacts', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('contacts').doc('user1').set({
      contactCount: 0
    });
    
    const unauthDb = getUnauthenticatedContext().firestore();
    await assertFails(unauthDb.collection('contacts').doc('user1').get());
  })) passedTests++;
  
  console.log(`\n${passedTests}/${totalTests} tests passed`);
  
  await cleanupTestEnvironment();
  
  if (passedTests !== totalTests) {
    throw new Error('Some tests failed');
  }
}

runContactsTests().catch(error => {
  console.error('Tests failed:', error);
  process.exit(1);
});
