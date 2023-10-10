/*=========================================================================

 Module: caplib

   Test for the straightened CPR

    Read also
      "CPR - Curved Planar Reformation", IEEE Visualization 2002.
     http://www.cg.tuwien.ac.at/research/vis/adapt/Vis2002/AKanitsar_CPR.pdf

 Author: karthik.krishnan@elucidbio.com

 License: Use of this source code is governed by the LICENSE file

=========================================================================*/

#include "ebiHelper.h"
#include "ebvCurvedPlanarReformationFilter.h"
#include "ebvImageTestUtils.h"
#include "ebvLinkedViewersVesselTarget.h"
#include "ebvMeshTestUtils.h"
#include "ebvTimeProbe.h"
#include "vtksys/CommandLineArguments.hxx"

/**
 * Sample args:
 *
 * --CTA Vol_Left_ct.mha --Centerline Vessel_RightCoronary.vtp
 * --PathXAxis0 0.0634183 --PathXAxis1 0.780348 --PathXAxis2 0.622122
 * --PathYAxis0 0.841227 --PathYAxis1 -0.377197 --PathYAxis2 0.387377
 *
 * --CTA Vol_Left_ct.mha --Centerline Vessel_RightCoronary.vtp
 * --PathXAxis0 0.0634183 --PathXAxis1 0.780348 --PathXAxis2 0.622122
 * --PathYAxis0 0.841227 --PathYAxis1 -0.377197 --PathYAxis2 0.387377
 * --Theta 90
 *
 * --CTA Vol_Left_ct.mha --Centerline Vessel_RightCoronary.vtp
 * --PathXAxis0 0.0634183 --PathXAxis1 0.780348 --PathXAxis2 0.622122
 * --PathYAxis0 0.841227 --PathYAxis1 -0.377197 --PathYAxis2 0.387377
 * --Animate true --Width 30
 */

// Parse arguments
void StraightenedVesselReformatTestParseArguments(int argc, char *argv[], std::string &CT,
    std::string &centerline, bool &animate, double &extra, double &theta,
    std::string &outFileNameStem, int &width, VectorType &xAxis, VectorType &yAxis)
{
  extra = 6; // mm
  animate = false;
  theta = 0;
  outFileNameStem = "StraightCPR";
  width = 30;

  typedef vtksys::CommandLineArguments argT;
  argT args;

  // Need this to get arguments without --'s
  args.StoreUnusedArguments(true);
  args.Initialize(argc, argv);
  args.AddArgument("--CTA", argT::SPACE_ARGUMENT, &CT, "CTA in (.mhd/mha) [Required]");
  args.AddArgument("--Centerline", argT::SPACE_ARGUMENT, &centerline,
      "coronary vessel centerline (.vtp or .vtk) [Required]");
  args.AddBooleanArgument(
      "--Animate", &animate, "animate with 1degree rotation from 0 to 360 deg [default true]");
  args.AddArgument("--Theta", argT::SPACE_ARGUMENT, &theta, "Theta angle for CPR. (deg) [0 deg]");
  args.AddArgument(
      "--PathXAxis0", argT::SPACE_ARGUMENT, &xAxis[0], "X coord of path's X axis vector");
  args.AddArgument(
      "--PathXAxis1", argT::SPACE_ARGUMENT, &xAxis[1], "Y coord of path's X axis vector");
  args.AddArgument(
      "--PathXAxis2", argT::SPACE_ARGUMENT, &xAxis[2], "Z coord of path's X axis vector");
  args.AddArgument(
      "--PathYAxis0", argT::SPACE_ARGUMENT, &yAxis[0], "X coord of path's Y axis vector");
  args.AddArgument(
      "--PathYAxis1", argT::SPACE_ARGUMENT, &yAxis[1], "Y coord of path's Y axis vector");
  args.AddArgument(
      "--PathYAxis2", argT::SPACE_ARGUMENT, &yAxis[2], "Z coord of path's Y axis vector");
  args.AddArgument("--Output", argT::SPACE_ARGUMENT, &outFileNameStem,
      "Name stem of result files [defaults to StraightCPR-<arguments>]");
  args.AddArgument("--Width", argT::SPACE_ARGUMENT, &width, "width of the Y view");

  bool argret = args.Parse();

  if (!argret)
  {
    std::cout << args.GetHelp() << std::endl;
    exit(-1);
  }
}

