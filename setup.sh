#!/usr/bin/env bash

set -e

echo "Installing AI Engineering Toolchain..."

./scripts/install-tools.sh

echo "Installing APM components..."

apm install --target kiro

echo "Initializing OpenSpec..."

if [ ! -d "openspec" ]; then
    openspec init --tools kiro
fi

echo "Done."