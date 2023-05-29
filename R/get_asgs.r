#' Geocode a point to ASGS
#'
#' This function geocodes an [sf::sf()] object to the Australian Statistical Geography Standard.
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
get_asgs <- function(.data, year, geo, layer = NULL) {
	# TODO add check or functions to deal with multiple rows
	layer <- layer %||% asgs_layer(year = year, geo = geo)


	server <- "https://geo.abs.gov.au/arcgis/rest/services/ASGS2016/SEARCH/MapServer/"
	url <- paste0(server, layer)
	bbox <- sf::st_bbox(.data)
	esri2sf::esri2sf(url, bbox = bbox) |>
		# Spatial filter to get closer to the initial geometry (ie not its bbox)
		sf::st_filter(sf::st_transform(.data, crs = 4326L)) |>
		# Rename all columns to lower
		dplyr::rename_all(tolower)
}
