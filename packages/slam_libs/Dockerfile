# syntax=docker/dockerfile:1.7-labs
#---
# name: slam_libs
# group: robotics
# depends: [opencv:4.9.0-builder, numpy, ros:humble-ros-base]
# notes: installs ffmpeg
# test: test.sh
#---

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

###########################################################################
##
## SuiteSparse (w/ CUDA) install
##
###########################################################################
WORKDIR /opt
RUN apt-get update && apt-get install --no-install-recommends -y ros-${ROS_DISTRO}-sophus libmpfr-dev libgmp-dev libboost-all-dev ros-${ROS_DISTRO}-libg2o libpcl-dev
ADD https://github.com/DrTimothyAldenDavis/SuiteSparse.git#v7.7.0 SuiteSparse
RUN cd SuiteSparse && mkdir -p build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_CUDA=1 -DSUITESPARSE_CUDA_ARCHITECTURES="60;61;70;75;80;86;89;90" -DGRAPHBLAS_COMPACT=1 .. && \
    cmake --build . && \
    cmake --install . && \
    ldconfig && \
    cd ../../ && \
    rm -rf SuiteSparse
###########################################################################
##
## Custom GTSAM Build with CUDA and SuiteSparse
##
###########################################################################  
WORKDIR /opt
ADD https://github.com/nhahn/gtsam.git gtsam
RUN cd gtsam && mkdir -p build && cd build && \
    cmake -DGTSAM_WITH_SUITESPARSE=1 -DGTSAM_WITH_CUSPARSE=1 -DGTSAM_ALLOW_DEPRECATED_SINCE_V43=OFF \
    -DGTSAM_USE_SYSTEM_EIGEN=ON -DEIGEN_USE_BLAS=1 -DEIGEN_USE_LAPACKE=1 -DEIGEN_USE_LAPACKE_STRICT=1 .. && \
    make install && \
    ldconfig && \
    cd ../../ && \
    rm -rf gtsam
###########################################################################
##
##  PCL Library
##
###########################################################################
# WORKDIR /opt
# RUN apt-get install --no-install-recommends -y \
#     libsqlite3-dev git cmake libflann-dev libproj-dev libqt5svg5-dev libboost-all-dev libqhull-dev libvtk9-dev libvtk9-qt-dev
# ADD https://github.com/PointCloudLibrary/pcl.git#pcl-1.13.1 pcl
# RUN mkdir pcl/build && cd pcl/build && \
#     cmake -DCMAKE_BUILD_TYPE=Release -DWITH_CUDA=ON .. && \
#     make -j`nproc` && \
#     make -j`nproc` install && \
#     ldconfig && \
#     cd /opt && \
#     rm -rf pcl
###########################################################################
##
##  SWARM-SLAM C++ Dependencies (RTABMAP, Torch w/ CUDA, TEASER++)
##
###########################################################################
WORKDIR /opt
ADD https://github.com/MIT-SPARK/TEASER-plusplus.git TEASER-plusplus
RUN cd TEASER-plusplus &&\
    mkdir build &&\
    cd build &&\
    cmake -DTEASERPP_PYTHON_VERSION=3.10 .. &&\
    make teaserpp_python &&\
    cd python &&\
    pip3 install .

RUN --mount=type=cache,target=/root/.cache \
    pip3 install open3d Pillow sortedcontainers distinctipy --ignore-installed

RUN git clone https://github.com/laurentkneip/opengv.git && \
    cd opengv && \
    git checkout 91f4b19c73450833a40e463ad3648aae80b3a7f3 && \
    wget https://gist.githubusercontent.com/matlabbe/a412cf7c4627253874f81a00745a7fbb/raw/accc3acf465d1ffd0304a46b17741f62d4d354ef/opengv_disable_march_native.patch && \
    git apply opengv_disable_march_native.patch && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && \
    rm -r opengv
# Will be used to read/store databases on host
RUN mkdir -p /root/Documents/RTAB-Map && chmod 777 /root/Documents/RTAB-Map
ENV TORCH_CUDA_ARCH_LIST="8.0 8.6 8.9 9.0"
# Build RTAB-Map project
ADD https://github.com/introlab/rtabmap.git#0.21.4-${ROS_DISTRO} rtabmap
RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" && \
    cd rtabmap/build && \
    cmake -DWITH_OPENGV=ON -DWITH_GTSAM=OFF -DOpenCV_DIR=/opt/opencv -DCMAKE_CXX_STANDARD=17 -DWITH_PYTHON=ON .. && \
 #   -DWITH_TORCH=ON -DTorch_DIR=/opt/libtorch/share/cmake/Torch/ && \
    make -j`nproc` && \
    make install && \
    ldconfig && \
    cd ../.. && \
    rm -rf rtabmap

