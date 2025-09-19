# Function to check and install a package 
check_and_install() {
    PKG="$1"
    CUSTOM_INSTALL_FUNC="$2"

    if dpkg -s "$PKG" >/dev/null 2>&1; then
        echo "[✔] $PKG is already installed."
    else
        echo "[✘] $PKG is not installed."

        if [ -n "$CUSTOM_INSTALL_FUNC" ] && declare -f "$CUSTOM_INSTALL_FUNC" > /dev/null; then
            echo "[↪] Using custom install function: $CUSTOM_INSTALL_FUNC"
            "$CUSTOM_INSTALL_FUNC"
        else
            echo "[↪] Installing $PKG via apt..."
            apt update && apt install -y "$PKG"
        fi
    fi
}

