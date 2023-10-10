/*=========================================================================

 Module: caplib

   Image test utilities

  Convenience methods to
   - read and write an image into VTK land and ITK land
   - Display an image at a user desired resolution

 Author: karthik.krishnan@elucidbio.com

 License: Use of this source code is governed by the LICENSE file

=========================================================================*/

#pragma once

#include <iostream>
#include "vtkRenderWindowInteractor.h"
#include "vtkMetaImageReader.h"
#include "vtkMetaImageWriter.h"
#include "vtkImageData.h"
#include "vtkSmartPointer.h"
#include "vtksys/SystemTools.hxx"
#include <vtkRenderWindow.h>
#include <vtkRenderer.h>
#include <vtkImageViewer2.h>
#include "vtkCamera.h"
#include "vtkLogger.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"

#include <string>
#include <sstream>

namespace ebv
{
  namespace Utils
  {

    class ImageUtils
    {
    public:
      /** Write an image in (optionally compressed) metaimage format */
      static void WriteMHA(vtkImageData *image, std::string filename, bool useCompression = true)
      {
        vtkSmartPointer<vtkMetaImageWriter> writer = vtkSmartPointer<vtkMetaImageWriter>::New();
        writer->SetInputData(image);
        writer->SetFileName(filename.c_str());
        if (useCompression)
        {
          writer->SetCompression(1);
        }

        std::cout << "Writing file: " << filename << " .. ";
        writer->Write();
        std::cout << "Done." << std::endl;
      }

      /** Read a volume */
      static vtkSmartPointer<vtkImageData> ReadMetaImageIntoVTK(std::string filename)
      {
        if (!vtksys::SystemTools::FileExists(filename.c_str(), true))
        {
          std::cout << "ReadMetaImageIntoVTK given File: " << filename << " which does not exist!" << std::endl;
          return NULL;
        }
        vtkSmartPointer<vtkMetaImageReader> reader = vtkSmartPointer<vtkMetaImageReader>::New();
        reader->SetFileName(filename.c_str());
        std::cout << "Reading file: " << filename << " .. ";
        reader->Update();
        std::cout << "Done." << std::endl;

        // Disconnect from the pipeline
        vtkSmartPointer<vtkImageData> output = vtkSmartPointer<vtkImageData>::New();
        output->ShallowCopy(reader->GetOutput());
        return output;
      }

      // Display and return the viewer.
      static vtkSmartPointer<vtkImageViewer2> ImDisplay(
          vtkImageData *image,
          bool interactorStart = true,
          double windowWidth = 675,
          double windowLevel = 175, // 0 to default to whole dynamic range
          int xsize = 800,
          int ysize = 800)
      {

        // create vtk pipeline
        vtkSmartPointer<vtkRenderer> renderer = vtkSmartPointer<vtkRenderer>::New();
        vtkSmartPointer<vtkRenderWindow> renderWindow = vtkSmartPointer<vtkRenderWindow>::New();
        renderWindow->AddRenderer(renderer);

        vtkSmartPointer<vtkRenderWindowInteractor> interactor = vtkSmartPointer<vtkRenderWindowInteractor>::New();
        interactor->SetRenderWindow(renderWindow);

        vtkSmartPointer<vtkImageViewer2> viewer = vtkSmartPointer<vtkImageViewer2>::New();
        viewer->SetInputData(image);
        viewer->SetupInteractor(interactor);

        // default it
        if (windowLevel == 0)
        {
          windowWidth = image->GetScalarRange()[1] - image->GetScalarRange()[0];
          windowLevel = (image->GetScalarRange()[1] + image->GetScalarRange()[0]) / 2;
        }

        viewer->SetSize(xsize, ysize);
        viewer->SetColorWindow(windowWidth);
        viewer->SetColorLevel(windowLevel);

        renderer->GetActiveCamera()->ParallelProjectionOn();

        renderer->ResetCamera();
        renderer->ResetCameraClippingRange();

        interactor->Initialize();

        // Render
        viewer->Render();

        if (interactorStart)
        {
          // blocking event loop
          interactor->Start();
        }

        return viewer;
      }
    };

  } // end namespace
} // end namespace