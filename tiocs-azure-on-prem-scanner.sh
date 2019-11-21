#!/bin/sh
#This script expects the following environment variables to be set:
# REPO, IMAGE, TAG, $TENABLEACCESSKEY, $TENABLESECRETKEY
echo "Checking $IMAGE:$TAG and uploading results into cloud.tenable.com repo $REPO"
echo "Tenable.io Access Key: $TENABLEACCESSKEY"

docker login --username pubread --password BXaXRD9n3uEWKkGgt56eHVD5h tenableio-docker-consec-local.jfrog.io
docker pull tenableio-docker-consec-local.jfrog.io/cs-scanner:latest

echo "Start of on-prem analysis"
docker save $IMAGE:$TAG | docker run -e DEBUG_MODE=true -e TENABLE_ACCESS_KEY=$TENABLEACCESSKEY \
 -e TENABLE_SECRET_KEY=$TENABLESECRETKEY -e IMPORT_REPO_NAME=$REPO \
 -i tenableio-docker-consec-local.jfrog.io/cs-scanner:latest \
 inspect-image $IMAGE:$TAG
echo "End of on-prem analysis
