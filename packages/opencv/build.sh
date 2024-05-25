#!/usr/bin/env bash
set -ex
echo "Building opencv-python ${OPENCV_VERSION}"

bash /tmp/opencv/install_deps.sh

cd /opt

git clone --branch ${OPENCV_VERSION} --recursive https://github.com/opencv/opencv.git /opt/opencv
git clone --branch ${OPENCV_VERSION} --recursive https://github.com/opencv/opencv_contrib.git /opt/opencv_contrib

# apply patches to setup.py
# git apply /tmp/opencv/patches.diff || echo "failed to apply git patches"
# git diff

# OpenCV looks for the cuDNN version in cudnn_version.h, but it's been renamed to cudnn_version_v8.h
ln -s /usr/include/$(uname -i)-linux-gnu/cudnn_version_v*.h /usr/include/$(uname -i)-linux-gnu/cudnn_version.h

# patches for FP16/half casts
sed -i 's|weight != 1.0|(float)weight != 1.0f|' opencv/modules/dnn/src/cuda4dnn/primitives/normalize_bbox.hpp
sed -i 's|nms_iou_threshold > 0|(float)nms_iou_threshold > 0.0f|' opencv/modules/dnn/src/cuda4dnn/primitives/region.hpp
grep 'weight' opencv/modules/dnn/src/cuda4dnn/primitives/normalize_bbox.hpp
grep 'nms_iou_threshold' opencv/modules/dnn/src/cuda4dnn/primitives/region.hpp

export ENABLE_CONTRIB=1
export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)
export CMAKE_ARGS="\
   -DCMAKE_BUILD_TYPE=Release \
   -DCPACK_BINARY_DEB=ON \
   -DBUILD_EXAMPLES=OFF \
   -DBUILD_opencv_python2=OFF \
   -DBUILD_opencv_python3=ON \
   -DBUILD_opencv_java=OFF \
   -DCMAKE_BUILD_TYPE=RELEASE \
   -DCMAKE_INSTALL_PREFIX=/usr/local \
   -DCUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
   -DCUDA_ARCH_PTX= \
   -DCUDA_FAST_MATH=ON \
   -DCUDNN_INCLUDE_DIR=/usr/include/$(uname -i)-linux-gnu \
   -DEIGEN_INCLUDE_PATH=/usr/include/eigen3 \
   -DWITH_EIGEN=ON \
   -DENABLE_NEON=ON \
   -DOPENCV_DNN_CUDA=ON \
   -DOPENCV_ENABLE_NONFREE=ON \
   -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
   -DOPENCV_GENERATE_PKGCONFIG=ON \
   -DOpenGL_GL_PREFERENCE=GLVND \
   -DWITH_CUBLAS=ON \
   -DWITH_CUDA=ON \
   -DWITH_CUDNN=ON \
   -DWITH_GTK=ON \
   -DWITH_OPENGL=OFF \
   -DWITH_OPENCL=OFF \
   -DWITH_IPP=OFF \
   -DWITH_TBB=ON \
   -DBUILD_TIFF=ON \
   -DBUILD_PERF_TESTS=OFF \
   -DBUILD_TESTS=OFF"

mkdir -p /opt/opencv/build
cd /opt/opencv/build
cmake ${CMAKE_ARGS} ..

 CFLAGS=-Wno-error make -j`nproc` && \
 CFLAGS=-Wno-error make install && \
    ldconfig && \
    ln -s /usr/local/lib/python3.10/site-packages/cv2 /usr/local/lib/python3.10/dist-packages/cv2 && \
    cd /opt && \
    rm -rf opencv opencv_contrib

python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"

