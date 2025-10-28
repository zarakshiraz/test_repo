const { execSync } = require('child_process');
const path = require('path');

console.log('🔒 Running Firebase Security Rules Tests...\n');

const testFiles = [
  'firestore-users.test.js',
  'firestore-memberships.test.js',
  'firestore-contacts.test.js',
  'firestore-reminders.test.js',
  'storage.test.js'
];

let allTestsPassed = true;

for (const testFile of testFiles) {
  const testPath = path.join(__dirname, testFile);
  console.log(`\n📝 Running ${testFile}...`);
  
  try {
    execSync(`node ${testPath}`, { stdio: 'inherit' });
    console.log(`✅ ${testFile} passed`);
  } catch (error) {
    console.error(`❌ ${testFile} failed`);
    allTestsPassed = false;
  }
}

console.log('\n' + '='.repeat(50));
if (allTestsPassed) {
  console.log('✅ All security rules tests passed!');
  process.exit(0);
} else {
  console.log('❌ Some security rules tests failed');
  process.exit(1);
}
