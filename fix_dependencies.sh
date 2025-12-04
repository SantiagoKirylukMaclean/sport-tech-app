#!/bin/bash

echo "Fetching Flutter dependencies..."
flutter pub get

echo ""
echo "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "Analyzing code for errors..."
flutter analyze

echo ""
echo "Done! Check the output above for any remaining issues."
