#' Meshblock Counts 2021
#'
#' Meshblock counts from the 2021 Census of Population and Housing, including
#' category and counts of dwellings and persons by usual residence.
#'
#' @format ## `mbc2021`
#' A data frame with 368,285 rows and `r ncol(mbc2021)` variables:
#' \describe{
#'  \item{mb_code_2021}{Meshblock code}
#'  \item{mb_category}{Meshblock category}
#'  \item{area_albers_sqkm}{Area in square kilometres}
#'  \item{dwellings}{Count of dwellings}
#'  \item{persons}{Count of persons usually resident}
#'  \item{state_code}{State code}
#'  \item{ASGS identifiers}{Various columns to identify the ASGS hierarchy}
#' }
#' @source [ABS](https://www.abs.gov.au/census/guide-census-data/mesh-block-counts/latest-release)
"mbc2021"
