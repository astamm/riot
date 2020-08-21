#ifndef _TRACKREADERS_H
#define _TRACKREADERS_H

#include <Rcpp.h>
#include <string>
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>

void ProcessPolyData(const vtkSmartPointer <vtkPolyData> &inputData, std::string &outputFile);
// [[Rcpp::export]]
void ReadVTK(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void ReadVTP(const std::string &inputTracts, std::string &outputFile);

#endif /* _TRACKREADERS_H */
