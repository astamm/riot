#include "bundleWriters.h"
#include <vtkDoubleArray.h>
#include <vtkPointData.h>
#include <vtkPolyDataWriter.h>
#include <vtkXMLPolyDataWriter.h>
#include <vtksys/SystemTools.hxx>

void ListToPolyData(cpp11::list inputData,
                    vtkSmartPointer<vtkPolyData> &polyData) {
  cpp11::strings names(static_cast<SEXP>(inputData.attr("names")));
  int numberOfColumns = inputData.size();

  if (numberOfColumns < 5)
    cpp11::stop("Input must have at least 5 columns.");

  if (std::string(names[0]) != "X" || std::string(names[1]) != "Y" ||
      std::string(names[2]) != "Z" || std::string(names[3]) != "PointId" ||
      std::string(names[4]) != "StreamlineId")
    cpp11::stop("First 5 columns must be X, Y, Z, PointId, StreamlineId.");

  // Extract a list element as std::vector<double>, coercing integer if needed
  auto extractCol = [&](int idx) -> std::vector<double> {
    SEXP col = inputData[idx];
    if (TYPEOF(col) == REALSXP) {
      cpp11::doubles d = cpp11::as_cpp<cpp11::doubles>(col);
      return std::vector<double>(d.begin(), d.end());
    } else if (TYPEOF(col) == INTSXP) {
      cpp11::integers iv = cpp11::as_cpp<cpp11::integers>(col);
      std::vector<double> out(iv.size());
      for (R_xlen_t j = 0; j < iv.size(); ++j)
        out[static_cast<std::size_t>(j)] = iv[j];
      return out;
    }
    cpp11::stop("Unsupported column type in input data.");
  };

  std::vector<double> X_col = extractCol(0);
  std::vector<double> Y_col = extractCol(1);
  std::vector<double> Z_col = extractCol(2);
  // PointId is not needed for polydata reconstruction
  std::vector<double> StreamlineId_col = extractCol(4);

  unsigned int numberOfRows = static_cast<unsigned int>(X_col.size());

  // Determine array component structure by inspecting column names
  std::vector<unsigned int> componentCounts;
  std::vector<std::string> arrayNames;
  int pos = 5;
  while (pos < numberOfColumns) {
    std::string name = std::string(names[pos]);
    if (name.find('#') == std::string::npos) {
      componentCounts.push_back(1);
      arrayNames.push_back(name);
      ++pos;
    } else {
      unsigned int count = 0;
      while (pos + static_cast<int>(count) < numberOfColumns &&
             std::string(names[pos + static_cast<int>(count)]).find('#') !=
                 std::string::npos)
        ++count;
      arrayNames.push_back(name.substr(0, name.find('#')));
      componentCounts.push_back(count);
      pos += static_cast<int>(count);
    }
  }

  // Pre-extract all extra columns
  std::vector<std::vector<double>> arrayCols;
  for (int c = 5; c < numberOfColumns; ++c)
    arrayCols.push_back(extractCol(c));

  // Build polydata geometry
  polyData->Initialize();
  polyData->Allocate();

  vtkSmartPointer<vtkPoints> myPoints = vtkSmartPointer<vtkPoints>::New();
  unsigned int numberOfStreamlines =
      static_cast<unsigned int>(StreamlineId_col[numberOfRows - 1]);
  cpp11::message("Number of streamlines: %d", numberOfStreamlines);

  unsigned int initialPosition = 0;
  for (unsigned int i = 0; i < numberOfStreamlines; ++i) {
    unsigned int npts = 0;
    while (initialPosition + npts < numberOfRows &&
           static_cast<unsigned int>(
               StreamlineId_col[initialPosition + npts]) == i + 1)
      ++npts;

    vtkIdType *ids = new vtkIdType[npts];
    for (unsigned int j = 0; j < npts; ++j) {
      unsigned int tmpPos = initialPosition + j;
      ids[j] = myPoints->InsertNextPoint(X_col[tmpPos], Y_col[tmpPos],
                                         Z_col[tmpPos]);
    }
    polyData->InsertNextCell(VTK_POLY_LINE, npts, ids);
    delete[] ids;
    initialPosition += npts;
  }
  polyData->SetPoints(myPoints);

  // Add point-data arrays
  cpp11::message("Number of arrays: %d", componentCounts.size());
  unsigned int colOffset = 0;
  for (unsigned int a = 0; a < componentCounts.size(); ++a) {
    unsigned int nbComponents = componentCounts[a];

    vtkSmartPointer<vtkDoubleArray> arrayData =
        vtkSmartPointer<vtkDoubleArray>::New();
    arrayData->SetName(arrayNames[a].c_str());
    arrayData->SetNumberOfComponents(nbComponents);
    arrayData->SetNumberOfTuples(static_cast<vtkIdType>(numberOfRows));

    double *ptr = static_cast<double *>(arrayData->GetVoidPointer(0));
    for (unsigned int i = 0; i < numberOfRows; ++i)
      for (unsigned int j = 0; j < nbComponents; ++j)
        ptr[i * nbComponents + j] = arrayCols[colOffset + j][i];

    polyData->GetPointData()->AddArray(arrayData);
    colOffset += nbComponents;
  }
}

