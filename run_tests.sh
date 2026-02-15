#!/bin/bash
# Run all tests for Three Kingdoms Survivors
# Usage: ./run_tests.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running Three Kingdoms Survivors Test Suite..."
echo ""

godot --headless --script "$SCRIPT_DIR/tests/test_runner.gd"

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo ""
    echo "✓ All tests passed!"
else
    echo ""
    echo "✗ Some tests failed!"
fi

exit $exit_code
