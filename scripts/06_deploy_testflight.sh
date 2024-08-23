#!/bin/sh
set -e 
set -o pipefail

. script/00_common.sh

echo "Changing to code directory at $CODE_DIR"
pushd $CODE_DIR


# echo "Verify Archive"
# xcrun altool  \
#             --validate-app \
#             -f "$BUILD_PATH/$SCHEME.ipa" \
#             -t ios \
#             -u $APPLE_ID \
#             -p @env:APPLE_SECRET 

# echo "Upload to AppStore Connect"
# xcrun altool  \
# 		--upload-app \
# 		-f "$BUILD_PATH/$SCHEME.ipa" \
# 		-t ios \
# 		-u $APPLE_ID \
# 		-p @env:APPLE_SECRET 

popd