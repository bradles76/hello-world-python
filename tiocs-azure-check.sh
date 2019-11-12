#!/bin/sh
#This script expects the following environment variables to be set:
# REPO, IMAGE, TAG, $TENABLEACCESSKEY, $TENABLESECRETKEY
echo "Checking $REPO/$IMAGE:$TAG"
echo "Tenable.io Access Key: $TENABLEACCESSKEY"
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