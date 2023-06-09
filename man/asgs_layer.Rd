% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/asgs_layer.r
\name{asgs_layer}
\alias{asgs_layer}
\title{Return the ASGS server and layer URL}
\usage{
asgs_layer(geo, year)
}
\arguments{
\item{geo}{(character) the geographic level (eg "sa1", "SUA", "lga")}

\item{year}{(numeric) the year of the ASGS}
}
\value{
The server and layer URL
}
\description{
Give this function a year and a geography and it will return the URL to the
feature layer. See available year and geographies with \code{\link[=get_layers]{get_layers()}}.
}
