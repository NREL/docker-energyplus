#!/usr/bin/env bash

IMAGETAG=skip
if [ "${GITHUB_REF}" == "refs/heads/develop" ]; then
    IMAGETAG=develop
elif [ "${GITHUB_REF}" == "refs/heads/main" ]; then
    # Retrieve the version number from package.json - 9.5.0 has date with decimal separator, so grab first line withhead -n1
    IMAGETAG=$( docker run -it energyplus:latest /bin/bash -c "EnergyPlus --version | grep -Po '\d{1,2}\.\d{1,2}\.\d{1,2}'" | head -n1 )
    OUT=$?
    if [ $OUT -eq 0 ]; then
        IMAGETAG=$( echo $IMAGETAG | tr -d '\r' )
        echo "Found EnergyPlus Version: $IMAGETAG"
    else
        echo "ERROR Trying to find EnergyPlus Version"
        IMAGETAG=skip
    fi
fi

if [ "${IMAGETAG}" != "skip" ]; then
    echo "Tagging image as $IMAGETAG"

    echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
    docker tag energyplus:latest nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))
    docker tag energyplus:latest nrel/energyplus:latest; (( exit_status = exit_status || $? ))
    docker push nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))

    if [ "${GITHUB_REF}" == "refs/heads/main" ]; then
	# Deploy main as the latest.
        docker push nrel/energyplus:latest; (( exit_status = exit_status || $? ))
    fi

    exit $exit_status
else
    echo "Not on a deployable branch, this is a pull request or has been explicity skipped"
fi

# Deploy the singularity image
# ... hmm, do we need to add this back in here?