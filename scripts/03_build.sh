#!/bin/sh
set -e 
set -o pipefail

. scripts/00_common.sh

echo "Changing to code directory at $CODE_DIR"
pushd $CODE_DIR

KEYCHAIN_PASSWORD=Passw0rd
KEYCHAIN_NAME=dev.keychain

EXPORT_OPTIONS_FILE="./exportOptions.plist"

# Increase Build Number
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/

BUILD_NUMBER=`date +%Y%m%d%H%M%S`
echo "Updated build number is " $BUILD_NUMBER
plutil -replace CFBundleVersion -string $BUILD_NUMBER "./getting started/Info.plist"

security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_NAME

cat << EOF > $EXPORT_OPTIONS_FILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>destination</key>
	<string>export</string>
	<key>method</key>
	<string>app-store</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.stormacq.flutter.hello-world</key>
		<string>flutter-hello-world</string>
	</dict>
	<key>signingCertificate</key>
	<string>Apple Distribution</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>56U756R2L2</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
EOF

$FLUTTER_DIR/bin/flutter config --no-cli-animations
$FLUTTER_DIR/bin/flutter build ipa --export-options-plist $EXPORT_OPTIONS_FILE

popd
