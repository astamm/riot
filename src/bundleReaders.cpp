#include "bundleReaders.h"
#include "tinyxml2.h"
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vtkPointData.h>
#include <vtkPolyDataReader.h>
#include <vtkXMLPolyDataReader.h>

// ---------------------------------------------------------------------------
// TRK reader – fast bulk I/O path
// ---------------------------------------------------------------------------

static inline void swap4(void *p) {
  uint8_t *b = static_cast<uint8_t *>(p);
  uint8_t t;
  t = b[0];
  b[0] = b[3];
  b[3] = t;
  t = b[1];
  b[1] = b[2];
  b[2] = t;
}

static inline int32_t read_i32(const uint8_t *buf, bool swap) {
  int32_t v;
  std::memcpy(&v, buf, 4);
  if (swap)
    swap4(&v);
  return v;
}

static inline float read_f32(const uint8_t *buf, bool swap) {
  float v;
  std::memcpy(&v, buf, 4);
  if (swap)
    swap4(&v);
  return v;
}

// Detect native endianness at run-time
static inline bool native_is_little() {
  uint16_t x = 1;
  return *reinterpret_cast<uint8_t *>(&x) == 1;
}

cpp11::writable::list ReadTRK(const std::string &inputFile, int n_scalars,
                              int n_properties, int n_count, bool little_endian,
                              cpp11::strings scalar_names,
                              cpp11::strings property_names) {
  // Need to byte-swap if file endianness != native endianness
  bool need_swap = (little_endian != native_is_little());

  // Open and read the entire body (after the 1000-byte header) in one shot
  FILE *fp = std::fopen(inputFile.c_str(), "rb");
  if (!fp)
    cpp11::stop("Cannot open TRK file: %s", inputFile.c_str());

  if (std::fseek(fp, 1000L, SEEK_SET) != 0) {
    std::fclose(fp);
    cpp11::stop("Cannot seek past TRK header in: %s", inputFile.c_str());
  }

  // Determine remaining byte count
  long body_start = std::ftell(fp);
  std::fseek(fp, 0L, SEEK_END);
  long file_end = std::ftell(fp);
  std::fseek(fp, body_start, SEEK_SET);
  std::size_t body_size = static_cast<std::size_t>(file_end - body_start);

  std::vector<uint8_t> buf(body_size);
  std::size_t nread = std::fread(buf.data(), 1, body_size, fp);
  std::fclose(fp);

  if (nread != body_size)
    cpp11::stop("Short read on TRK file: %s", inputFile.c_str());

  // --- First pass: count total points so we can pre-allocate ---------------
  std::size_t pos = 0;
  const int floats_per_point = 3 + n_scalars;
  const std::size_t point_block_bytes =
      static_cast<std::size_t>(floats_per_point) * 4;
  const std::size_t prop_block_bytes =
      static_cast<std::size_t>(n_properties) * 4;

  std::vector<int32_t> npts_per_sl(static_cast<std::size_t>(n_count));
  std::size_t total_points = 0;

  for (int s = 0; s < n_count; ++s) {
    if (pos + 4 > body_size)
      cpp11::stop("Premature end of TRK body (streamline %d)", s + 1);
    int32_t np = read_i32(buf.data() + pos, need_swap);
    pos += 4;
    if (np < 0)
      cpp11::stop("Invalid num_points %d at streamline %d", np, s + 1);
    npts_per_sl[s] = np;
    total_points += static_cast<std::size_t>(np);
    pos += static_cast<std::size_t>(np) * point_block_bytes + prop_block_bytes;
  }

  // --- Pre-allocate output vectors -----------------------------------------
  cpp11::writable::doubles X(total_points), Y(total_points), Z(total_points);
  cpp11::writable::integers PointIdVec(total_points),
      StreamlineIdVec(total_points);

  std::vector<cpp11::writable::doubles> scalar_cols(
      static_cast<std::size_t>(n_scalars),
      cpp11::writable::doubles(total_points));

  std::vector<cpp11::writable::doubles> prop_cols(
      static_cast<std::size_t>(n_properties),
      cpp11::writable::doubles(total_points));

  // --- Second pass: parse data ---------------------------------------------
  pos = 0;
  R_xlen_t out = 0;

  for (int s = 0; s < n_count; ++s) {
    int32_t np = npts_per_sl[s];
    pos += 4; // skip num_points (already consumed in first pass)

    for (int p = 0; p < np; ++p) {
      X[out] = static_cast<double>(read_f32(buf.data() + pos, need_swap));
      Y[out] = static_cast<double>(read_f32(buf.data() + pos + 4, need_swap));
      Z[out] = static_cast<double>(read_f32(buf.data() + pos + 8, need_swap));
      PointIdVec[out] = p + 1;
      StreamlineIdVec[out] = s + 1;
      pos += 12;
      for (int sc = 0; sc < n_scalars; ++sc) {
        scalar_cols[static_cast<std::size_t>(sc)][out] =
            static_cast<double>(read_f32(buf.data() + pos, need_swap));
        pos += 4;
      }
      ++out;
    }

    // Per-streamline properties → replicate across all points of this
    // streamline
    R_xlen_t sl_start = out - static_cast<R_xlen_t>(np);
    for (int pr = 0; pr < n_properties; ++pr) {
      double pval = static_cast<double>(read_f32(buf.data() + pos, need_swap));
      pos += 4;
      for (R_xlen_t pp = sl_start; pp < out; ++pp)
        prop_cols[static_cast<std::size_t>(pr)][pp] = pval;
    }
  }

  // --- Assemble named list -------------------------------------------------
  cpp11::writable::list result;
  result.push_back(X);
  result.push_back(Y);
  result.push_back(Z);
  result.push_back(PointIdVec);
  result.push_back(StreamlineIdVec);
  for (int sc = 0; sc < n_scalars; ++sc)
    result.push_back(scalar_cols[static_cast<std::size_t>(sc)]);
  for (int pr = 0; pr < n_properties; ++pr)
    result.push_back(prop_cols[static_cast<std::size_t>(pr)]);

  std::vector<std::string> colNames = {"X", "Y", "Z", "PointId",
                                       "StreamlineId"};
  for (int sc = 0; sc < n_scalars; ++sc)
    colNames.push_back(std::string(scalar_names[static_cast<R_xlen_t>(sc)]));
  for (int pr = 0; pr < n_properties; ++pr)
    colNames.push_back(std::string(property_names[static_cast<R_xlen_t>(pr)]));

  cpp11::writable::strings rNames(static_cast<R_xlen_t>(colNames.size()));
  for (std::size_t i = 0; i < colNames.size(); ++i)
    rNames[static_cast<R_xlen_t>(i)] = colNames[i];
  result.attr("names") = rNames;

  return result;
}

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
