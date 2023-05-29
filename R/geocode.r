#' Geocode an address using ArcGIS
#'
#' This function geocodes an address using the ArcGIS API. The address is
#' suffixed with the country code "AUS". The more specific the address, the more
#' likely the correct result will be returned. See details for more information.
#'
#' The returned object has the matched address as well as columns indicating the
#' accuracy of the match. These columns are:
#' \describe{
#' \item{candidate}{Which address candidate was returned. The default is 1, which is the most likely result.}
#' \item{score}{The match score of the candidate to which the address was
#' matched. The score can be in a range of 0 to 100, in which 100 indicates the
#' candidate is a perfect match.}
#' \item{match_status}{The status of the address match. The status can be one of
#' the following: matched, tied, unmatched.}
#' \item{address_type}{The type of address that was matched. There are many
#' address types, with `Subaddress` generally being the most spatially accurate. See
#' [here](https://pro.arcgis.com/en/pro-app/latest/help/data/geocoding/what-is-included-in-the-geocoded-results-.htm)
#' (search `Addr_type`) for more details.}
#' }
#'
#' @param address (character) The address to geocode
#' @param candidate (integer) The address candidate to return. Defaults to 1
#' (the most likely result). Changing this can be useful if geocoding returns a
#' tie.
#' @return A one-row [sf::sf()] object containing the address and its coordinates.
#' @export
#'
#' @examples
#' \dontrun{
#' geocode(address = "Melbourne Town Hall")
#' geocode(address = "Melbourne Town Hall", 2)
#' }
geocode <- function(address, candidate = 1L) {
	assertthat::assert_that(is.character(address))
	assertthat::assert_that(
		length(address) == 1L,
		length(candidate) == 1L,
		msg = "`address` and `candidate` must both be length 1"
	)
	# Create the URL to geocode
	stem <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine="

	end <- "&f=json&countryCode=AUS&maxLocations=10&outFields=*"

	url <- paste0(stem, address, end) |>
		utils::URLencode()

	res <- httr::GET(url)
	#  Get the geocoded address
	candidates <- httr::content(res)[["candidates"]]

	num_candidates <- length(candidates)

	# Check it got something
	assertthat::assert_that(
		num_candidates > 0L,
		msg = "Geocoding failed. Try a more specific address."
	)

	if (candidate > num_candidates) {
		candidate <- num_candidates
		warning(
			"`candidate` is greater than the number of address candidates. Using the last candidate (",
			num_candidates,
			")."
		)
	}

	# Pull out the address and build an sf
	cont <- candidates[[candidate]]
	score <- cont[["score"]]
	match_status <- switch(
		cont[["attributes"]][["Status"]],
		"M" = "match",
		"T" = "tie",
		"U" = "unmatch"
	)
	address_type <- cont[["attributes"]][["Addr_type"]]

	sfc <- sf::st_point(x = c(cont[["location"]][["x"]], cont[["location"]][["y"]])) |>
		sf::st_sfc(crs = 4326L)

	sf::st_sf(
		address = cont[["address"]],
		candidate = candidate,
		score = score,
		match_status = match_status,
		address_type = address_type,
		geometry = sfc
	)
}
