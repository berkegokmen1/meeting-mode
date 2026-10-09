#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/tests
cp Tests/journal.swift build/tests/main.swift
xcrun swiftc -module-cache-path "$PWD/build/ModuleCache" Sources/Journal.swift build/tests/main.swift -o build/tests/journal
build/tests/journal
