#!/bin/bash

# ============================================
# Script to Uninstall All Python 3.x Versions Except 3.9
# Designed for Apple M1 Macs using Homebrew
# ============================================

# Define the Python version to keep
KEEP_VERSION="3.9"

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Please install Homebrew first:"
        echo "https://brew.sh/"
        exit 1
    fi
}

# Function to list installed Python@ versions via Homebrew
list_installed_pythons() {
    brew list --formula | grep "^python@"
}

# Function to uninstall a specific Python@ version
uninstall_python() {
    local formula="$1"
    echo "Uninstalling $formula..."
    brew uninstall --ignore-dependencies "$formula"
    if [ $? -eq 0 ]; then
        echo "$formula has been successfully uninstalled."
    else
        echo "Failed to uninstall $formula. Please check manually."
    fi
}

# Function to check if Python 3.9 is installed
check_keep_version() {
    if brew list --formula | grep -q "^python@${KEEP_VERSION}$"; then
        echo "Keeping Python ${KEEP_VERSION} as per user request."
    else
        echo "Python ${KEEP_VERSION} is not installed. Installing it now..."
        brew install "python@${KEEP_VERSION}"
        if [ $? -eq 0 ]; then
            echo "Python ${KEEP_VERSION} has been successfully installed."
        else
            echo "Failed to install Python ${KEEP_VERSION}. Please check manually."
            exit 1
        fi
    fi
}

# Main script execution starts here
echo "Starting Python cleanup script..."

# Step 1: Check for Homebrew
check_homebrew

# Step 2: Ensure Python 3.9 is installed
check_keep_version

# Step 3: List all installed Python@ versions
INSTALLED_PYTHONS=$(list_installed_pythons)

if [ -z "$INSTALLED_PYTHONS" ]; then
    echo "No Python@ versions are installed via Homebrew."
    exit 0
fi

echo "Installed Python@ versions:"
echo "$INSTALLED_PYTHONS"
echo "-----------------------------------"

# Step 4: Iterate and uninstall versions except Python 3.9
for formula in $INSTALLED_PYTHONS; do
    # Extract version number (e.g., python@3.8 -> 3.8)
    VERSION=$(echo "$formula" | grep -oE '[0-9]+\.[0-9]+')
    
    if [ "$VERSION" != "$KEEP_VERSION" ]; then
        uninstall_python "$formula"
    else
        echo "Retaining Python ${VERSION}."
    fi
done

echo "Python cleanup complete."

# Optional: Link Python 3.9 to make it the default python3
echo "Linking Python ${KEEP_VERSION} to make it the default python3..."
brew link --force --overwrite "python@${KEEP_VERSION}"

echo "All done!"
