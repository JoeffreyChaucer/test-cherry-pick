#!/bin/bash
set -euo pipefail

check_build_mode(){
    echo "ENABLE BUILD ALL SET to = ${ENABLE_BUILD_ALL:-"false"}"
    echo "If ENABLE_BUILD_ALL is null or unset, ENABLE_BUILD_ALL is set to the default value of false."
    if [ "${ENABLE_BUILD_ALL:-"false"}" = false ]
    then
        DIFFCHECK="--diffcheck"
        buildkite-agent annotate 'Building packages that have changed' --style 'info'
    else
        DIFFCHECK=""
    fi
}

build_packages(){
    echo "--- Building packages"
    if [ ${VALIDATE:-""} = "validate" ]
    then
        sfdx sfpowerscripts:orchestrator:build -v devhub --executorcount 10 --buildnumber=${BUILDKITE_BUILD_NUMBER} --tag sfdc-core \
        --artifactdir validated_artifacts ${DIFFCHECK} --branch "$BUILDKITE_BRANCH"
    else
        sfdx sfpowerscripts:orchestrator:quickbuild -v devhub --executorcount 10 --buildnumber=${BUILDKITE_BUILD_NUMBER} --tag sfdc-core \
        ${DIFFCHECK} --branch "$BUILDKITE_BRANCH"
    fi
}

buildkite_agent_annotate(){
    if [ -z "$(find . -name "*_sfpowerscripts_artifact*.zip" -print)" ]
    then
        buildkite-agent annotate 'Nothing to build or deploy. Did you mean to build all packages?' --style 'warning'
    fi
}

main(){
    #import file
    source .buildkite/lib/cleanup.sh
    source .buildkite/lib/installSfdxPlugin.sh
    source .buildkite/lib/authenticate.sh

    # Set STATSD Environment Variables for logging metrics about this build
    export SFPOWERSCRIPTS_STATSD=${ENABLE_METRICS:-"false"}
    export SFPOWERSCRIPTS_STATSD_HOST=${STATSD_ADDR:-}


    cyan=$(tput setaf 6)
    sgr0=$(tput sgr0)

    trap "cleanup" EXIT

    local VALIDATE="$1"

    # Invoke functions
    install_sfdx_plugins
    authenticate_to_production
    check_build_mode
    build_packages
    buildkite_agent_annotate

}

main "$1"