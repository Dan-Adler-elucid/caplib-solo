/*=========================================================================

 Module: caplib

   Image test utilities

  Convenience methods to
   - read and write a mesh

 Author: karthik.krishnan@elucidbio.com

 License: Use of this source code is governed by the LICENSE file

=========================================================================*/
#pragma once

#include "ebFileSystem.h"
#include "vtkAppendPolyData.h"
#include "vtkCellArray.h"
#include "vtkFlyingEdges3D.h"
#include "vtkGlyph3D.h"
#include "vtkImageData.h"
#include "vtkMetaImageWriter.h"
#include "vtkPoints.h"
#include "vtkPolyData.h"
#include "vtkPolyDataConnectivityFilter.h"
#include "vtkPolyDataMapper.h"
#include "vtkPolyDataReader.h"
#include "vtkPolyDataWriter.h"
#include "vtkSmartPointer.h"
#include "vtkSphereSource.h"
#include "vtkTransform.h"
#include "vtkTransformPolyDataFilter.h"
#include "vtkWindowLevelLookupTable.h"
#include "vtkXMLPolyDataReader.h"
#include "vtkXMLPolyDataWriter.h"

namespace ebv
{
  namespace Utils
  {

    class MeshUtils
    {
    public:
      /** Write a mesh with a postfix or id that's
       appended to the filename on the fly */
      static void Write(int id, vtkPolyData *pd, std::string filename)
      {
        std::ostringstream fname;
        fname << filename << "_" << id << ".vtk" << std::ends;
        Write(pd, fname.str());
      }

      /** Write a mesh  */
      static void Write(vtkPolyData *pd, std::string filename)
      {
        vtkNew<vtkXMLPolyDataWriter> pdw;
        pdw->SetInputData(pd);
        pdw->SetFileName(filename.c_str());
        std::cout << "Writing mesh " << filename << " .. ";
        pdw->Write();
        std::cout << "Done. " << std::endl;
      }

      static vtkSmartPointer<vtkPolyData> Read(std::string filename)
      {
        // TODO in C++17
        // std::filesystem::path path = filename;
        // std::string ext = path.extension();
        std::string prefix, ext;
        GetPrefixAndExtension(filename, prefix, ext);
        if (ext == ".vtk")
        {
          return ReadVTK(filename);
        }
        else if (ext == ".vtp")
        {
          return ReadVTP(filename);
        }
        else
        {
          std::cout << "Unexpected file type " << ext << std::endl;
          return vtkSmartPointer<vtkPolyData>();
        }
      }

      /** Read a VTP file  */
      static vtkSmartPointer<vtkPolyData> ReadVTP(std::string filename)
      {
        auto pdr = vtkSmartPointer<vtkXMLPolyDataReader>::New();
        pdr->SetFileName(filename.c_str());

        std::cout << "Reading VTP file " << filename << " .. ";
        pdr->Update();

        // Disconnect from the pipeline (shallow copy in VTK parlance)
        auto output = vtkSmartPointer<vtkPolyData>::New();
        output->ShallowCopy(pdr->GetOutput());
        std::cout << "Done. [Contains " << output->GetNumberOfPoints() << " points.]" << std::endl;

        return output;
      }

      /** Read a VTK mesh  */
      static vtkSmartPointer<vtkPolyData> ReadVTK(std::string filename)
      {
        auto pdr = vtkSmartPointer<vtkPolyDataReader>::New();
        pdr->SetFileName(filename.c_str());
        std::cout << "Reading VTK mesh " << filename << " .. ";
        pdr->Update();

        // Disconnect from the pipeline (shallow copy in VTK parlance)
        auto output = vtkSmartPointer<vtkPolyData>::New();
        output->ShallowCopy(pdr->GetOutput());
        std::cout << "Done. [Contains " << output->GetNumberOfPoints() << " points.]" << std::endl;

        return output;
      }

      /** Helper to create as many renderers as there are polydatas and add to window  */
      static void AddPolysToRenderWindow(std::vector<vtkPolyData *> pds, vtkRenderWindow *renwin,
          double windowWidth, double windowLevel)
      {
        int numPolys = pds.size();
        for (int i = 0; i < numPolys; i++)
        {
          auto pd = pds[i];
          auto mapper = vtkSmartPointer<vtkPolyDataMapper>::New();
          mapper->SetInputData(pd);

          auto actor = vtkSmartPointer<vtkActor>::New();
          actor->SetMapper(mapper);

          if (windowLevel == 0)
          {
            windowWidth = pd->GetScalarRange()[1] - pd->GetScalarRange()[0];
            windowLevel = (pd->GetScalarRange()[1] + pd->GetScalarRange()[0]) / 2;
          }
          auto lut = vtkSmartPointer<vtkWindowLevelLookupTable>::New();
          lut->SetWindow(windowWidth);
          lut->SetLevel(windowLevel);
          mapper->SetLookupTable(lut);
          mapper->UseLookupTableScalarRangeOn();

          auto renderer = vtkSmartPointer<vtkRenderer>::New();
          renderer->AddActor(actor);
          renwin->AddRenderer(renderer);

          double xMin = (double)i / numPolys;
          double xMax = (double)(i + 1) / numPolys;
          renderer->SetViewport(xMin, 0, xMax, 1);
        }
      }

      // Display a polydata and return the window.
      static vtkSmartPointer<vtkRenderWindow> DisplayPolyData(vtkPolyData *pd,
          bool interactorStart = true, std::string name = "PolyData Test", double windowWidth = 675,
          double windowLevel = 175, // 0 to default to whole dynamic range
          int xsize = 800, int ysize = 800)
      {
        return DisplayPolyDatas(
            {pd}, interactorStart, name, windowWidth, windowLevel, xsize, ysize);
      }

      // Display multiple polydatas and return the window.
      static vtkSmartPointer<vtkRenderWindow> DisplayPolyDatas(std::vector<vtkPolyData *> pds,
          bool interactorStart = true, std::string name = "PolyData Test", double windowWidth = 675,
          double windowLevel = 175, // 0 to default to whole dynamic range
          int xsize = 800, int ysize = 800)
      {
        auto renwin = vtkSmartPointer<vtkRenderWindow>::New();
        renwin->SetSize(xsize, ysize);
        renwin->SetPosition(0, 0);
        renwin->SetWindowName(name.c_str());

        AddPolysToRenderWindow(pds, renwin, windowWidth, windowLevel);

        auto interactor = vtkSmartPointer<vtkRenderWindowInteractor>::New();
        interactor->SetRenderWindow(renwin);

        interactor->Initialize();

        // Render
        renwin->Render();

        if (interactorStart)
        {
          // blocking event loop
          interactor->Start();
        }

        return renwin;
      }
    };

  } // end namespace
} // end namespace
