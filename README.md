# Requirements:
  - Ubuntu 24.04+
  - At least one Intel RealSense D435
  - At least one other V4L2 device, including other RealSenses

# Description

The script `run.sh` first updates the apt cache and installs the Podman container runtime. It then installs the udev rules file `/etc/udev/rules.d/99-realsense.rules` which deterministically names a RealSense D435 device plugged into the system through symlinks in /dev/. Once installs it reloads the udev system to apply the rules immediately.

Podman is then used to build a container image from the supplied Dockerfile, which simply installs the RealSense stack from the upstream Jazzy distro.

An unprivileged rootless container is then run, sharing the host's network and IPC namespaces, bind-mounting the Intel RealSense D435 devnodes inside, and running the standard launch file.

It should not be necessary to specify which device to use with launch params, as only one device was bind-mounted in. This worked perfectly fine with librealsense v2.55, but has since regressed...

# Running

Enable executable bit on the script with `chmod +x run.sh`

Run as a normal rootless user the script `./run.sh`

N.B. DO NOT RUN AS ROOT! It will prompt for sudo password where necessary.
