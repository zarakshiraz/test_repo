const {
  setupTestEnvironment,
  cleanupTestEnvironment,
  getAuthenticatedContext,
  getUnauthenticatedContext,
  runTest,
  clearStorage,
  assertFails,
  assertSucceeds
} = require('./test-helpers');

async function runStorageTests() {
  console.log('\n📦 Testing Storage Rules...');
  
  await setupTestEnvironment();
  
  let passedTests = 0;
  let totalTests = 0;
  
  const testImageFile = Buffer.from('fake-image-data');
  const testAudioFile = Buffer.from('fake-audio-data');
  
  // Test 1: User can upload avatar to their own directory
  totalTests++;
  if (await runTest('User can upload avatar to their own directory', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('avatars/user1/profile.jpg');
    
    await assertSucceeds(
      ref.put(testImageFile, { contentType: 'image/jpeg' })
    );
  })) passedTests++;
  
  // Test 2: User cannot upload avatar to another user\'s directory
  totalTests++;
  if (await runTest('User cannot upload avatar to another user\'s directory', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('avatars/user2/profile.jpg');
    
    await assertFails(
      ref.put(testImageFile, { contentType: 'image/jpeg' })
    );
  })) passedTests++;
  
  // Test 3: Any authenticated user can read avatars
  totalTests++;
  if (await runTest('Any authenticated user can read avatars', async () => {
    await clearStorage();
    const storage1 = getAuthenticatedContext('user1').storage();
    const ref1 = storage1.ref('avatars/user1/profile.jpg');
    await ref1.put(testImageFile, { contentType: 'image/jpeg' });
    
    const storage2 = getAuthenticatedContext('user2').storage();
    const ref2 = storage2.ref('avatars/user1/profile.jpg');
    await assertSucceeds(ref2.getDownloadURL());
  })) passedTests++;
  
  // Test 4: Unauthenticated user cannot read avatars
  totalTests++;
  if (await runTest('Unauthenticated user cannot read avatars', async () => {
    await clearStorage();
    const storage1 = getAuthenticatedContext('user1').storage();
    const ref1 = storage1.ref('avatars/user1/profile.jpg');
    await ref1.put(testImageFile, { contentType: 'image/jpeg' });
    
    const unauthStorage = getUnauthenticatedContext().storage();
    const ref = unauthStorage.ref('avatars/user1/profile.jpg');
    await assertFails(ref.getDownloadURL());
  })) passedTests++;
  
  // Test 5: User cannot upload non-image file as avatar
  totalTests++;
  if (await runTest('User cannot upload non-image file as avatar', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('avatars/user1/profile.txt');
    
    await assertFails(
      ref.put(testImageFile, { contentType: 'text/plain' })
    );
  })) passedTests++;
  
  // Test 6: User can upload audio to their own directory
  totalTests++;
  if (await runTest('User can upload audio to their own directory', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('audio/user1/recording.mp3');
    
    await assertSucceeds(
      ref.put(testAudioFile, { contentType: 'audio/mpeg' })
    );
  })) passedTests++;
  
  // Test 7: User cannot upload audio to another user\'s directory
  totalTests++;
  if (await runTest('User cannot upload audio to another user\'s directory', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('audio/user2/recording.mp3');
    
    await assertFails(
      ref.put(testAudioFile, { contentType: 'audio/mpeg' })
    );
  })) passedTests++;
  
  // Test 8: Only owner can read their audio files
  totalTests++;
  if (await runTest('Only owner can read their audio files', async () => {
    await clearStorage();
    const storage1 = getAuthenticatedContext('user1').storage();
    const ref1 = storage1.ref('audio/user1/recording.mp3');
    await ref1.put(testAudioFile, { contentType: 'audio/mpeg' });
    
    const storage2 = getAuthenticatedContext('user2').storage();
    const ref2 = storage2.ref('audio/user1/recording.mp3');
    await assertFails(ref2.getDownloadURL());
  })) passedTests++;
  
  // Test 9: Owner can read their own audio files
  totalTests++;
  if (await runTest('Owner can read their own audio files', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('audio/user1/recording.mp3');
    await ref.put(testAudioFile, { contentType: 'audio/mpeg' });
    
    await assertSucceeds(ref.getDownloadURL());
  })) passedTests++;
  
  // Test 10: User cannot upload non-audio file to audio directory
  totalTests++;
  if (await runTest('User cannot upload non-audio file to audio directory', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('audio/user1/document.pdf');
    
    await assertFails(
      ref.put(testAudioFile, { contentType: 'application/pdf' })
    );
  })) passedTests++;
  
  // Test 11: User can delete their own avatar
  totalTests++;
  if (await runTest('User can delete their own avatar', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('avatars/user1/profile.jpg');
    await ref.put(testImageFile, { contentType: 'image/jpeg' });
    
    await assertSucceeds(ref.delete());
  })) passedTests++;
  
  // Test 12: User cannot delete another user\'s avatar
  totalTests++;
  if (await runTest('User cannot delete another user\'s avatar', async () => {
    await clearStorage();
    const storage1 = getAuthenticatedContext('user1').storage();
    const ref1 = storage1.ref('avatars/user1/profile.jpg');
    await ref1.put(testImageFile, { contentType: 'image/jpeg' });
    
    const storage2 = getAuthenticatedContext('user2').storage();
    const ref2 = storage2.ref('avatars/user1/profile.jpg');
    await assertFails(ref2.delete());
  })) passedTests++;
  
  // Test 13: User can delete their own audio
  totalTests++;
  if (await runTest('User can delete their own audio', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('audio/user1/recording.mp3');
    await ref.put(testAudioFile, { contentType: 'audio/mpeg' });
    
    await assertSucceeds(ref.delete());
  })) passedTests++;
  
  // Test 14: User cannot access files in root or other paths
  totalTests++;
  if (await runTest('User cannot access files in root or other paths', async () => {
    await clearStorage();
    const storage = getAuthenticatedContext('user1').storage();
    const ref = storage.ref('random/path/file.txt');
    
    await assertFails(
      ref.put(testImageFile, { contentType: 'text/plain' })
    );
  })) passedTests++;
  
  console.log(`\n${passedTests}/${totalTests} tests passed`);
  
  await cleanupTestEnvironment();
  
  if (passedTests !== totalTests) {
    throw new Error('Some tests failed');
  }
}

runStorageTests().catch(error => {
  console.error('Tests failed:', error);
  process.exit(1);
});
