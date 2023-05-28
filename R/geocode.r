#' Geocode an address using ArcGIS
#'
#' This function geocodes an address using the ArcGIS API. The address is
#' suffixed with the country code "AUS", and only the top match is returned. The
#' more specific the address, the more likely the correct result will be
#' returned.
#'
#' @param address (character) The address to geocode
#' @return A one-row [sf::sf()] object containing the address and its coordinates
#' @export
#'
#' @examples
#' \dontrun{
#' geocode(address = "Melbourne Town Hall")
#' }
geocode <- function(address) {
	assertthat::assert_that(is.character(address))
	assertthat::assert_that(
		length(address) == 1L,
		msg = "`address` must be length 1"
	)

	stem <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine="

	end <- "&f=json&countryCode=AUS&maxLocations=1"

	url <- paste0(stem, address, end) |>
		utils::URLencode()

	res <- httr::GET(url)

	cont <- httr::content(res)[["candidates"]][[1L]]

	sfc <- sf::st_point(x = c(cont[["location"]][["x"]], cont[["location"]][["y"]])) |>
		sf::st_sfc(crs = 4326L)

	sf::st_sf(address = cont[["address"]], geometry = sfc)
}
