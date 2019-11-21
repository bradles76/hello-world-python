#!/bin/sh
#This script expects the following environment variables to be set:
# REPO, IMAGE, TAG, $TENABLEACCESSKEY, $TENABLESECRETKEY
echo "Checking $IMAGE:$TAG and uploading results into cloud.tenable.com repo $REPO"
echo "Tenable.io Access Key: $TENABLEACCESSKEY"


docker login --username pubread --password BXaXRD9n3uEWKkGgt56eHVD5h tenableio-docker-consec-local.jfrog.io
docker pull tenableio-docker-consec-local.jfrog.io/cs-scanner:latest

docker save $IMAGE:$TAG | docker run -e DEBUG_MODE=true -e TENABLE_ACCESS_KEY=$TENABLE_IO_ACCESS_KEY \
 -e TENABLE_SECRET_KEY=$TENABLE_IO_SECRET_KEY -e IMPORT_REPO_NAME=$REPO \
 -i tenableio-docker-consec-local.jfrog.io/cs-scanner:latest \
 inspect-image $IMAGE:$TAG

docker save $IMAGE:$TAG | docker run -e DEBUG_MODE=true
while [ 1 -eq 1 ]; do
  RESP=`curl -s --request GET --url "https://cloud.tenable.com/container-security/api/v1/compliancebyname?image=$IMAGE&repo=$REPO&tag=$TAG" \
  --header 'accept: application/json' --header "x-apikeys: accessKey=$TENABLEACCESSKEY;secretKey=$TENABLESECRETKEY" \
  | sed -n 's/.*\"status\":\"\([^\"]*\)\".*/\1/p'`
  if [ "x$RESP" = "xpass" ] ; then
    echo "Container marked as PASSED by policy rules"
    exit 0
  fi
  if [ "x$RESP" = "xfail" ] ; then
    echo "Container marked as FAILED by policy rules"
    exit 1
  fi
  if [ "x$RESP" = "x" ] ; then
    echo "No response received, likely this means there is an issue with the script.  Failing"
    exit 1
  fi
  sleep 30
done