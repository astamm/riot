#include "fascicleWriters.h"
#include <vtkPointData.h>
#include <vtkDoubleArray.h>
#include <vtkPolyDataWriter.h>
#include <vtkXMLPolyDataWriter.h>

void ReadCSV(const std::string &inputFile, vtkSmartPointer <vtkPolyData> &inputData)
{
  std::ifstream file(inputFile);
  if (!file)
    Rcpp::stop("The input file does not exist.");

  // Read headers
  std::vector<std::string> header;
  std::string file_line;
  std::getline(file, file_line);
  std::stringstream iss(file_line);
  unsigned int numberOfColumns = 0;

  Rcpp::Rcout << "Header:" << std::endl;
  while (iss.good())
  {
    std::string val;
    std::getline(iss, val, ',');
    std::stringstream convertor(val);

    header.resize(numberOfColumns + 1);
    convertor >> header[numberOfColumns];
    Rcpp::Rcout << "    " << header[numberOfColumns] << std::endl;
    ++numberOfColumns;
  }

  Rcpp::Rcout << "Number of columns: " << numberOfColumns << std::endl;

  if (numberOfColumns < 5)
    Rcpp::stop("The CSV should contain at least 5 columns.");

  if (header[0] != "X" || header[1] != "Y" || header[2] != "Z" || header[3] != "PointId" || header[4] != "StreamlineId")
    Rcpp::stop("The CSV should contain at least the following first 5 variables in order: X, Y, Z, PointId, StreamlineId.");

  std::vector<unsigned int> numberOfComponents;
  unsigned int pos = 5;
  while (pos < numberOfColumns)
  {
    // Dealing with arrays now
    if (header[pos].find_last_of("#") == -1) // Array value is scalar
    {
      numberOfComponents.push_back(1);
      ++pos;
    }
    else
    {
      unsigned int count = 0;
      while (header[pos+count].find_last_of("#") != -1)
        ++count;
      numberOfComponents.push_back(count);
      pos += count;
    }
  }

  // Retrieve data matrix
  std::vector< std::vector<double> > data;
  unsigned int numberOfRows = 0;

  while (file.good())
  {
    data.resize(numberOfRows + 1);
    data[numberOfRows].resize(numberOfColumns);
    std::string file_line;
    std::getline(file, file_line);
    std::stringstream iss(file_line);

    for (unsigned int i = 0;i < numberOfColumns;++i)
    {
      std::string val;
      std::getline(iss, val, ',');
      std::stringstream convertor(val);

      if (val == "")
        data[numberOfRows][i] = std::numeric_limits<double>::quiet_NaN();
      else
        convertor >> data[numberOfRows][i];
    }

    ++numberOfRows;
  }

  // ISO standards for CSVs insert a new line at the end of the file as ENDOFFILE
  // This line has to be removed if present

  // First, check if the CSV was ISO-formatted or not
  bool isoFormat = true;
  for (unsigned int j = 0;j < numberOfColumns;++j)
    if (!std::isnan(data[numberOfRows - 1][j]))
    {
      isoFormat = false;
      break;
    }

    // If ISO standard, do not consider last line
    if (isoFormat)
      --numberOfRows;

    Rcpp::Rcout << "Number of data points: " << numberOfRows << std::endl;

    // Initialize output polydata object
    inputData->Initialize();
    inputData->Allocate();

    //--------------------------------
    // Add geometry to the output polydata object
    //--------------------------------

    vtkSmartPointer<vtkPoints> myPoints = vtkSmartPointer<vtkPoints>::New();

    // Add streamlines
    unsigned int numberOfStreamlines = data[numberOfRows-1][4];
    Rcpp::Rcout << "Number of streamlines: " << numberOfStreamlines << std::endl;

    unsigned int initialPosition = 0;
    for (unsigned int i = 0;i < numberOfStreamlines;++i)
    {
      // Retrieve number of points along i-th streamline
      unsigned int npts = 0;
      while (initialPosition + npts < numberOfRows && data[initialPosition+npts][4] == i+1) // numeration in CSV starts at one.
        ++npts;

      vtkIdType* ids = new vtkIdType[npts];

      for (unsigned int j = 0;j < npts;++j)
      {
        unsigned int tmpPos = initialPosition + j;
        ids[j] = myPoints->InsertNextPoint(data[tmpPos][0], data[tmpPos][1], data[tmpPos][2]);
      }

      inputData->InsertNextCell(VTK_POLY_LINE, npts, ids);
      delete[] ids;
      initialPosition += npts;
    }

    inputData->SetPoints(myPoints);

    // Add array information
    Rcpp::Rcout << "Number of arrays: " << numberOfComponents.size() << std::endl;
    pos = 5;
    unsigned int arrayPos = 0;
    while (pos < numberOfColumns)
    {
      unsigned int nbComponents = numberOfComponents[arrayPos];

      vtkSmartPointer<vtkDoubleArray> arrayData = vtkSmartPointer<vtkDoubleArray>::New();
      std::string tmpStr;

      if (nbComponents == 1)
        tmpStr = header[pos];
      else
        tmpStr = header[pos].substr(0, header[pos].find_last_of("#"));

      arrayData->SetName(tmpStr.c_str());
      arrayData->SetNumberOfComponents(nbComponents);

      for (unsigned int i = 0;i < numberOfRows;++i)
        for (unsigned int j = 0;j < nbComponents;++j)
          arrayData->InsertNextValue(data[i][pos+j]);

      inputData->GetPointData()->AddArray(arrayData);
      pos += nbComponents;
      ++arrayPos;
    }
}

void WriteVTK(const std::string &inputTracts, std::string &outputFile)
{
  vtkSmartPointer<vtkPolyData> inputData = vtkSmartPointer<vtkPolyData>::New();
  ReadCSV(inputTracts, inputData);

  vtkSmartPointer <vtkPolyDataWriter> vtkWriter = vtkPolyDataWriter::New();
  vtkWriter->SetInputData(inputData);
  vtkWriter->SetFileName(outputFile.c_str());
  vtkWriter->Update();
}

void WriteVTP(const std::string &inputTracts, std::string &outputFile)
{
  vtkSmartPointer<vtkPolyData> inputData = vtkSmartPointer<vtkPolyData>::New();
  ReadCSV(inputTracts, inputData);

  vtkSmartPointer <vtkXMLPolyDataWriter> vtkWriter = vtkXMLPolyDataWriter::New();
  vtkWriter->SetInputData(inputData);
  vtkWriter->SetFileName(outputFile.c_str());
  vtkWriter->SetDataModeToBinary();
  vtkWriter->EncodeAppendedDataOff();
  vtkWriter->SetCompressorTypeToZLib();
  vtkWriter->Update();
}
