#ifndef _TRACKREADERS_H
#define _TRACKREADERS_H

#include <Rcpp.h>

// [[Rcpp::export]]
Rcpp::List ReadVTP(std::string &file);

#endif /* _TRACKREADERS_H */
