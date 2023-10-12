#!/bin/bash

CMAKE_BUILD_TYPE=$1
VTK_SOURCE_DIR=$2
VTK_BUILD_DIR=$3
EVServer_DEPLOY_TYPE=$4
EVServer_RENDERING_BACKEND=$5
BUILD_TOOL_OPTIONS=$6

# In production build, turn off debug leak reporting of VTK objects lingering around after destruction.
# VTK_DEBUG_LEAKS is sort of like Java Garbage Collection. There is an overhead associated with it in
# terms of keeping track of objects instantiated.

if [ ${EVServer_DEPLOY_TYPE} == "Production" ]; then
    VTK_DEBUG_LEAKS=OFF
else
    VTK_DEBUG_LEAKS=ON
fi

if [ ${EVServer_RENDERING_BACKEND} == "HardwareOffScreen" ]; then
    VTK_USE_X=OFF
    VTK_OPENGL_HAS_EGL=ON
    VTK_OPENGL_HAS_OSMESA=OFF
    VTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON

elif [ ${EVServer_RENDERING_BACKEND} == "SoftwareOffScreen" ]; then
    VTK_USE_X=OFF
    VTK_OPENGL_HAS_EGL=OFF
    VTK_OPENGL_HAS_OSMESA=ON
    VTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON

elif [ ${EVServer_RENDERING_BACKEND} == "OnScreen" ]; then
    VTK_USE_X=ON
    VTK_OPENGL_HAS_EGL=OFF
    VTK_OPENGL_HAS_OSMESA=OFF
    VTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=OFF
fi

CMAKE_ARGS=" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF \
    -DVTK_BUILD_TESTING:BOOL=OFF \
    -DModule_vtkTestingRendering:BOOL=ON \
    -DVTK_BUILD_EXAMPLES:BOOL=OFF \
    -DVTK_Group_Qt:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_Group_Web:BOOL=ON \
    -DVTK_GROUP_ENABLE_Web:STRING=WANT \
    -DVTK_PYTHON_VERSION:STRING=3 \
    -DVTK_DEBUG_LEAKS:BOOL=${VTK_DEBUG_LEAKS} \
    -DVTK_USE_X:BOOL=${VTK_USE_X} \
    -DVTK_OPENGL_HAS_EGL:BOOL=${VTK_OPENGL_HAS_EGL} \
    -DVTK_OPENGL_HAS_OSMESA:BOOL=${VTK_OPENGL_HAS_OSMESA} \
    -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=${VTK_DEFAULT_RENDER_WINDOW_OFFSCREEN} \
    -DCMAKE_POLICY_DEFAULT_CMP0127=NEW \
    -S ${VTK_SOURCE_DIR} \
    -B ${VTK_BUILD_DIR} \
    "
#     -DVTK_MODULE_ENABLE_VTK_loguru=1 \

echo "CMAKE_ARGS=${CMAKE_ARGS}"

# Configure, generate, and build
cmake ${CMAKE_ARGS}
cmake --build ${VTK_BUILD_DIR} -- ${BUILD_TOOL_OPTIONS}
