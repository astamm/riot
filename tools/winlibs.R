VERSION <- commandArgs(TRUE)
if(!file.exists(sprintf("../windows/vtk-%s/include/vtk/vtkPolyData.h", VERSION))){
  download.file(sprintf("https://github.com/rwinlib/vtk/archive/%s.zip", VERSION),
                "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}
