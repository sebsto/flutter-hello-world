#!/bin/sh

. script/00_common.sh

CERTIFICATES_DIR=$HOME/certificates
mkdir -p $CERTIFICATES_DIR 2>&1 >/dev/null
echo "Certificates directory: $CERTIFICATES_DIR"

echo "Cleaning Provisioning Profiles"
rm -rf "$HOME/Library/MobileDevice/Provisioning Profiles"

echo "Prepare keychain"
KEYCHAIN_PASSWORD=Passw0rd
KEYCHAIN_NAME=dev.keychain
SYSTEM_KEYCHAIN=/Library/Keychains/System.keychain
AUTHORISATION=(-T /usr/bin/security -T /usr/bin/codesign -T /usr/bin/xcodebuild)

echo "Re-Creating System Keychain"
sudo security delete-keychain "${SYSTEM_KEYCHAIN}" 
sudo security create-keychain -p "${KEYCHAIN_PASSWORD}" "${SYSTEM_KEYCHAIN}"
security list-keychains -s "${SYSTEM_KEYCHAIN}"

if [ -f $HOME/Library/Keychains/"${KEYCHAIN_NAME}"-db ]; then
    echo "Deleting old ${KEYCHAIN_NAME} keychain"
    security delete-keychain "${KEYCHAIN_NAME}"
fi

echo "Creating keychain"
security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"

echo "Adding the build keychain to the search list"
EXISTING_KEYCHAINS=( $( security list-keychains | sed -e 's/ *//' | tr '\n' ' ' | tr -d '"') )
sudo security list-keychains -s "${KEYCHAIN_NAME}" "${EXISTING_KEYCHAINS[@]}"
echo "New keychain search list :"
security list-keychain 

# at this point the keychain is unlocked, the below line is not needed
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"

echo "Configure keychain : remove lock timeout"
security set-keychain-settings "${KEYCHAIN_NAME}"

if [ ! -f $CERTIFICATES_DIR/AppleWWDRCAG3.cer ]; then
    echo "Downloadind Apple Worlwide Developer Relation GA3 certificate"
    curl -s -o $CERTIFICATES_DIR/AppleWWDRCAG3.cer https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
fi
sudo security find-certificate -c "Apple Worldwide Developer Relations Certification Authority"  /Library/Keychains/System.keychain 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing Apple Worlwide Developer Relation GA3 certificate into System keychain"
    sudo security import $CERTIFICATES_DIR/AppleWWDRCAG3.cer -t cert -k "${SYSTEM_KEYCHAIN}" "${AUTHORISATION[@]}"
fi

echo "Retrieve application dev and dist keys from AWS Secret Manager"
SIGNING_DIST_KEY_SECRET=flutter-dist-certificate
MOBILE_PROVISIONING_PROFILE_DIST_SECRET=flutter-dist-provisionning

# These are base64 values, we will need to decode to a file when needed
MOBILE_PROVISIONING_DIST_PROFILE=$($AWS_CLI --region $REGION secretsmanager get-secret-value --secret-id $MOBILE_PROVISIONING_PROFILE_DIST_SECRET --query SecretBinary --output text)

echo "Import Signing private key and certificate"
DIST_KEY_FILE=$CERTIFICATES_DIR/apple_dist_key.p12
echo $SIGNING_DIST_KEY | base64 -d > $DIST_KEY_FILE
security import "${DIST_KEY_FILE}" -P "" -k "${KEYCHAIN_NAME}" "${AUTHORISATION[@]}"

# is this necessary when importing keys with -A ?
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"

echo "Install distribution provisioning profile"
MOBILE_PROVISIONING_DIST_PROFILE_FILE=$CERTIFICATES_DIR/project-dist.mobileprovision
echo $MOBILE_PROVISIONING_DIST_PROFILE | base64 -d > $MOBILE_PROVISIONING_DIST_PROFILE_FILE
UUID=$(security cms -D -i $MOBILE_PROVISIONING_DIST_PROFILE_FILE -k "${KEYCHAIN_NAME}" | plutil -extract UUID xml1 -o - - | xmllint --xpath "//string/text()" -)
cp $MOBILE_PROVISIONING_DIST_PROFILE_FILE "$HOME/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"

