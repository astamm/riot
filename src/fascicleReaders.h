#ifndef _FIBERREADERS_H
#define _FIBERREADERS_H

#include <Rcpp.h>
#include <string>
// VTK headers trigger 'dllimport' redeclaration warnings on Windows (MinGW);
// suppress them portably around the VTK includes.
#ifdef __GNUC__
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"
#endif
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>
#ifdef __GNUC__
#pragma GCC diagnostic pop
#endif

void WriteCSV(const vtkSmartPointer<vtkPolyData> &inputData,
              std::string &outputFile);
// [[Rcpp::export]]
void ReadVTK(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void ReadVTP(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void ReadFDS(const std::string &inputTracts, std::string &outputFile);

#endif /* _FIBERREADERS_H */
