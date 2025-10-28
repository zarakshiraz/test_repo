#!/bin/bash

# Verification script to ensure all security rules components are in place

echo "🔍 Verifying Security Rules Implementation"
echo "=========================================="
echo ""

EXIT_CODE=0

# Check for required files
echo "📁 Checking required files..."

REQUIRED_FILES=(
    "firebase.json"
    "firestore.rules"
    "storage.rules"
    "package.json"
    ".gitignore"
    "docs/security-rules.md"
    "test/security/test-helpers.js"
    "test/security/run-tests.js"
    "test/security/firestore-users.test.js"
    "test/security/firestore-memberships.test.js"
    "test/security/firestore-contacts.test.js"
    "test/security/firestore-reminders.test.js"
    "test/security/storage.test.js"
    "scripts/test-security.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (MISSING)"
        EXIT_CODE=1
    fi
done

echo ""
echo "📋 Checking for TODO placeholders in rules..."

if grep -r "TODO\|FIXME\|XXX" *.rules 2>/dev/null; then
    echo "  ✗ Found TODO placeholders in rules files"
    EXIT_CODE=1
else
    echo "  ✓ No TODO placeholders found in rules files"
fi

echo ""
echo "📝 Checking documentation..."

if [ -f "docs/security-rules.md" ]; then
    WORD_COUNT=$(wc -w < docs/security-rules.md)
    if [ "$WORD_COUNT" -gt 1000 ]; then
        echo "  ✓ Security documentation is comprehensive ($WORD_COUNT words)"
    else
        echo "  ⚠ Security documentation might need more detail ($WORD_COUNT words)"
    fi
fi

echo ""
echo "🧪 Counting test files..."

TEST_COUNT=$(find test/security -name "*.test.js" | wc -l)
echo "  ✓ Found $TEST_COUNT test suites"

echo ""
echo "📦 Checking package.json scripts..."

if grep -q '"test:security"' package.json; then
    echo "  ✓ test:security script found"
else
    echo "  ✗ test:security script missing"
    EXIT_CODE=1
fi

echo ""
echo "=========================================="

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All security implementation components verified!"
else
    echo "❌ Some components are missing or incomplete"
fi

exit $EXIT_CODE