void WriteVTK(cpp11::list inputTracts, const std::string &outputFile) {
  vtkSmartPointer<vtkPolyData> inputData = vtkSmartPointer<vtkPolyData>::New();
  ListToPolyData(inputTracts, inputData);

  vtkSmartPointer<vtkPolyDataWriter> vtkWriter = vtkPolyDataWriter::New();
  vtkWriter->SetInputData(inputData);
  vtkWriter->SetFileName(outputFile.c_str());
  vtkWriter->Update();
}

void WriteVTP(cpp11::list inputTracts, const std::string &outputFile) {
  vtkSmartPointer<vtkPolyData> inputData = vtkSmartPointer<vtkPolyData>::New();
  ListToPolyData(inputTracts, inputData);

  vtkSmartPointer<vtkXMLPolyDataWriter> vtkWriter = vtkXMLPolyDataWriter::New();
  vtkWriter->SetInputData(inputData);
  vtkWriter->SetFileName(outputFile.c_str());
  vtkWriter->SetDataModeToBinary();
  vtkWriter->EncodeAppendedDataOff();
  vtkWriter->SetCompressorTypeToZLib();
  vtkWriter->Update();
}

void WriteFDS(cpp11::list inputTracts, const std::string &outputFile) {
  vtkSmartPointer<vtkPolyData> inputData = vtkSmartPointer<vtkPolyData>::New();
  ListToPolyData(inputTracts, inputData);

  // Work on a local mutable copy so we can normalise path separators
  std::string outputFilePath = outputFile;
  std::replace(outputFilePath.begin(), outputFilePath.end(), '\\', '/');

  std::string baseName;
  std::size_t lastDotPos = outputFilePath.find_last_of('.');
  baseName.append(outputFilePath.begin(), outputFilePath.begin() + lastDotPos);

  std::string noPathName = baseName;
  std::size_t lastSlashPos = baseName.find_last_of("/");
  if (lastSlashPos != std::string::npos) {
    noPathName.clear();
    noPathName.append(baseName.begin() + lastSlashPos + 1, baseName.end());
  }

  vtksys::SystemTools::MakeDirectory(baseName.c_str());

  std::string vtkFileName = noPathName + "/";
  vtkFileName += noPathName;
  vtkFileName += "_0.vtp";

  std::string vtkWriteFileName = baseName + "/";
  vtkWriteFileName += noPathName + "_0.vtp";

  vtkSmartPointer<vtkXMLPolyDataWriter> vtkWriter = vtkXMLPolyDataWriter::New();
  vtkWriter->SetInputData(inputData);
  vtkWriter->SetFileName(vtkWriteFileName.c_str());
  vtkWriter->SetDataModeToBinary();
  vtkWriter->EncodeAppendedDataOff();
  vtkWriter->SetCompressorTypeToZLib();
  vtkWriter->Update();

  std::ofstream outputHeaderFile(outputFilePath.c_str());
  outputHeaderFile << "<?xml version=\"1.0\"?>" << std::endl;
  outputHeaderFile
      << "<VTKFile type=\"vtkFiberDataSet\" version=\"1.0\" "
         "byte_order=\"LittleEndian\" compressor=\"vtkZLibDataCompressor\">"
      << std::endl;
  outputHeaderFile << "<vtkFiberDataSet>" << std::endl;
  outputHeaderFile << "\t<Fibers index=\"0\" file=\"" << vtkFileName << "\">"
                   << std::endl;
  outputHeaderFile << "\t</Fibers>" << std::endl;
  outputHeaderFile << "</vtkFiberDataSet>" << std::endl;
  outputHeaderFile << "</VTKFile>" << std::endl;
  outputHeaderFile.close();
}
