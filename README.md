# Requirements:
  - Ubuntu 24.04+
  - At least one Intel RealSense D435
  - At least one other V4L2 device, including other RealSenses

# Background

[PR #11900](https://github.com/IntelRealSense/librealsense/pull/11900) introduced the ability to run librealsense in unprivileged rootless containers without the entire /dev/ directory bind-mounted in. The enumeration of V4L2 devices is subject to race conditions—the same camera is not not always mapped to the same /dev/videoX devnodes. To deterministically resolve this, udev rules can be written to map exact cameras to particular symlinked known-names in /dev. The problem is the the old enumeration system parsed /sys/ to find the V4L2 devices, and expected them to be named the same in /dev/, which wouldn't be the case if they were renamed and in a container namespace. This is the cause of the device not found error.

The solution was to check the devnode major and minor numbers, which are the kernel's true view and unique identifiers, and find the associated devnode in /dev/, no matter what the name is.

This allowed device identification and naming to be handled at the udev layer, with each RealSense mapped into their own containers, with librealsense implicitly picking up the camera as in its namespace view that was the only one connected to the system, no extra params needed.

Unfortunately, [#PR #13296](https://github.com/IntelRealSense/librealsense/pull/13296) reverted this functionality, and now subsets of /dev/ bind-mounted into different containers no longer works with librealsense, since around v2.56.1

Below is a reproducible example of the setup described and how it currently fails.

# Description

The script `run.sh` first updates the apt cache and installs the Podman container runtime. It then installs the udev rules file `/etc/udev/rules.d/99-realsense.rules` which deterministically names a RealSense D435 device plugged into the system through symlinks in /dev/. Once installs it reloads the udev system to apply the rules immediately.

Podman is then used to build a container image from the supplied Dockerfile, which simply installs the RealSense stack from the upstream Jazzy distro.

An unprivileged rootless container is then run, sharing the host's network and IPC namespaces, bind-mounting the Intel RealSense D435 devnodes inside, and running the standard launch file.

It should not be necessary to specify which device to use with launch params, as only one device was bind-mounted in. This worked perfectly fine with librealsense v2.55, but has since regressed...

# Running

Enable executable bit on the script with `chmod +x run.sh`

Run as a normal rootless user the script `./run.sh`

N.B. DO NOT RUN AS ROOT! It will prompt for sudo password where necessary.
