#include "trackReaders.h"
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>
#include <vtkXMLPolyDataReader.h>

Rcpp::List ReadVTP(std::string &file)
{
  vtkSmartPointer <vtkXMLPolyDataReader> vtpReader = vtkXMLPolyDataReader::New();
  vtpReader->SetFileName(file.c_str());
  vtpReader->Update();

  vtkSmartPointer <vtkPolyData> outputData = vtkSmartPointer <vtkPolyData>::New();
  outputData->ShallowCopy(vtpReader->GetOutput());

  unsigned int numberOfPoints = outputData->GetNumberOfPoints();

  Rcpp::Rcout << "Number of points: " << numberOfPoints << std::endl;

  Rcpp::NumericVector vx(numberOfPoints);
  Rcpp::NumericVector vy(numberOfPoints);
  Rcpp::NumericVector vz(numberOfPoints);

  for (unsigned int i = 0;i < numberOfPoints;++i)
  {
    double p[3];
    outputData->GetPoint(i, p);

    vx[i] = p[0];
    vy[i] = p[1];
    vz[i] = p[2];
  }

  return Rcpp::List::create(
    Rcpp::Named("x") = vx,
    Rcpp::Named("y") = vy,
    Rcpp::Named("z") = vz
  );
}
