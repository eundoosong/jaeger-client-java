#!/bin/bash

set -e

make crossdock-fresh

export REPO=jaegertracing/xdock-java
export BRANCH=$(if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then echo $TRAVIS_BRANCH; else echo $TRAVIS_PULL_REQUEST_BRANCH; fi)
export TAG=`if [ "$BRANCH" == "master" ]; then echo "latest"; else echo "${BRANCH///}"; fi`
echo "TRAVIS_BRANCH=$TRAVIS_BRANCH, REPO=$REPO, PR=$PR, BRANCH=$BRANCH, TAG=$TAG"

# Only push the docker container to Docker Hub for master branch
if [[ "$BRANCH" == "master" && "$TRAVIS_SECURE_ENV_VARS" == "true" ]]; then echo 'upload to Docker Hub'; else echo 'skip docker upload for PR'; exit 0; fi

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

set -x

pushd 'jaeger-crossdock'
docker build -f Dockerfile -t $REPO:$COMMIT .
popd
docker tag $REPO:$COMMIT $REPO:$TAG
docker tag $REPO:$COMMIT $REPO:travis-$TRAVIS_BUILD_NUMBER
docker push $REPO
