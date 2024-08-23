#!/bin/sh
set -e 
set -o pipefail

. code/ci_actions/00_common.sh

echo "Changing to code directory at $CODE_DIR"
pushd $CODE_DIR

KEYCHAIN_PASSWORD=Passw0rd
KEYCHAIN_NAME=dev.keychain

# Increase Build Number
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/

BUILD_NUMBER=`date +%Y%m%d%H%M%S`
echo "Updated build number is " $BUILD_NUMBER
plutil -replace CFBundleVersion -string $BUILD_NUMBER "./getting started/Info.plist"

security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_NAME

$FLUTTER_DIR/bin/flutter build ipa

popd
