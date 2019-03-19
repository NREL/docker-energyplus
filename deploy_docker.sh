#!/usr/bin/env bash

IMAGETAG=skip
if [ "${TRAVIS_BRANCH}" == "develop" ]; then
    IMAGETAG=develop
elif [ "${TRAVIS_BRANCH}" == "master" ]; then
    # Retrieve the version number from package.json
    IMAGETAG=$( docker run -it energyplus:latest /bin/bash -c "EnergyPlus --version | grep -Po '\d{1,2}\.\d{1,2}\.\d{1,2}'" )
    OUT=$?
    if [ $OUT -eq 0 ]; then
        IMAGETAG=$( echo $IMAGETAG | tr -d '\r' )
        echo "Found EnergyPlus Version: $IMAGETAG"
    else
        echo "ERROR Trying to find EnergyPlus Version"
        IMAGETAG=skip
    fi
fi

if [ "${IMAGETAG}" != "skip" ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    echo "Tagging image as $IMAGETAG"

    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
    docker tag energyplus:latest nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))
    docker tag energyplus:latest nrel/energyplus:latest; (( exit_status = exit_status || $? ))
    docker push nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))

    if [ "${TRAVIS_BRANCH}" == "master" ]; then
	# Deploy master as the latest.
        docker push nrel/energyplus:latest; (( exit_status = exit_status || $? ))
    fi

    exit $exit_status
else
    echo "Not on a deployable branch, this is a pull request or has been explicity skipped"
fi

# Deploy the singularity image
