cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( disp VERSION 1.0.0 LANGUAGES C CXX )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( DCMTK_DIR ${External_DCMTK_DIR} )

# ITKVtkGlue in ITK 4.12.2 doesn't compile with VTK9.0.3 (new module structure). This is a backported
# patch in ITK4.12.2 to introduce the vtk_module_config which has been removed in VTK9 with a new module
# structure

if( NOT COMMAND vtk_module_config )
  macro(vtk_module_config ns)
    foreach(arg ${ARGN})
      if(${arg} MATCHES "^[Vv][Tt][Kk]")
        string(REGEX REPLACE "^[Vv][Tt][Kk]" "" _arg ${arg})
      else()
        set(_arg ${arg})
      endif()
    
      set(${ns}_LIBRARIES ${${ns}_LIBRARIES} VTK::${_arg})
    endforeach()
  endmacro()
endif()

find_package( ITK HINTS ${ITK_DIR} REQUIRED )
find_package( VTK HINTS ${VTK_DIR} REQUIRED )
find_package( DCMTK HINTS ${DCMTK_DIR} REQUIRED )

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

add_executable( disp )
add_dependencies( disp caplib )

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )
set( DISP_CPP_DIR ${COMMON_LIBS_DIR}/test/utils/disp )

target_sources( disp PRIVATE
  ${DISP_CPP_DIR}/disp.cxx

  # ${COMMON_LIBS_DIR}/dicomlib/dicom.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_DataDictionary.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_DataStructure.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_FileFormat.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_Helper.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_IOD.cpp
  ${COMMON_LIBS_DIR}/dicomlib/DICOM_VR_Types.cpp
  
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLDisplayInterface.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLRenderViewReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLColorTransferFunctionReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLColorTransferFunctionWriter.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLDisplayInterface.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLIOBase.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLKWParser.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLObjectReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLObjectWriter.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLPiecewiseFunctionReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLPiecewiseFunctionWriter.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLRenderViewBaseReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLRenderViewReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLVolumePropertyReader.cxx
  ${COMMON_LIBS_DIR}/SceneSerialization/XML/vtkXMLVolumePropertyWriter.cxx 
  )

target_link_directories( disp PRIVATE
  ${External_DCMTK_LIB_DIR}
  )

target_include_directories( disp PRIVATE
  ${CAPLIB_CPP_DIR}
  ${COMMON_LIBS_DIR}/configlib
  ${COMMON_LIBS_DIR}/dicomlib
  ${COMMON_LIBS_DIR}/SceneSerialization
  ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
  ${EVServer_BUILD_DIR}/services/c++/common/libs/SceneSerialization # for sceneserialization_export.h
  )

target_include_directories( disp SYSTEM PRIVATE
  ${ITK_INCLUDE_DIRS}
  ${VTK_INCLUDE_DIRS}
  ${DCMTK_INCLUDE_DIRS}
  ${External_BOOST_SOURCE_DIR}
  )

target_link_libraries( disp PRIVATE
  ${ITK_LIBRARIES}
  ${VTK_LIBRARIES}
  ${DCMTK_LIBRARIES}
  caplib
  )

target_compile_definitions( disp PRIVATE ${VTK_DEFINITIONS} )

set_target_properties( disp PROPERTIES
  CXX_STANDARD 14
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS ON
  )



# install(TARGETS disp DESTINATION ${INSTALL_DIR})
# target_link_libraries(disp caplib ${ITK_LIBRARIES} ${VTK_LIBRARIES} dicomlib)
# vtk_module_autoinit(TARGETS disp MODULES ${VTK_LIBRARIES} )

# add_executable( DisplaySceneTest DisplaySceneTest.cxx )
# add_dependencies( DisplaySceneTest caplib )

