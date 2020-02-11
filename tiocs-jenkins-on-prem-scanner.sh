#!/bin/sh
#This script expects the following environment variables to be set:
# REPO, IMAGE, $BUILD_NUMBER, $TENABLEACCESSKEY, $TENABLESECRETKEY
IMAGENAME=$IMAGE_NAME
IMAGETAG=$BUILD_NUMBER
REPO=$IMAGE_NAME-on-prem
TENABLEACCESSKEY=$TIO_ACCESS_KEY
TENABLESECRETKEY=$TIO_SECRET_KEY

echo "Checking $IMAGENAME:$IMAGETAG and analyzing results on-premise then reporting into cloud.tenable.com repo $REPO"
echo "Tenable.io Access Key: $TENABLEACCESSKEY"
echo ""
#echo "Variables list:"
#set

echo
echo "Download Tenable.io on-prem scanner"

docker login --username pubread --password BXaXRD9n3uEWKkGgt56eHVD5h tenableio-docker-consec-local.jfrog.io
docker pull tenableio-docker-consec-local.jfrog.io/cs-scanner:latest

echo
echo "Start of on-prem analysis"
set -x
docker save $IMAGENAME:$IMAGETAG | docker run -e DEBUG_MODE=true -e TENABLE_ACCESS_KEY=$TENABLEACCESSKEY -e TENABLE_SECRET_KEY=$TENABLESECRETKEY -e IMPORT_REPO_NAME=$REPO -i tenableio-docker-consec-local.jfrog.io/cs-scanner:latest inspect-image $IMAGENAME:$IMAGETAG
set +x
echo "End of on-prem analysis"

echo
echo "Download report on image $REPO/$IMAGENAME:$IMAGETAG"
while [ 1 -eq 1 ]; do
  RESP=`curl -s --request GET --url "https://cloud.tenable.com/container-security/api/v1/compliancebyname?image=$IMAGENAME&repo=$REPO&tag=$IMAGETAG" \
  --header 'accept: application/json' --header "x-apikeys: accessKey=$TENABLEACCESSKEY;secretKey=$TENABLESECRETKEY" \
  | sed -n 's/.*\"status\":\"\([^\"]*\)\".*/\1/p'`
  echo "Report status: $RESP"
  if [ "x$RESP" = "xpass" ] ; then
    echo "Container marked as PASSED by policy rules"
    echo
    exit 0
  fi
  if [ "x$RESP" = "xfail" ] ; then
    echo "Container marked as FAILED by policy rules"
    echo
    exit 1
  fi
  echo "Waiting 30 seconds before checking again for report"
  sleep 30
done
