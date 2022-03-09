#ifndef _FIBERREADERS_H
#define _FIBERREADERS_H

#include <Rcpp.h>
#include <string>
#include <vtkPolyData.h>
#include <vtkSmartPointer.h>

void WriteCSV(const vtkSmartPointer <vtkPolyData> &inputData, std::string &outputFile);
// [[Rcpp::export]]
void ReadVTK(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void ReadVTP(const std::string &inputTracts, std::string &outputFile);
// [[Rcpp::export]]
void ReadFDS(const std::string &inputTracts, std::string &outputFile);

#endif /* _FIBERREADERS_H */