# install(TARGETS DisplaySceneTest DESTINATION ${INSTALL_DIR})
# target_link_libraries(DisplaySceneTest caplib ${ITK_LIBRARIES} ${VTK_LIBRARIES} dicomlib)
# vtk_module_autoinit(TARGETS DisplaySceneTest MODULES ${VTK_LIBRARIES} )

# hrp and FFR testing. Add the test with the -T directory to save the regression file
# and the -V baseline file. Environment variable for the config is specified too.
if (BUILD_TESTING)
  # add_wi_rendering_tests( "MUSC_FFR3_055/wi-ebbdf50b"
  #   "LeftCoronary/Emily.Jeffreys_20230118__readings.json"
  #   "LeftCoronary/Emily.Jeffreys_20230118_lumenSegmentation.nrrd,LeftCoronary/Emily.Jeffreys_20230118_wallSegmentation.nrrd"
  #   "LeftCoronary/Emily.Jeffreys_20230118__composition.multi.nrrd"
  #   "LeftCoronary/series_CT_0.json"
  # )

  # add_wi_rendering_tests( "Philips-13S/wi-16B2B751"
  #   "LeftCoronary/a-BatchProcessor_20220418000000000000__readings.json,RightCoronary/a-BatchProcessor_20220418000000000000__readings.json"
  #   "LeftCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,LeftCoronary/annajohannessen_20220418__wallSegmentation.nrrd,RightCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,RightCoronary/annajohannessen_20220418__wallSegmentation.nrrd"
  #   "LeftCoronary/BatchProcessor_20220418000000000000__composition.multi.nrrd,RightCoronary/BatchProcessor_20220418000000000000__composition.multi.nrrd"
  #   "LeftCoronary/series_CT_0.json"
  # )

  # add_wi_rendering_tests( "Philips-2S/wi-34F33192"
  #   "LeftCoronary/a-BatchProcessor_20220418000000000000__readings.json,RightCoronary/a-BatchProcessor_20220418000000000000__readings.json"
  #   "LeftCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,LeftCoronary/annajohannessen_20220418__wallSegmentation.nrrd,RightCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,RightCoronary/annajohannessen_20220418__wallSegmentation.nrrd"
  #   "LeftCoronary/BatchProcessor_20220418000000000000__composition.multi.nrrd,RightCoronary/BatchProcessor_20220418000000000000__composition.multi.nrrd"
  #   "LeftCoronary/series_CT_0.json"
  # )

  # add_wi_rendering_tests( "Philips-JO-K/wi-5EEDC784"
  #   "LeftCoronary/a-BatchProcessor_20220420000000000000__readings.json,RightCoronary/a-BatchProcessor_20220420000000000000__readings.json"
  #   "LeftCoronary/annajohannessen_20220420__lumenSegmentation.nrrd,LeftCoronary/annajohannessen_20220420__wallSegmentation.nrrd,RightCoronary/annajohannessen_20220420__lumenSegmentation.nrrd,RightCoronary/annajohannessen_20220420__wallSegmentation.nrrd"
  #   "LeftCoronary/BatchProcessor_20220420000000000000__composition.multi.nrrd,RightCoronary/BatchProcessor_20220420000000000000__composition.multi.nrrd"
  #   "LeftCoronary/series_CT_0.json"
  # )

  # add_wi_rendering_tests( "Philips-1U-TEST/wi-9EDC3940"
  #   "LeftCoronary/a-BatchProcessor_20220419000000000000__readings.json,RightCoronary/a-BatchProcessor_20220419000000000000__readings.json"
  #   "LeftCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,LeftCoronary/annajohannessen_20220418__wallSegmentation.nrrd,RightCoronary/annajohannessen_20220418__lumenSegmentation.nrrd,RightCoronary/annajohannessen_20220418__wallSegmentation.nrrd"
  #   "LeftCoronary/BatchProcessor_20220419000000000000__composition.multi.nrrd,RightCoronary/BatchProcessor_20220419000000000000__composition.multi.nrrd"
  #   "LeftCoronary/series_CT_0.json"
  # )

endif()
