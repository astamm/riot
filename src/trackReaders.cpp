#include "trackReaders.h"
#include <vtkPointData.h>
#include <vtkPolyDataReader.h>
#include <vtkXMLPolyDataReader.h>

void ProcessPolyData(const vtkSmartPointer <vtkPolyData> &inputData, std::string &outputFile)
{
  vtkSmartPointer<vtkPointData> pointData = inputData->GetPointData();

  // Initialize output file.
  std::ofstream outputData;
  outputData.open(outputFile.c_str(), std::ios_base::out);
  outputData.precision(std::numeric_limits<long double>::digits10);

  if (outputData.bad())
    Rcpp::stop("The output file could not be opened");

  // Export data to outputData.
  typedef std::vector<int> IndexVectorType;
  unsigned int numArrays = pointData->GetNumberOfArrays();
  IndexVectorType arraySizes(numArrays, 0);

  outputData << "X,Y,Z,PointId,StreamlineId";

  for (unsigned int i = 0;i < numArrays;++i)
  {
    int arraySize = pointData->GetArray(i)->GetNumberOfComponents();
    arraySizes[i] = arraySize;

    if (arraySize == 1)
    {
      outputData << "," << pointData->GetArrayName(i);
      continue;
    }

    for (unsigned int j = 0;j < arraySize;++j)
      outputData << "," << pointData->GetArrayName(i) << "#" << j;
  }

  //-------------------------------
  // Setting up streamline geometry
  //-------------------------------

  unsigned int numberOfPoints = inputData->GetNumberOfPoints();
  unsigned int numberOfStreamlines = inputData->GetNumberOfLines();
  Rcpp::Rcout << "Number of data points: " << numberOfPoints << std::endl;
  Rcpp::Rcout << "Number of streamlines: " << numberOfStreamlines << std::endl;

  // Extract streamline information by point
  IndexVectorType pointId(numberOfPoints, -1);
  IndexVectorType streamlineId(numberOfPoints, -1);
  inputData->GetLines()->InitTraversal();
  vtkSmartPointer<vtkIdList> idList = vtkSmartPointer<vtkIdList>::New();
  for (unsigned int i = 0;i < numberOfStreamlines;++i)
  {
    inputData->GetLines()->GetNextCell(idList);

    unsigned int streamlineSize = idList->GetNumberOfIds();

    if (streamlineSize == 1)
      continue;

    for (unsigned int j = 0;j < streamlineSize;++j)
    {
      unsigned int pid = idList->GetId(j);
      streamlineId[pid] = i+1;
      pointId[pid] = j+1;
    }
  }

  // Writing table content
  for (unsigned int i = 0;i < numberOfPoints;++i)
  {
    if (numberOfStreamlines != 0)
      if (streamlineId[i] == -1)
        continue;

      outputData << std::endl;

      // 1. Write point 3D coordinates
      double p[3];
      inputData->GetPoint(i, p);

      for (unsigned int j = 0;j < 3;++j)
        outputData << p[j] << ",";

      // 2. Write streamline index data
      outputData << pointId[i] << "," << streamlineId[i];

      // 3. Write array values if any
      for (unsigned int k = 0;k < numArrays;++k)
        for (unsigned int j = 0;j < arraySizes[k];++j)
          outputData << "," << pointData->GetArray(k)->GetComponent(i, j);
  }

  outputData << std::endl;
  outputData.close();
}

void ReadVTK(const std::string &inputTracts, std::string &outputFile)
{
  vtkSmartPointer <vtkPolyDataReader> vtkReader = vtkPolyDataReader::New();
  vtkReader->SetFileName(inputTracts.c_str());
  vtkReader->Update();
  ProcessPolyData(vtkReader->GetOutput(), outputFile);
}

void ReadVTP(const std::string &inputTracts, std::string &outputFile)
{
  vtkSmartPointer <vtkXMLPolyDataReader> vtpReader = vtkXMLPolyDataReader::New();
  vtpReader->SetFileName(inputTracts.c_str());
  vtpReader->Update();
  ProcessPolyData(vtpReader->GetOutput(), outputFile);
}
