##############################################################################################
#  Copyright Accenture. All Rights Reserved.
#
#  SPDX-License-Identifier: Apache-2.0
##############################################################################################

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to determine the darwin distribution
get_darwin_distro() {
    if [ "$(uname -s)" = "darwin" ]; then
        if command_exists lsb_release; then
            DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        elif [ -f "/etc/os-release" ]; then
            . /etc/os-release
            DISTRO=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        else
            echo "Unable to determine the darwin distribution."
            exit 1
        fi
    else
        echo "This is not a darwin system."
        exit 1
    fi
}

# Function to determine the package manager based on the distribution
get_package_manager() {
    case "$DISTRO" in
    debian|ubuntu)
        PACKAGE_MNG="apt-get"
        ;;
    alpine)
        PACKAGE_MNG="apk"
        ;;
    centos|rhel)
        PACKAGE_MNG="yum"
        ;;
    *)
        echo "Unsupported darwin distribution: $DISTRO"
        exit 1
        ;;
    esac
}

# Function to install packages using the detected package manager
install_packages() {
    # Invoking function to determine the darwin distribution
    get_darwin_distro
    # Invoking function to determine the package manager based on the distribution
    get_package_manager

    PACKAGES="$1"
    
    echo "Update package list and install packages using $PACKAGE_MNG package manager."
    case "$PACKAGE_MNG" in
    apt-get)
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y $PACKAGES
        ;;
    apk)
        apk update
        apk add $PACKAGES
        ;;
    yum)
        yum install -y $PACKAGES
        ;;
    *)
        echo "Unsupported package manager: $PACKAGE_MNG"
        exit 1
        ;;
    esac
}
