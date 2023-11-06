cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

project( caplib VERSION 1.0.0 LANGUAGES C CXX )

# Configuration types is used in IDEs
if( NOT CMAKE_CONFIGURATION_TYPES )
    set( CMAKE_CONFIGURATION_TYPES Release )
endif()

if( NOT CMAKE_BUILD_TYPE )
    set( CMAKE_BUILD_TYPE Release )
endif()

message( "Generated with CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}" )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( DCMTK_DIR ${External_DCMTK_DIR} )
set( IVAN_DIR ${External_IVANTK_DIR} )

find_package( ITK HINTS ${ITK_DIR} REQUIRED )
find_package( VTK HINTS ${VTK_DIR} REQUIRED )
find_package( DCMTK HINTS ${DCMTK_DIR} REQUIRED )
find_package( IVAN HINTS ${IVAN_DIR} REQUIRED )

if( ITK_FOUND )
    include( ${ITK_USE_FILE} )
else()
    message( FATAL_ERROR "ITK was not found. Please set ITK_DIR." )
endif()

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()

if( NOT DCMTK_FOUND )
    message( FATAL_ERROR "DCMTK was not found. Please set DCMTK_DIR." )
endif()

if( IVAN_FOUND )
    include( ${IVAN_USE_FILE} )
else()
    message( FATAL_ERROR "IVAN library not found. Please set IVAN_DIR." )
endif()

if( CMAKE_BUILD_TYPE STREQUAL "Release" )
    set( IVAN_LIBRARIES
        ivanCommon
        ivanITK
    )
elseif( CMAKE_BUILD_TYPE STREQUAL "Debug" )
    set( IVAN_LIBRARIES
        ivanCommond
        ivanITKd
    )
endif()


set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )

set( CAPLIB_SOURCES
    command_line.cpp
    CornerTextInfo.cxx

    ebCrossHairsListener.h
    ebCrossHairsTransformHelpers.h
    ebDICOMtoNRRDConverter.cxx
    ebFileSystem.cxx

    ebiAnalyte.cxx
    ebiProgressToDispatchCommand.cxx
    ebiVesselCrossSection.cxx
    ebiVesselLesion.cxx
    ebiVesselSegment.cxx
    ebiVesselTarget.cxx
    ebiVesselTargetPipeline.cxx

    ebLog.cxx

    ebvAbstractAttributeLookupTable.cxx
    ebvAortaSurfaceActor.cxx
    ebvAxisActor2D.cxx
    ebvCalloutActor2D.cxx
    ebvCaptionRepresentation.cxx
    ebvCaptionWidget.cxx
    ebvCenteringPointPlacer.cxx
    ebvColorDictionary.cxx
    ebvColorMappedVessel3DActor.cxx
    ebvContourTriangulator.cxx
    ebvCPRFFRHRPActor.cxx
    ebvCPRFFRHRPAttributeGenerator.cxx
    ebvCPRFFRHRPFilter.cxx
    ebvCPRFFRHRPInteractorStyle.cxx
    ebvCPRFilter.cxx
    ebvCranLAORepresentation.cxx
    ebvCranLAOWidget.cxx
    ebvCrossHairsCallback.cpp
    ebvCrossHairsCallback.h
    ebvCrossHairsWidget.cpp
    ebvCrossHairsWidget.h
    ebvCurvedPlanarReformationFilter.cxx
    ebvDisplayScene.cxx
    ebvDistanceWidget.cxx
    ebvDistanceWidget2D.cxx
    ebvDistanceWidget3D.cxx
    ebvElucidLogoActor.cxx
    ebvFFRLookupTable.cxx
    ebvFFRScalarBarActor.cxx
    ebvFlyingEdges2D.cxx
    ebvFlyingEdges3D.cxx
    ebvFrenetSerretRefFrame.cxx
    ebvHRP2DLookupTable.cxx
    ebvHRPLookupTable.cxx
    ebvHRPScalarBarActor.cxx
    ebvImageMapToColors.cxx
    ebvImageMapToWindowLevelColors.cxx
    ebvImageMorphRepresentation.cxx
    ebvImageMorphWidget.cxx
    ebvImageReslice.cxx
    ebvInteractorStyleSwitcher.cxx
    ebvLesionMarkerActor2D.cxx
    ebvLesionOverlayActor2D.cxx
    ebvLineRepresentation.cxx
    ebvLineRepresentation.h
    ebvLineWidget.cxx
    ebvLineWidget.h
    ebvLinkedViewers2.cxx
    ebvLinkedViewersCursor.cxx
    ebvLinkedViewersCursorSource.cxx
    ebvLinkedViewersImage4.cxx
    ebvLinkedViewersScene.cxx
    ebvLinkedViewersSegmentation4.cxx
    ebvLinkedViewersVesselTarget.cxx
    ebvLinkedViewersVesselTargetMap.cxx
    ebvLinkedViewersVisualObject.cxx
    ebvLumenSurfaceModelGenerator.cxx
    ebvMouse.cxx
    ebvOrientationCubeWidget.cxx
    ebvPointHandleRepresentation3D.cxx
    ebvPointHandleRepresentation3D.h
    ebvPolyDataLSFitter.cxx
    ebvRegionOfInterestRepresentation.cxx
    ebvRegionOfInterestWidget.cxx
    ebvRenderMonitor.cxx
    ebvRenderWindowProxy.cxx
    ebvRenderWindowProxyFactory.cxx
    ebvResourceUtilities.cxx
    ebvRulerRepresentation.cxx
    ebvScaleActor2D.cxx
    ebvScaleBarWidget.cxx
    ebvSegmentationEditorRepresentation.cxx
    ebvSegmentationEditorWidget.cxx
    ebvSmartVolumeMapper.cxx
    ebvStenosisLookupTable.cxx
    ebvSystemInformation.cxx
    ebvTimeProbe.cxx
    ebvVesselAnalysis.cxx
    ebvVesselCenterline.cxx
    ebvVesselGraphToMeshAttributeInterpolator.cxx
    ebvVesselNameAdapter.cxx
    ebvVesselNameDictionary.cxx
    ebvVesselOrderDictionary.cxx
    ebvVesselTargetInitializationWidget.cxx
    ebvVesselTargetPointPlacer.cxx
    ebvVesselTraverserBase.cxx
    ebvVesselTraverserStraightened.cxx
    ebvVesselTraverserStraightened.h
    ebvVesselTraverserStretched.cxx
    ebvViewer.cxx
    ebvViewer2D.cxx
    ebvViewer2DInteractorStyle.cxx
    ebvViewer3D.cxx
    ebvViewer3DInteractorStyle.cxx
    ebvViewerInteractorCallbacks.cxx
    ebvViewerChart.cxx
    ebvViewerCPR.cxx
    ebvViewerCPRFFRHRP.cxx
    ebvViewerCPRInteractorStyle.cxx
    ebvViewerSpatial.cxx
    ebvVolumeMidPointPicker.cxx
    ebvVTK3DWidget.cxx

    EVEventDispatcher.cxx
    string_parsing.cpp
    vnl_helpers.cpp
    vnl_helpers.h

    vtkBalloonWidgetBugFix.cxx
    vtkBarChartActorBugFix.cxx
    vtkBorderRepresentationBugFix.cxx
    vtkCornerAnnotationBugFix.cxx
    vtkDiskSource2.cxx
    vtkLogoRepresentationBugFix.cxx
    vtkOrientationMarkerWidgetBugFix.cxx
    vtkSeedWidgetBugFix.cxx
    vtkStackedImageReader.cxx
)

