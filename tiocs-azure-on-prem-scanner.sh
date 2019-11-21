#!/bin/sh

docker login --username pubread --password BXaXRD9n3uEWKkGgt56eHVD5h tenableio-docker-consec-local.jfrog.io
docker pull tenableio-docker-consec-local.jfrog.io/cs-scanner:latest
