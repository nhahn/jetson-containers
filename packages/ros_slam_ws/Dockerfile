# syntax=docker/dockerfile:1.7-labs
#---
# name: ros_slam_ws
# group: robotics
# depends: [ros:humble-ros-base, slam_libs]
# notes: installs ffmpeg
# test: test.sh
#---

ARG BASE_IMAGE
FROM ${BASE_IMAGE}


###########################################################################
##
##  CUDA Compiled ROS Dependencies
##
###########################################################################
WORKDIR /opt/ros_cuda
RUN mkdir src
# TODO make sure all of these are built from source (using cuda)
# Use rosinstall_generator instead of ADD where possible
#cv_bridge \
#vision_opencv \
#vision_msgs \
#image_geometry \
#image_pipeline \
#image_transport \
#compressed_image_transport \
#compressed_depth_image_transport \
ADD https://github.com/ros-perception/vision_opencv.git#${ROS_DISTRO} src/vision_opencv
ADD https://github.com/Box-Robotics/ros2_numpy.git#${ROS_DISTRO} src/ros2_numpy
ADD https://github.com/lajoiepy/cslam_interfaces.git src/cslam_interfaces
ADD https://github.com/uos/lvr2.git#${ROS_DISTRO} src/lvr2
ADD https://github.com/naturerobots/mesh_tools.git#${ROS_DISTRO} src/mesh_tools
ADD https://github.com/ros-drivers/audio_common.git#ros2 /opt/audio_common
ADD https://github.com/ros-perception/perception_pcl.git#${ROS_DISTRO} src/perception_pcl
RUN mv /opt/audio_common/audio_common_msgs ./src
RUN git clone https://github.com/introlab/rtabmap_ros.git && \
    cd rtabmap_ros && \
    git checkout bfef9ee && \
    cd ../ && \
    cp -r rtabmap_ros/rtabmap_conversions src && \
    rm -rf rtabmap_ros
ARG skip_keys="rtabmap libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv image_geometry rtabmap_conversions cslam_common_interfaces"
RUN . /opt/ros/${ROS_DISTRO}/setup.sh &&\
    rosdep update &&\
    rosdep install --from-paths src --ignore-src -r -y --skip-keys "${skip_keys}"
RUN apt-get remove ros-${ROS_DISTRO}-cv-bridge -q -y --no-install-recommends
RUN apt autoremove -y
RUN apt-get update && apt-get install -y --no-install-recommends ros-humble-sensor-msgs ros-humble-laser-geometry ros-humble-nav2-msgs
COPY ./colcon_defaults.yaml /root/.colcon/defaults.yaml
COPY ./colcon_entrypoint.sh /colcon_entrypoint.sh
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build
