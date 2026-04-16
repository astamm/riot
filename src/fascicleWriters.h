#ifndef _FIBERWRITERS_H
#define _FIBERWRITERS_H

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

void ReadCSV(const std::string &inputFile,
             vtkSmartPointer<vtkPolyData> &inputData);
// [[Rcpp::export]]
void WriteVTK(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void WriteVTP(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void WriteFDS(const std::string &inputTracts, std::string &outputFile);

#endif /* _FIBERWRITERS_H */
