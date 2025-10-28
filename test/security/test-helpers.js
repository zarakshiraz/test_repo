const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { setLogLevel } = require('firebase/firestore');

let testEnv;

async function setupTestEnvironment() {
  if (testEnv) {
    return testEnv;
  }
  
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-security-rules-test',
    firestore: {
      rules: require('fs').readFileSync('firestore.rules', 'utf8'),
      host: 'localhost',
      port: 8080
    },
    storage: {
      rules: require('fs').readFileSync('storage.rules', 'utf8'),
      host: 'localhost',
      port: 9199
    }
  });
  
  return testEnv;
}

async function cleanupTestEnvironment() {
  if (testEnv) {
    await testEnv.cleanup();
    testEnv = null;
  }
}

function getAuthenticatedContext(uid) {
  return testEnv.authenticatedContext(uid);
}

function getUnauthenticatedContext() {
  return testEnv.unauthenticatedContext();
}

async function runTest(testName, testFn) {
  try {
    await testFn();
    console.log(`  ✓ ${testName}`);
    return true;
  } catch (error) {
    console.error(`  ✗ ${testName}`);
    console.error(`    Error: ${error.message}`);
    return false;
  }
}

async function clearFirestore() {
  if (testEnv) {
    await testEnv.clearFirestore();
  }
}

async function clearStorage() {
  if (testEnv) {
    await testEnv.clearStorage();
  }
}

module.exports = {
  setupTestEnvironment,
  cleanupTestEnvironment,
  getAuthenticatedContext,
  getUnauthenticatedContext,
  runTest,
  clearFirestore,
  clearStorage,
  assertFails,
  assertSucceeds
};
