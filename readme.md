# robot_idl

Interface message definitions for the robot subsystems

# Setup

### Clone

Clone this repo into the desired workspace location

```bash
$ mkdir -p ~/robot_ws/src
$ git clone https://github.com/samlovelace/robot_idl.git
```

### Configure

The setup script can be used to install required dependencies and repos for a subset or all robot subsystems.

If all subsystems are desired, run

```bash
$ cd robot_idl/scripts
$ chmod +x setup.sh
$ sudo ./setup
```

If only a certain subset of subsystems are desired, pass the name of the subsystem to the setup script e.g. for manipulation and perception, run

```bash
$ cd robot_idl/scripts
$ chmod +x setup.sh
$ sudo ./setup.sh manipulation perception
```
