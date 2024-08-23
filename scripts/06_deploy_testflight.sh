#!/bin/sh
set -e 
set -o pipefail

. scripts/00_common.sh

echo "Changing to code directory at $CODE_DIR"
pushd $CODE_DIR

APPLE_ID_SECRET=apple-id
APPLE_SECRET_SECRET=apple-secret
APPLE_ID=$($AWS_CLI --region $REGION secretsmanager get-secret-value --secret-id $APPLE_ID_SECRET --query SecretString --output text)
export APPLE_SECRET=$($AWS_CLI --region $REGION secretsmanager get-secret-value --secret-id $APPLE_SECRET_SECRET --query SecretString --output text)

# echo "Verify Archive"
# xcrun altool  \
#             --validate-app \
#             -f "build/ios/ipa/hello_world.ipa" \
#             -t ios \
#             -u $APPLE_ID \
#             -p @env:APPLE_SECRET 

# echo "Upload to AppStore Connect"
# xcrun altool  \
# 		--upload-app \
# 		-f "build/ios/ipa/hello_world.ipa" \
# 		-t ios \
# 		-u $APPLE_ID \
# 		-p @env:APPLE_SECRET 

popd