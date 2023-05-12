#' Geocode an address using ArcGIS
#'
#' @param address The address to geocode
#' @return A \code{sf} object containing the address and its coordinates
#' @export
#'
#' @examples
#' \dontrun{
#' geocode("Melbourne Town Hall")
#' }
geocode <- function(address) {
	stem <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine="

	end <- "&f=json&countryCode=AUS&maxLocations=1"

	url <- paste0(stem, address, end) |>
		utils::URLencode()

	res <- httr::GET(url)

	cont <- httr::content(res)[["candidates"]][[1]]

	sfc <- sf::st_point(x = c(cont$location$x, cont$location$y)) |>
		sf::st_sfc(crs = 4326)

	sf::st_sf(address = cont$address, geometry = sfc)
}
