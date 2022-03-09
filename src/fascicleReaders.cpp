#include "fascicleReaders.h"
#include "tinyxml2.h"
#include <vtkPointData.h>
#include <vtkPolyDataReader.h>
#include <vtkXMLPolyDataReader.h>

void WriteCSV(const vtkSmartPointer <vtkPolyData> &inputData, std::string &outputFile)
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
  WriteCSV(vtkReader->GetOutput(), outputFile);
}

void ReadVTP(const std::string &inputTracts, std::string &outputFile)
{
  vtkSmartPointer <vtkXMLPolyDataReader> vtpReader = vtkXMLPolyDataReader::New();
  vtpReader->SetFileName(inputTracts.c_str());
  vtpReader->Update();
  WriteCSV(vtpReader->GetOutput(), outputFile);
}

void ReadFDS(const std::string &inputTracts, std::string &outputFile)
{
  std::string baseName;
  std::size_t lastSlashPos = inputTracts.find_last_of('/');
  if (lastSlashPos != std::string::npos)
    baseName.append(inputTracts.begin(), inputTracts.begin() + lastSlashPos + 1);

  tinyxml2::XMLDocument doc;
  tinyxml2::XMLError loadOk = doc.LoadFile(inputTracts.c_str());

  if (loadOk != tinyxml2::XML_SUCCESS)
    Rcpp::stop("Error reading XML FDS file header");

  tinyxml2::XMLElement *vtkFileNode = doc.FirstChildElement("VTKFile");
  if (!vtkFileNode)
    Rcpp::stop("Malformed FDS file");

  tinyxml2::XMLElement *datasetNode = vtkFileNode->FirstChildElement("vtkFiberDataSet");
  if (!datasetNode)
    Rcpp::stop("Malformed FDS file");

  tinyxml2::XMLElement *fibersNode = datasetNode->FirstChildElement("Fibers");
  std::string vtkFileName = baseName + fibersNode->Attribute("file");

  std::string extensionName = vtkFileName.substr(vtkFileName.find_last_of('.') + 1);

  if (extensionName == "vtk")
  {
    vtkSmartPointer <vtkPolyDataReader> vtkReader = vtkPolyDataReader::New();
    vtkReader->SetFileName(vtkFileName.c_str());
    vtkReader->Update();
    WriteCSV(vtkReader->GetOutput(), outputFile);
  }
  else if (extensionName == "vtp")
  {
    vtkSmartPointer <vtkXMLPolyDataReader> vtpReader = vtkXMLPolyDataReader::New();
    vtpReader->SetFileName(vtkFileName.c_str());
    vtpReader->Update();
    WriteCSV(vtpReader->GetOutput(), outputFile);
  }
  else
    Rcpp::stop("Unsupported fibers extension inside FDS files.");
}
