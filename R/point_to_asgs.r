#' Geocode a point to ASGS
#'
#' @param .data The input data
#' @param layer The layer to use
#' @return ASGS data
#' @export
#' @examples
#' \dontrun{
#' melbourne <- geocode("Melbourne Town Hall")
#' point_to_asgs(melbourne)
#' }
point_to_asgs <- function(.data, layer) {
	server <- "https://geo.abs.gov.au/arcgis/rest/services/ASGS2016/SEARCH/MapServer/"
	url <- paste0(server, layer)
	bbox <- sf::st_bbox(.data)
	esri2sf::esri2sf(url, bbox = bbox)
}