// Pull out into helper function
static ebvLinkedViewersVisualObject::VectorType SetCPRAngle(
    ebvCurvedPlanarReformationFilter *cprFilter, double theta, VectorType xAxis, VectorType yAxis,
    bool quiet = false)
{
  double thetaRad = theta * itk::Math::pi / 180.;
  auto axis = ebvLinkedViewersVesselTarget::CalculateCPRAxis(thetaRad, xAxis, yAxis);
  if (!quiet)
  {
    std::cout << "For angle " << theta << " deg = " << thetaRad << ", CPR axis = " << axis[0]
              << ", " << axis[1] << ", " << axis[2] << std::endl;
  }
  cprFilter->SetAxis(axis);
  return axis;
}

int StraightenedVesselReformatTest(int argc, char *argv[])
{
  vtkLogger::Init(argc, argv);
  vtkLogger::LogToFile("log.log", vtkLogger::APPEND, vtkLogger::VERBOSITY_8);

  // Parse the options
  std::string ctaFileName, outFileNameStem, vesselCenterlineFileName;
  double extra, theta;
  bool animate;
  int width;
  VectorType xAxis, yAxis;

  StraightenedVesselReformatTestParseArguments(argc, argv, ctaFileName, vesselCenterlineFileName,
      animate, extra, theta, outFileNameStem, width, xAxis, yAxis);

  // cta
  auto inVolume = ebv::Utils::ImageUtils::ReadMetaImageIntoVTK(ctaFileName);

  // centerline
  auto centerline = ebv::Utils::MeshUtils::Read(vesselCenterlineFileName);

  // filter
  auto cprFilter = vtkSmartPointer<ebvCurvedPlanarReformationFilter>::New();

  //  cprFilter

  // set CT
  cprFilter->SetInputImage(inVolume);

  // set centerline
  // because SetPath updates the curved surface based on the image, we have to set the image before
  // setting the path
  ebvCurvedPlanarReformationFilter::PathType path;
  for (int i = 0; i < centerline->GetNumberOfPoints(); i++)
  {
    path.push_back(centerline->GetPoint(i));
  }
  cprFilter->SetPath(path);
  cprFilter->SetStraighten(true);
  cprFilter->SetWidth(width);

  auto axis = SetCPRAngle(cprFilter, theta, xAxis, yAxis);

  // timing start
  ebv::TimeProbe tp(true, "CPR Execution time");

  // CPR generation
  cprFilter->Update();

  // timing end
  tp.EndAll("CPR Execution time");

  // FTODO change to Output 1 and Output 2 depending on updates to the filter
  auto curved = cprFilter->GetOutputCurvedSurface();
  auto flat = cprFilter->GetOutputFlatSurface();

  std::string ctStem, ext;
  GetPrefixAndExtension(ctaFileName, ctStem, ext);
  std::ostringstream os;
  os << outFileNameStem << ctStem;
  os << "-Theta_" << theta;
  os << "-Axis_" << axis[0] << "_" << axis[1] << "_" << axis[2];
  std::string nameStem = os.str().c_str();

  std::cout << "nameStem = " << nameStem << std::endl;
  std::cout << "outFileNameStem = " << outFileNameStem << std::endl;
  std::cout << "ctStem = " << ctStem << std::endl;

  ebv::Utils::MeshUtils::Write(curved, (nameStem + "-CurvedSurface.vtp").c_str());
  ebv::Utils::MeshUtils::Write(flat, (nameStem + "-FlatSurface.vtp").c_str());

  // display
  auto renwin = ebv::Utils::MeshUtils::DisplayPolyDatas({curved, flat}, !animate, "Straight CPR");

  // animate 0 to 360
  if (animate)
  {
    for (double animationTheta = 0; animationTheta < 360; animationTheta += 1)
    {
      // timing start
      ebv::TimeProbe tP(true, "CPR execution time");

      SetCPRAngle(cprFilter, animationTheta, xAxis, yAxis, true);
      cprFilter->Update();

      // timing end
      tP.EndAll("CPR Execution time");

      renwin->Render();
    }
  }

  return EXIT_SUCCESS;
}

int main(int argc, char *argv[])
{
  StraightenedVesselReformatTest(argc, argv);
}