list( TRANSFORM CAPLIB_SOURCES PREPEND ${CAPLIB_CPP_DIR}/ )

message( STATUS "VTK_OPENGL_HAS_EGL = ${VTK_OPENGL_HAS_EGL}" )
message( STATUS "VTK_OPENGL_HAS_MESA = ${VTK_OPENGL_HAS_MESA}" )

if( VTK_OPENGL_HAS_EGL )
    set( EBV_COMPILE_DEFINITIONS EBV_USE_EGL )
    find_package( OpenGL REQUIRED COMPONENTS OpenGL EGL GLX )

    set( PROXY_SOURCES ${CAPLIB_CPP_DIR}/ebvEGLRenderWindowProxy.cxx )
    set( CAPLIB_SOURCES ${CAPLIB_SOURCES} ${CAPLIB_CPP_DIR}/ebvEGLRenderWindow.cxx ) # Use custom EGL window
    set( GRAPHICS_INCLUDE_DIRS ${OPENGL_INCLUDE_DIRS} ${EGL_INCLUDE_DIRS} )

elseif( VTK_OPENGL_HAS_MESA ) # VTK_OPENGL_HAS_OSMESA?
    set( EBV_COMPILE_DEFINITIONS EBV_USE_MESA )

else()
    set( EBV_COMPILE_DEFINITIONS EBV_USE_X )
    set( PROXY_SOURCES ${CAPLIB_CPP_DIR}/ebvXOpenGLRenderWindowProxy.cxx )
endif()

add_library( caplib ${CAPLIB_LINKAGE} )

target_sources( caplib PRIVATE
    ${CAPLIB_SOURCES}
    ${PROXY_SOURCES}
)

target_link_directories( caplib PRIVATE
    ${External_DCMTK_LIB_DIR}
    ${IVAN_LIBRARY_DIRS}
)

target_include_directories( caplib PRIVATE
    ${CAPLIB_CPP_DIR}
    ${COMMON_LIBS_DIR}/configlib
    ${COMMON_LIBS_DIR}/dicomlib
    ${COMMON_LIBS_DIR}/SceneSerialization
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
    ${EVServer_BUILD_DIR}/services/c++/common/libs/SceneSerialization # for sceneserialization_export.h
)

# These are 'system' includes in order to ignore compiler warnings:
target_include_directories( caplib SYSTEM PRIVATE
    ${ITK_INCLUDE_DIRS}
    ${VTK_INCLUDE_DIRS}
    ${DCMTK_INCLUDE_DIRS}
    ${IVAN_INCLUDE_DIRS}
    ${External_BOOST_BUILD_DIR}
    ${GRAPHICS_INCLUDE_DIRS}
)

target_link_libraries( caplib PRIVATE
    configlib
    dicomlib
    SceneSerialization
    ${ITK_LIBRARIES}
    ${VTK_LIBRARIES}
    ${DCMTK_LIBRARIES}
    ${IVAN_LIBRARIES}
)

target_compile_definitions( caplib PRIVATE
    ${EBV_COMPILE_DEFINITIONS}
    ${VTK_DEFINITIONS}
)

target_compile_options( caplib PRIVATE
#       -Werror
#       -Wall -Wextra -Wpointer-arith -Winit-self -Wunreachable-code
       -Wno-error=array-bounds
       -Wno-error=empty-body
       -Wno-error=maybe-uninitialized
       -Wno-error=stringop-overflow
       -Wno-sign-compare
       -g -ftrapv
#       -Wconversion -Wsign-conversion
       -Wshadow
    -O3
)

set_target_properties( caplib PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)
