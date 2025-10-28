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

async function runUsersTests() {
  console.log('\n🔐 Testing Users Collection Rules...');
  
  await setupTestEnvironment();
  
  let passedTests = 0;
  let totalTests = 0;
  
  // Test 1: Unauthenticated users cannot read user data
  totalTests++;
  if (await runTest('Unauthenticated users cannot read user data', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    const unauthDb = getUnauthenticatedContext().firestore();
    await assertFails(unauthDb.collection('users').doc('user1').get());
  })) passedTests++;
  
  // Test 2: Users can read their own data
  totalTests++;
  if (await runTest('Users can read their own data', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(db.collection('users').doc('user1').get());
  })) passedTests++;
  
  // Test 3: Users cannot read other users' data
  totalTests++;
  if (await runTest('Users cannot read other users\' data', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('users').doc('user1').get());
  })) passedTests++;
  
  // Test 4: Users can create their own user document with required fields
  totalTests++;
  if (await runTest('Users can create their own user document with required fields', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertSucceeds(
      db.collection('users').doc('user1').set({
        email: 'user1@example.com',
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 5: Users cannot create documents for other users
  totalTests++;
  if (await runTest('Users cannot create documents for other users', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('users').doc('user2').set({
        email: 'user2@example.com',
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 6: Users cannot create documents without required fields
  totalTests++;
  if (await runTest('Users cannot create documents without required fields', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('users').doc('user1').set({
        email: 'user1@example.com'
      })
    );
  })) passedTests++;
  
  // Test 7: Users can update their own data
  totalTests++;
  if (await runTest('Users can update their own data', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(
      db.collection('users').doc('user1').update({
        displayName: 'User One'
      })
    );
  })) passedTests++;
  
  // Test 8: Users cannot update createdAt field
  totalTests++;
  if (await runTest('Users cannot update createdAt field', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    await assertFails(
      db.collection('users').doc('user1').update({
        createdAt: serverTimestamp()
      })
    );
  })) passedTests++;
  
  // Test 9: Users can delete their own data
  totalTests++;
  if (await runTest('Users can delete their own data', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    await assertSucceeds(db.collection('users').doc('user1').delete());
  })) passedTests++;
  
  // Test 10: Users cannot delete other users' data
  totalTests++;
  if (await runTest('Users cannot delete other users\' data', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('users').doc('user1').set({
      email: 'user1@example.com',
      createdAt: serverTimestamp()
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('users').doc('user1').delete());
  })) passedTests++;
  
  console.log(`\n${passedTests}/${totalTests} tests passed`);
  
  await cleanupTestEnvironment();
  
  if (passedTests !== totalTests) {
    throw new Error('Some tests failed');
  }
}

runUsersTests().catch(error => {
  console.error('Tests failed:', error);
  process.exit(1);
});
