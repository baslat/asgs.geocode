
<!-- README.md is generated from README.Rmd. Please edit that file -->

# asgs.geocode

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/asgs.geocode)](https://CRAN.R-project.org/package=asgs.geocode)
<!-- badges: end -->

The goal of asgs.geocode is to be able to take an address and get the
ASGS code for it.

## Installation

You can install the development version of asgs.geocode from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("baslat/asgs.geocode")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(asgs.geocode)
## basic example code
address <- "Melbourne Town Hall, Melbourne"
point <- geocode(address)
point
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 144.9666 ymin: -37.81506 xmax: 144.9666 ymax: -37.81506
#> Geodetic CRS:  WGS 84
#>                                                           address
#> 1 Melbourne Town Hall, 100 Swanston St, Melbourne, Victoria, 3000
#>                     geometry
#> 1 POINT (144.9666 -37.81506)


# Get the SA1 (layer 12)
sa1 <- point_to_asgs(point, 12)
#> Layer Type: Feature Layer
#> Geometry Type: esriGeometryPolygon
#> Service Coordinate Reference System: 3857
#> Output Coordinate Reference System: 4326
sa1
#> Simple feature collection with 1 feature and 6 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 144.9661 ymin: -37.81745 xmax: 144.9699 ymax: -37.81378
#> Geodetic CRS:  WGS 84
#>   OBJECTID SA1_MAINCODE_2016 Shape_Length Shape_Area SA1_7DIGIT_2016
#> 1    15095       20604112225      1468.25   129312.4         2112225
#>   STATE_CODE_2016                          geoms
#> 1               2 MULTIPOLYGON (((144.9686 -3...

# Get the LGA (guess the layer)
lga <- point_to_asgs(point, guess_geo(2016, "lga"))
#> Layer Type: Feature Layer
#> Geometry Type: esriGeometryPolygon
#> Service Coordinate Reference System: 3857
#> Output Coordinate Reference System: 4326
lga
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 144.8971 ymin: -37.85067 xmax: 144.9914 ymax: -37.77545
#> Geodetic CRS:  WGS 84
#>   OBJECTID LGA_CODE_2016 LGA_NAME_2016 Shape_Length Shape_Area
#> 1      174         24600 Melbourne (C)     51750.21   59941687
#>   LGA_CENSUSCODE_2016 AREA_ALBERS_SQKM                          geoms
#> 1            LGA24600          37.3513 MULTIPOLYGON (((144.9027 -3...
```
