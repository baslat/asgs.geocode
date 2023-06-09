% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_layers.r
\name{get_layers}
\alias{get_layers}
\title{Get ABS ASGS Layers}
\usage{
get_layers()
}
\value{
A data frame of the ABS ASGS layers
}
\description{
Get a data frame of the ABS ASGS layers available for geocoding.
}
\examples{
layers <- get_layers()
# What LGA years are available? 2016-2022!
dplyr::filter(layers, geo == "lga")

# What's available for 2018? LGA, CED and SED!
dplyr::filter(layers, year == 2018)

}
