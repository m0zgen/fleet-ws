#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Download and run JetBrain Fleet Workspace
# Reference: https://www.jetbrains.com/help/fleet/install-on-a-remote-machine.html

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

# Initial variables
# ---------------------------------------------------\
DOWNLOAD_FLEET_URL="https://download.jetbrains.com/product?code=FLL&release.type=preview&release.type=eap&platform=linux_x64"
DOWNLOAD_DESTINATION=$SCRIPT_PATH

# Functions
# ---------------------------------------------------\

# Init
# Help information
usage() {

    echo -e "\nArguments:
    -r (run fleet)\n"
    exit 1

}

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--run) _RUN=1; ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Checks supporting distros
check_distro() {
    # Checking distro
    if [ -e /etc/centos-release ]; then
        DISTRO=`cat /etc/redhat-release | awk '{print $1,$4}'`
        RPM=1
    elif [ -e /etc/fedora-release ]; then
        DISTRO=`cat /etc/fedora-release | awk '{print ($1,$3~/^[0-9]/?$3:$4)}'`
        RPM=2
    elif [ -e /etc/os-release ]; then
        DISTRO=`lsb_release -d | awk -F"\t" '{print $2}'`
        RPM=0
        DEB=1
    else
        echo "Your distribution is not supported (yet)"
        exit 1
    fi
}

check_dest() {
    if [[ ! -d "${DOWNLOAD_DESTINATION}"  ]]; then
        mkdir -p "${DOWNLOAD_DESTINATION}"
    fi
}

# check_already() {
#     if [[ condition ]]; then
#         #statements
#     fi
# }

get_fleet() {
    echo "Download Fleet from JetBrains..."
    curl -LSs "https://download.jetbrains.com/product?code=FLL&release.type=preview&release.type=eap&platform=linux_x64" --output fleet && chmod +x fleet

    if [[ "$_RUN" -eq "1" ]]; then
        ./fleet launch workspace -- --auth=accept-everyone --publish --enableSmartMode
    fi
}

# Action
# ---------------------------------------------------\
check_dest
check_distro

# TODO: If need in future - customize it
if [[ "$RPM" -eq "1" ]]; then
    echo "CentOS detected..."
    get_fleet
elif [[ "$RPM" -eq "2" ]]; then
    echo "Fedora detected..."
    get_fleet
elif [[ "$DEB" -eq "1" ]]; then
    echo "Debian detected..."
    get_fleet
else
    echo "Unknown distro. Exit."
    exit 1
fi