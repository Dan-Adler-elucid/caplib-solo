/*=========================================================================

 Module: caplib

   Test for the stretched CPR

    Read also
      "CPR - Curved Planar Reformation", IEEE Visualization 2002.
     http://www.cg.tuwien.ac.at/research/vis/adapt/Vis2002/AKanitsar_CPR.pdf

 Author: karthik.krishnan@elucidbio.com

 License: Use of this source code is governed by the LICENSE file

=========================================================================*/
/**
 * Sample args:
 *
 * --CTA CTA.mha --Centerline centerline1.vtk --Output cpr.mha --Theta 0 --Interpolation 3  --ThickResolution 0.3 --Pad 10
 *
 * --CTA CTA.mha --Centerline centerline2.vtk --Output cpr.mha --Theta 0 --Interpolation 3  --ThickResolution 0.3 --Pad 10 --Thick --Thickness 5
 *
 */

#include "ebvImageTestUtils.h"
#include "ebvMeshTestUtils.h"
#include "ebvCPRFilter.h"
#include "ebvVesselCenterline.h"
#include "ebvVesselTraverserStretched.h"
#include "vtksys/CommandLineArguments.hxx"
#include "ebvTimeProbe.h"
#include "vtkLogger.h"


// Parse arguments
void StretchedVesselReformatTestParseArguments( int argc, char *argv[],
    std::string &CT,
    std::string &centerline,
    bool &animate,
    int &interp,
    double &extra,
    bool &doThickReformat,
    double &thicknessWidth, // mm
    int &thicknessCompositionMode,
    double &slabThicknessResolution,
    double &theta,
    std::string &outFileName,
    int &nThreads,
    int &width )
{
    extra = 6; // mm
    doThickReformat = false;
    thicknessCompositionMode = CPR_THICK_MIP;
    thicknessWidth = 10;
    std::string thicknessCompositionModeString = "MIP";
    slabThicknessResolution = 0; // autocompute to half the pixel spacing
    animate = false;
    theta = 0;
    interp = 1;
    outFileName = "StretchedCPR.mha";
    nThreads = -1; // -1 for auto
    width = 400;

    typedef vtksys::CommandLineArguments argT;
    argT args;

    // Need this to get arguments without --'s
    args.StoreUnusedArguments(true);

    args.Initialize(argc, argv);
    args.AddArgument("--CTA", argT::SPACE_ARGUMENT, &CT, "CTA in (.mhd/mha) [Required]");
    args.AddArgument("--Centerline", argT::SPACE_ARGUMENT, &centerline,
        "coronary vessel centerline (.vtp or .vtp) [Required]");
    args.AddBooleanArgument("--Animate", &animate, "animate with 1degree rotation from 0 to 360 deg [default true]");
    args.AddArgument("--Pad", argT::SPACE_ARGUMENT, &extra, "Padding on either side of the centerline for context. [10mm]");
    args.AddBooleanArgument("--Thick", &doThickReformat, "Thick / thin slab ?. [thin]");
    args.AddArgument("--Thickness", argT::SPACE_ARGUMENT, &thicknessWidth, "Slab thickness (mm). [10mm]");
    args.AddArgument("--ThickBlend", argT::SPACE_ARGUMENT, &thicknessCompositionModeString, "Composition mode. [MIP] (MIP, MinIP, Mean)");
    args.AddArgument("--ThickResolution", argT::SPACE_ARGUMENT, &slabThicknessResolution, "Thickness resolution. Smaller values are more compute intensive. (mm). [default = half voxel spacing]");
    args.AddArgument("--Theta", argT::SPACE_ARGUMENT, &theta, "Theta angle for Stretched CPR. (deg) [0 deg] Default is optimized for display using PCA.");
    args.AddArgument(
        "--Output", argT::SPACE_ARGUMENT, &outFileName, "Result [defaults to StretchedCPR.mha");
    args.AddArgument("--Interpolation", argT::SPACE_ARGUMENT, &interp, "0th order, 1st order, 2nd order [default 1]");
    args.AddArgument("--Threads", argT::SPACE_ARGUMENT, &nThreads, "Result [defaults to 1]");
    args.AddArgument("--Width", argT::SPACE_ARGUMENT, &width, "width of the Y view");

    bool argret = args.Parse();

    if ( thicknessCompositionModeString == "MIP" )
    {
        thicknessCompositionMode = CPR_THICK_MIP;
    }
    else if (thicknessCompositionModeString == "Mean")
    {
        thicknessCompositionMode = CPR_THICK_MEAN;
    }
    else if (thicknessCompositionModeString == "MinIP")
    {
        thicknessCompositionMode = CPR_THICK_MIN;
    }

    if (!argret)
    {
        std::cout << args.GetHelp() << std::endl;
        exit(-1);
    }
}


