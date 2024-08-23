# download and install Flutter 

export FLUTTER_DIR="$HOME/flutter"
if [ -d ${FLUTTER_DIR} ]; then # we are running inside AWS CodeBuild
    echo "Flutter detected"
		exit -1
else
    echo "Flutter not found."
		
    echo "Downloading Flutter."
		curl https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.1-stable.zip -O flutter_macos_arm64_3.24.1-stable.zip -s

    echo "Unziping Flutter."
		unzip -qq -l flutter_macos_arm64_3.24.1-stable.zip -d "$FLUTTER_DIR" 
fi



