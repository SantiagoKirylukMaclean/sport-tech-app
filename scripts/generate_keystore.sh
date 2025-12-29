#!/bin/bash

# Script to generate an Android Upload Keystore
# Usage: ./generate_keystore.sh

KEYSTORE_NAME="upload-keystore.jks"
ALIAS="upload"
VALIDITY_DAYS=10000

echo "Generating Android Upload Keystore..."
echo "This keystore will be used to sign your Android app releases."
echo ""

if [ -f "$KEYSTORE_NAME" ]; then
    echo "Error: $KEYSTORE_NAME already exists in the current directory."
    echo "Please move or rename it before generating a new one."
    exit 1
fi

echo "Please verify you have keytool installed (comes with Java JDK)."
if ! command -v keytool &> /dev/null; then
    echo "Error: keytool command not found."
    exit 1
fi

echo ""
echo "You will be prompted to enter a password and some details."
echo "REMEMBER THE PASSWORD! You will need it for the CI/CD secrets."
echo ""

keytool -genkey -v -keystore $KEYSTORE_NAME \
    -alias $ALIAS \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY_DAYS

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully: $KEYSTORE_NAME"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Base64 encode the keystore file to store it in GitHub Secrets:"
    echo "   base64 -i $KEYSTORE_NAME > keystore_base64.txt"
    echo "   (Copy the content of keystore_base64.txt to a secret named ANDROID_KEYSTORE_BASE64)"
    echo ""
    echo "2. Add the following secrets to your GitHub Repository:"
    echo "   - ANDROID_KEYSTORE_BASE64 (The base64 string from step 1)"
    echo "   - ANDROID_KEY_ALIAS (Value: $ALIAS)"
    echo "   - ANDROID_KEY_PASSWORD (The password you entered)"
    echo "   - ANDROID_STORE_PASSWORD (The password you entered)"
    echo ""
    echo "⚠️  KEEP THIS FILE SAFE AND DO NOT COMMIT IT TO GIT!"
else
    echo "❌ Failed to generate keystore."
fi
