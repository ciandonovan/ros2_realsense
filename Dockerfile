FROM ros:jazzy-ros-base AS base

# install packages
RUN apt-get update && apt-get install --no-install-recommends -y \
        ros-$ROS_DISTRO-realsense2-camera \
        && rm -rf /var/lib/apt/lists/*
