#ifndef _FIBERWRITERS_H
#define _FIBERWRITERS_H

#include <cpp11.hpp>
#include <string>
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>

void ListToPolyData(cpp11::list inputData,
                    vtkSmartPointer<vtkPolyData> &polyData);
[[cpp11::register]]
void WriteVTK(cpp11::list inputTracts, const std::string &outputFile);
[[cpp11::register]]
void WriteVTP(cpp11::list inputTracts, const std::string &outputFile);
[[cpp11::register]]
void WriteFDS(cpp11::list inputTracts, const std::string &outputFile);

#endif /* _FIBERWRITERS_H */
