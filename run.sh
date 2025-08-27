#/bin/sh

# install Podman
sudo apt update && sudo apt install podman

# copy and load udev rules file
sudo install -m 644 99-realsense.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl restart systemd-udevd && sudo systemctl restart systemd-udev-trigger

# build container
podman build -t localhost/$(basename $PWD) .

# run container
/usr/bin/podman run --rm \
--name ros2_realsense \
--stop-signal=SIGINT \
--tz=local \
--ipc=host \
--net=host \
--annotation run.oci.keep_original_groups=1 \
--device=/dev/realsense_depth_media:/dev/media0:rw \
--device=/dev/realsense_rgb_media:/dev/media1:rw \
--device=/dev/realsense_depth_left_video:/dev/video0:rw \
--device=/dev/realsense_depth_left_video_meta:/dev/video1:rw \
--device=/dev/realsense_depth_right_video:/dev/video2:rw \
--device=/dev/realsense_depth_right_video_meta:/dev/video3:rw \
--device=/dev/realsense_rgb_video:/dev/video4:rw \
--device=/dev/realsense_rgb_video_meta:/dev/video5:rw \
localhost/ros2_realsense \
ros2 launch realsense2_camera rs_launch.py
