#!/usr/bin/env bash

IMAGETAG=9.6.0-python3.7

if [ "${IMAGETAG}" != "skip" ]; then
    echo "Tagging image as $IMAGETAG"

    echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
    docker tag energyplus:latest nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))
    docker push nrel/energyplus:$IMAGETAG; (( exit_status = exit_status || $? ))

    if [ "${GITHUB_REF}" == "refs/heads/main" ]; then
        # Deploy main as the latest.
        docker push nrel/energyplus:latest; (( exit_status = exit_status || $? ))
    fi

    exit $exit_status
else
    echo "Not on a deployable branch, this is a pull request or has been explicitly skipped"
fi

# Deploy the singularity image
# ... hmm, do we need to add this back in here?
