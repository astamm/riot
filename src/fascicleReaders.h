#ifndef _FIBERREADERS_H
#define _FIBERREADERS_H

#include <cpp11.hpp>
#include <string>
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>

cpp11::writable::list
PolyDataToList(const vtkSmartPointer<vtkPolyData> &polyData);
[[cpp11::register]]
cpp11::writable::list ReadVTK(const std::string &inputTracts);
[[cpp11::register]]
cpp11::writable::list ReadVTP(const std::string &inputTracts);
[[cpp11::register]]
cpp11::writable::list ReadFDS(const std::string &inputTracts);

#endif /* _FIBERREADERS_H */
