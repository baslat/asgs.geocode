#' Get ABS ASGS Layers
#'
#' Get a data frame of the ABS ASGS layers
#'
#' @return A data frame of the ABS ASGS layers
#'
#' @examples
#' get_layers()
#'
#' @export
get_layers <- function() {
	lay <- esri2sf::esriLayers("https://geo.abs.gov.au/arcgis/rest/services/ASGS2016/SEARCH/MapServer/")

	tibble::tibble(lay[["layers"]]) |>
		dplyr::select(dplyr::all_of(c("id", "name", "description")))
}
