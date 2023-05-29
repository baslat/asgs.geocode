#' Get ABS ASGS Layers
#'
#' Get a data frame of the ABS ASGS layers available for geocoding.
#'
#' @return A data frame of the ABS ASGS layers
#'
#' @examples
#' layers <- get_layers()
#' # What LGA years are available? 2016-2020!
#' dplyr::filter(layers, geo == "lga")
#'
#' # What's available for 2018? LGA, CED and SED!
#' dplyr::filter(layers, year == 2018)
#'
#' @export
get_layers <- function() {
	lay <- esri2sf::esriLayers("https://geo.abs.gov.au/arcgis/rest/services/ASGS2016/SEARCH/MapServer/")

	tibble::tibble(lay[["layers"]]) |>
		dplyr::mutate(
			year = as.numeric(stringr::str_extract(name, "\\d{4}")),
			geo = tolower(stringr::str_extract(name, "(?<=\\d{4}_).*(?=_)"))
		) |>
		dplyr::select(dplyr::all_of(c("id", "year", "geo", "name", "description")))
}
