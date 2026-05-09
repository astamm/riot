#include "fascicleReaders.h"
#include "tinyxml2.h"
#include <vtkPointData.h>
#include <vtkPolyDataReader.h>
#include <vtkXMLPolyDataReader.h>

cpp11::writable::list
PolyDataToList(const vtkSmartPointer<vtkPolyData> &inputData) {
  vtkSmartPointer<vtkPointData> pointData = inputData->GetPointData();

  unsigned int numberOfPoints = inputData->GetNumberOfPoints();
  unsigned int numberOfStreamlines = inputData->GetNumberOfLines();
  unsigned int numArrays = pointData->GetNumberOfArrays();

  cpp11::message("Number of data points: %d", numberOfPoints);
  cpp11::message("Number of streamlines: %d", numberOfStreamlines);

  // Compute per-point PointId and StreamlineId from VTK cell structure
  std::vector<int> pointId(numberOfPoints, -1);
  std::vector<int> streamlineId(numberOfPoints, -1);
  inputData->GetLines()->InitTraversal();
  vtkSmartPointer<vtkIdList> idList = vtkSmartPointer<vtkIdList>::New();
  for (unsigned int i = 0; i < numberOfStreamlines; ++i) {
    inputData->GetLines()->GetNextCell(idList);
    unsigned int streamlineSize = idList->GetNumberOfIds();
    if (streamlineSize == 1)
      continue;
    for (unsigned int j = 0; j < streamlineSize; ++j) {
      unsigned int pid = idList->GetId(j);
      streamlineId[pid] = static_cast<int>(i + 1);
      pointId[pid] = static_cast<int>(j + 1);
    }
  }

  // Count valid (non-singleton) points
  unsigned int validPoints = 0;
  for (unsigned int i = 0; i < numberOfPoints; ++i)
    if (numberOfStreamlines == 0 || streamlineId[i] != -1)
      ++validPoints;

  // Build coordinate and ID vectors
  cpp11::writable::doubles X(validPoints), Y(validPoints), Z(validPoints);
  cpp11::writable::integers PointIdVec(validPoints),
      StreamlineIdVec(validPoints);

  // Determine column names and per-array component counts
  std::vector<std::string> colNames = {"X", "Y", "Z", "PointId",
                                       "StreamlineId"};
  std::vector<int> arrayComponents(numArrays);
  unsigned int totalArrayCols = 0;
  for (unsigned int a = 0; a < numArrays; ++a) {
    int nc = pointData->GetArray(a)->GetNumberOfComponents();
    arrayComponents[a] = nc;
    if (nc == 1) {
      colNames.push_back(pointData->GetArrayName(a));
    } else {
      for (int c = 0; c < nc; ++c)
        colNames.push_back(std::string(pointData->GetArrayName(a)) + "#" +
                           std::to_string(c));
    }
    totalArrayCols += static_cast<unsigned int>(nc);
  }

  // One writable::doubles per extra column
  std::vector<cpp11::writable::doubles> arrayData(
      totalArrayCols, cpp11::writable::doubles(validPoints));

  R_xlen_t outIdx = 0;
  for (unsigned int i = 0; i < numberOfPoints; ++i) {
    if (numberOfStreamlines != 0 && streamlineId[i] == -1)
      continue;

    double p[3];
    inputData->GetPoint(i, p);
    X[outIdx] = p[0];
    Y[outIdx] = p[1];
    Z[outIdx] = p[2];
    PointIdVec[outIdx] = pointId[i];
    StreamlineIdVec[outIdx] = streamlineId[i];

    unsigned int colOffset = 0;
    for (unsigned int a = 0; a < numArrays; ++a) {
      int nc = arrayComponents[a];
      for (int c = 0; c < nc; ++c)
        arrayData[colOffset + c][outIdx] =
            pointData->GetArray(a)->GetComponent(i, c);
      colOffset += static_cast<unsigned int>(nc);
    }
    ++outIdx;
  }

  // Assemble named list
  cpp11::writable::list result;
  result.push_back(X);
  result.push_back(Y);
  result.push_back(Z);
  result.push_back(PointIdVec);
  result.push_back(StreamlineIdVec);
  for (unsigned int c = 0; c < totalArrayCols; ++c)
    result.push_back(arrayData[c]);

  cpp11::writable::strings names(colNames.size());
  for (std::size_t i = 0; i < colNames.size(); ++i)
    names[i] = colNames[i];
  result.attr("names") = names;

  return result;
}

cpp11::writable::list ReadVTK(const std::string &inputTracts) {
  vtkSmartPointer<vtkPolyDataReader> vtkReader = vtkPolyDataReader::New();
  vtkReader->SetFileName(inputTracts.c_str());
  vtkReader->Update();
  return PolyDataToList(vtkReader->GetOutput());
}

cpp11::writable::list ReadVTP(const std::string &inputTracts) {
  vtkSmartPointer<vtkXMLPolyDataReader> vtpReader = vtkXMLPolyDataReader::New();
  vtpReader->SetFileName(inputTracts.c_str());
  vtpReader->Update();
  return PolyDataToList(vtpReader->GetOutput());
}

cpp11::writable::list ReadFDS(const std::string &inputTracts) {
  std::string baseName;
  std::size_t lastSlashPos = inputTracts.find_last_of('/');
  if (lastSlashPos != std::string::npos)
    baseName.append(inputTracts.begin(),
                    inputTracts.begin() + lastSlashPos + 1);

  tinyxml2::XMLDocument doc;
  tinyxml2::XMLError loadOk = doc.LoadFile(inputTracts.c_str());

  if (loadOk != tinyxml2::XML_SUCCESS)
    cpp11::stop("Error reading XML FDS file header");

  tinyxml2::XMLElement *vtkFileNode = doc.FirstChildElement("VTKFile");
  if (!vtkFileNode)
    cpp11::stop("Malformed FDS file");

  tinyxml2::XMLElement *datasetNode =
      vtkFileNode->FirstChildElement("vtkFiberDataSet");
  if (!datasetNode)
    cpp11::stop("Malformed FDS file");

  tinyxml2::XMLElement *fibersNode = datasetNode->FirstChildElement("Fibers");
  std::string vtkFileName = baseName + fibersNode->Attribute("file");
  std::string extensionName =
      vtkFileName.substr(vtkFileName.find_last_of('.') + 1);

  if (extensionName == "vtk") {
    vtkSmartPointer<vtkPolyDataReader> vtkReader = vtkPolyDataReader::New();
    vtkReader->SetFileName(vtkFileName.c_str());
    vtkReader->Update();
    return PolyDataToList(vtkReader->GetOutput());
  } else if (extensionName == "vtp") {
    vtkSmartPointer<vtkXMLPolyDataReader> vtpReader =
        vtkXMLPolyDataReader::New();
    vtpReader->SetFileName(vtkFileName.c_str());
    vtpReader->Update();
    return PolyDataToList(vtpReader->GetOutput());
  } else
    cpp11::stop("Unsupported fibers extension inside FDS files.");
}
