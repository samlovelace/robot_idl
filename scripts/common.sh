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

install_ros() {
    echo "[ROS] Starting installation of ROS 2 Humble..."

    # --- Configure UTF-8 Locale ---
    if ! locale | grep -q "UTF-8"; then
        echo "[ROS] Configuring UTF-8 locale..."
        apt install -y locales
        locale-gen en_US en_US.UTF-8
        update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
        export LANG=en_US.UTF-8
    fi

    # --- Set Timezone Non-Interactively ---
    echo "[ROS] Setting timezone to America/New_York..."
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
    DEBIAN_FRONTEND=noninteractive apt install -y tzdata
    dpkg-reconfigure -f noninteractive tzdata

    # --- Add Required Tools ---
    apt install -y software-properties-common curl gnupg lsb-release

    # --- Add Universe Repo ---
    add-apt-repository universe

    # --- Add ROS 2 GPG Key ---
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg

    # --- Add ROS 2 Repository ---
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
        http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/ros2.list
    # --- Install ROS 2 Humble and Tools ---
    apt update
    apt install -y ros-humble-desktop \
                   python3-colcon-common-extensions \
                   python3-rosdep \
                   python3-vcstool

    # --- Source ROS Environment ---
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    source /opt/ros/humble/setup.bash
    echo "[✔] ROS 2 Humble installed and environment sourced."
}
