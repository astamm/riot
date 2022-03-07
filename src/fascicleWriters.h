#ifndef _FIBERWRITERS_H
#define _FIBERWRITERS_H

#include <Rcpp.h>
#include <string>
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>

void ReadCSV(const std::string &inputFile, vtkSmartPointer <vtkPolyData> &inputData);
// [[Rcpp::export]]
void WriteVTK(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void WriteVTP(const std::string &inputTracts, std::string &outputFile);

#endif /* _FIBERWRITERS_H */