// Test
int StretchedVesselReformatTest(int argc, char *argv[] )
{
    vtkLogger::Init(argc, argv);
    vtkLogger::LogToFile("log.log", vtkLogger::APPEND, vtkLogger::VERBOSITY_8 );

    // Parse the options
    int interp;
    std::string ctaFileName, outFileName, vesselCenterlineFileName;
    double extra, slabThicknessResolution, theta, thicknessWidth;
    bool doThickReformat;
    int nThreads;
    int thicknessCompositionMode;
    bool animate;
    int width = 400;

    StretchedVesselReformatTestParseArguments( argc, argv,
      ctaFileName,
      vesselCenterlineFileName,
      animate,
      interp,
      extra,
      doThickReformat,
      thicknessWidth,
      thicknessCompositionMode,
      slabThicknessResolution,
      theta,
      outFileName,
      nThreads,
      width );

    // type of cpr
    auto cprMode = ebv::mpr::VesselCenterline::CPRMode::CPRStretchedMode;

    // cta
    vtkSmartPointer< vtkImageData > inVolume = ebv::Utils::ImageUtils::ReadMetaImageIntoVTK( ctaFileName );

    // centerline
    vtkSmartPointer<vtkPolyData> centerline = ebv::Utils::MeshUtils::Read(vesselCenterlineFileName);

    // filter
    vtkSmartPointer< ebvCPRFilter > cprFilter = vtkSmartPointer< ebvCPRFilter >::New();

    // set centerline
    cprFilter->SetCenterlinePolyData(centerline); // vessel path

    // set CT
    cprFilter->SetInputData(inVolume);

    // set reformation type
    cprFilter->SetCPRMode( cprMode );

    // 0, 1, 3 // interpo order NN , linear, cubic
    cprFilter->SetInterpolationMode(interp);

    // info
    cprFilter->GetCenterline()->SetPerformanceProfiling(true);

    // sampling of centerline
    cprFilter->GetCenterline()->SetSamplingmode( ebv::mpr::VesselTraverserBase::FirstOrder );

    // [optional] width
    cprFilter->SetYWidth( width ); // mm

    // threads. -1 for auto
    if (nThreads != -1) cprFilter->SetNumberOfThreads(nThreads);

    // anything that maps outside
    cprFilter->SetBackgroundLevel(-1000);

    // Get traverser
    ebv::mpr::VesselTraverserStretched *traverser =
        ebv::mpr::VesselTraverserStretched::SafeDownCast(
            cprFilter->GetCenterline()->GetVesselTraverser( cprMode ) );

    // pad a bit if needed about the vessel to get some context
    traverser->SetPadding( extra ); // mm

    // thick slab options
    if (doThickReformat)
    {
        cprFilter->SetThicknessResolution( slabThicknessResolution );
        cprFilter->SetThickMode( thicknessCompositionMode );
        cprFilter->SetThickness( thicknessWidth );
    }

    // rotation angle - ideally done interactively
    traverser->SetTheta( theta );

    // timing start
    ebv::TimeProbe tp( true, "CPR Execution time" );

    // CPR generation
    cprFilter->Update();

    // timing end
    tp.EndAll( "CPR Execution time" );

    // write output
    vtkNew< vtkImageData > out;
    out->ShallowCopy(cprFilter->GetOutput());

    // write the reformatted image
    ebv::Utils::ImageUtils::WriteMHA( out, outFileName.c_str() );

    // display
    auto viewer = ebv::Utils::ImageUtils::ImDisplay( out, !animate );

    // animate 0 to 360
    if (animate)
    {
        for (double theta = 0; theta < 360; theta += 1)
        {
            // timing start
            ebv::TimeProbe tP( true, "CPR execution time" );

            traverser->SetTheta(theta);
            cprFilter->Modified();
            cprFilter->Update();
            out->ShallowCopy(cprFilter->GetOutput());

            // timing end
            tP.EndAll( "CPR Execution time" );

            viewer->SetInputData(out);
            viewer->Render();
        }
    }

    return EXIT_SUCCESS;
}


int main(int argc, char *argv[])
{
    StretchedVesselReformatTest(argc, argv);
}
