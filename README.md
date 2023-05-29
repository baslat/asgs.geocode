
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
#> Simple feature collection with 1 feature and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 144.9666 ymin: -37.81506 xmax: 144.9666 ymax: -37.81506
#> Geodetic CRS:  WGS 84
#>                                                           address candidate
#> 1 Melbourne Town Hall, 100 Swanston St, Melbourne, Victoria, 3000         1
#>   score match_status address_type                   geometry
#> 1   100        match PointAddress POINT (144.9666 -37.81506)

# Get the LGA
lga <- get_asgs(point, 2016, "lga")
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
#>   objectid lga_code_2016 lga_name_2016 shape_length shape_area
#> 1      174         24600 Melbourne (C)     51750.21   59941687
#>   lga_censuscode_2016 area_albers_sqkm                          geoms
#> 1            LGA24600          37.3513 MULTIPOLYGON (((144.9027 -3...
# See available year-geography layers
layers <- get_layers()
layers
#> # A tibble: 61 × 6
#>       id  year geo   name                description                       url  
#>    <int> <dbl> <chr> <chr>               <chr>                             <chr>
#>  1     0  2016 add   ASGS_2016_ADD_GEN   "Australian Drainage Divisions (… http…
#>  2     1  2016 aus   ASGS_2016_AUS_GEN   ""                                http…
#>  3     2  2016 ced   ASGS_2016_CED_GEN   "Commonwealth Electoral Division… http…
#>  4     3  2016 dzn   ASGS_2016_DZN_GEN   ""                                http…
#>  5     4  2016 gccsa ASGS_2016_GCCSA_GEN "Greater Capital City Statistica… http…
#>  6     5  2016 iare  ASGS_2016_IARE_GEN  "Indigenous Areas are medium siz… http…
#>  7     6  2016 iloc  ASGS_2016_ILOC_GEN  "Indigenous Locations (ILOCs) ar… http…
#>  8     7  2016 ireg  ASGS_2016_IREG_GEN  "Indigenous Regions (IREGs) are … http…
#>  9     8  2016 lga   ASGS_2016_LGA_GEN   "Local Government Areas (LGAs) a… http…
#> 10     9  2016 mb    ASGS_2016_MB_GEN    "Mesh Blocks (MB) are the smalle… http…
#> # ℹ 51 more rows
```
