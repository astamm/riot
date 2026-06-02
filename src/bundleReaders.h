#ifndef _BUNDLEREADERS_H
#define _BUNDLEREADERS_H

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
[[cpp11::register]]
cpp11::writable::list ReadTRK(const std::string &inputFile, int n_scalars,
                              int n_properties, int n_count, bool little_endian,
                              cpp11::strings scalar_names,
                              cpp11::strings property_names);

#endif /* _BUNDLEREADERS_H */
