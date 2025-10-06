#!/bin/bash

echo "Configuring runner with name ${RUNNER_NAME} for repository ${REPOSITORY} and tokens ${ACCESS_TOKEN}..."

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/"${REPOSITORY}"/actions/runners/registration-token | jq .token --raw-output)

echo "Registration token received: ${REG_TOKEN}"

cd /home/docker/actions-runner || return

./config.sh --url https://github.com/"${REPOSITORY}" --token "${REG_TOKEN}" --unattended --replace --name "${RUNNER_NAME}" --labels "${RUNNER_LABELS}"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
