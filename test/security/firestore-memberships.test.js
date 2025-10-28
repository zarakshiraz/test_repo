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

async function runMembershipsTests() {
  console.log('\n👥 Testing Memberships Collection Rules...');
  
  await setupTestEnvironment();
  
  let passedTests = 0;
  let totalTests = 0;
  
  // Test 1: Owner can read their membership
  totalTests++;
  if (await runTest('Owner can read their membership', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {}
    });
    
    await assertSucceeds(db.collection('memberships').doc('membership1').get());
  })) passedTests++;
  
  // Test 2: Member with viewer role can read membership
  totalTests++;
  if (await runTest('Member with viewer role can read membership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {
        user2: { role: 'viewer' }
      }
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertSucceeds(db2.collection('memberships').doc('membership1').get());
  })) passedTests++;
  
  // Test 3: Member with editor role can read membership
  totalTests++;
  if (await runTest('Member with editor role can read membership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {
        user2: { role: 'editor' }
      }
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertSucceeds(db2.collection('memberships').doc('membership1').get());
  })) passedTests++;
  
  // Test 4: Non-member cannot read membership
  totalTests++;
  if (await runTest('Non-member cannot read membership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {}
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('memberships').doc('membership1').get());
  })) passedTests++;
  
  // Test 5: User can create membership they own
  totalTests++;
  if (await runTest('User can create membership they own', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertSucceeds(
      db.collection('memberships').doc('membership1').set({
        userId: 'user1',
        createdAt: serverTimestamp(),
        members: {}
      })
    );
  })) passedTests++;
  
  // Test 6: User cannot create membership for another user
  totalTests++;
  if (await runTest('User cannot create membership for another user', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await assertFails(
      db.collection('memberships').doc('membership1').set({
        userId: 'user2',
        createdAt: serverTimestamp(),
        members: {}
      })
    );
  })) passedTests++;
  
  // Test 7: Owner can update membership
  totalTests++;
  if (await runTest('Owner can update membership', async () => {
    await clearFirestore();
    const db = getAuthenticatedContext('user1').firestore();
    await db.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {}
    });
    
    await assertSucceeds(
      db.collection('memberships').doc('membership1').update({
        name: 'My Membership'
      })
    );
  })) passedTests++;
  
  // Test 8: Editor can update membership but not ownership
  totalTests++;
  if (await runTest('Editor can update membership but not ownership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {
        user2: { role: 'editor' }
      }
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertSucceeds(
      db2.collection('memberships').doc('membership1').update({
        name: 'Updated Name'
      })
    );
    
    await assertFails(
      db2.collection('memberships').doc('membership1').update({
        userId: 'user2'
      })
    );
  })) passedTests++;
  
  // Test 9: Viewer cannot update membership
  totalTests++;
  if (await runTest('Viewer cannot update membership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {
        user2: { role: 'viewer' }
      }
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(
      db2.collection('memberships').doc('membership1').update({
        name: 'Updated Name'
      })
    );
  })) passedTests++;
  
  // Test 10: Only owner can delete membership
  totalTests++;
  if (await runTest('Only owner can delete membership', async () => {
    await clearFirestore();
    const db1 = getAuthenticatedContext('user1').firestore();
    await db1.collection('memberships').doc('membership1').set({
      userId: 'user1',
      createdAt: serverTimestamp(),
      members: {
        user2: { role: 'editor' }
      }
    });
    
    const db2 = getAuthenticatedContext('user2').firestore();
    await assertFails(db2.collection('memberships').doc('membership1').delete());
    
    await assertSucceeds(db1.collection('memberships').doc('membership1').delete());
  })) passedTests++;
  
  console.log(`\n${passedTests}/${totalTests} tests passed`);
  
  await cleanupTestEnvironment();
  
  if (passedTests !== totalTests) {
    throw new Error('Some tests failed');
  }
}

runMembershipsTests().catch(error => {
  console.error('Tests failed:', error);
  process.exit(1);
});
