#' Geocode a point to ASGS
#'
#' This function geocodes an [sf::sf()] object to the Australian Statistical Geography Standardf.
#'
#' @param .data (sf) The input data to geocode to ASGS
#' @inheritParams asgs_layer
#' @param layer (numeric; default = `NULL`) The layer to use if you know the
#' code. View all available layers with [get_layers()].
#' @return an [sf::sf()] object containing the ASGS geometry and details
#' @export
#' @examples
#' \dontrun{
#' melbourne <- geocode("Melbourne Town Hall")
#' get_asgs(melbourne, 2016, "sa1")
#' }
get_asgs <- function(.data, year, geo) {
	# TODO add check or functions to deal with multiple rows
 url <- asgs_layer(year = year, geo = geo)

	bbox <- sf::st_bbox(.data)
	esri2sf::esri2sf(url, bbox = bbox) |>
		# Spatial filter to get closer to the initial geometry (ie not its bbox)
		sf::st_filter(sf::st_transform(.data, crs = 4326L)) |>
		# Rename all columns to lower
		dplyr::rename_all(tolower)
}
