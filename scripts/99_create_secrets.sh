REGION=us-east-2

SIGNING_DIST_KEY_SECRET=flutter-dist-certificate
MOBILE_PROVISIONING_PROFILE_DIST_SECRET=flutter-dist-provisionning

aws --region $REGION secretsmanager create-secret --name $SIGNING_DIST_KEY_SECRET --secret-binary fileb://./secrets/sebsto-flutter-dist.p12 
# aws --region $REGION secretsmanager update-secret --secret-id $SIGNING_DIST_KEY_SECRET --secret-binary fileb://./secrets/sebsto-flutter-dist.p12

aws --region $REGION secretsmanager create-secret --name $MOBILE_PROVISIONING_PROFILE_DIST_SECRET --secret-binary fileb://./secrets/flutterdist.mobileprovision
# aws --region $REGION secretsmanager update-secret --secret-id $MOBILE_PROVISIONING_PROFILE_DIST_SECRET --secret-binary fileb://./secrets/amplifyiosgettingstarteddist.mobileprovision
