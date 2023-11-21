#' Geocode an address using ArcGIS
#'
#' This function geocodes an address using the ArcGIS API. The address is
#' suffixed with the country code "AUS". The more specific the address, the more
#' likely the correct result will be returned. See details for more information.
#'
#' The returned object has the matched address as well as columns indicating the
#' accuracy of the match. These columns are:
#' \describe{
#' \item{rank}{A numerical text value or floating-point value in a number field,
#' depending on the locator that indicates the importance of a result relative
#' to other results with the same name. For example, there are cities in France
#' and Texas named Paris. Paris, France, has a greater population than Paris,
#' Texas, so it has a higher rank. The smaller numbers represent higher-ranked
#' features. Rank is used to sort results for ambiguous queries such as Lincoln,
#' in which no additional information (state) is available. Rank values are
#' based on population or feature type.}
#' \item{score}{The match score of the candidate to which the address was
#' matched. The score can be in a range of 0 to 100, in which 100 indicates the
#' candidate is a perfect match.}
#' \item{match_status}{The status of the address match. The status can be one of
#' the following: matched, tied, unmatched.}
#' \item{type}{The feature type for results returned by a search. The Type field
#' only includes a value for candidates with Addr_type = POI or Locality, as an
#' example, for Starbucks, `Type = Coffee Shop`.}
#' \item{address_type}{The type of address that was matched. There are many
#' address types, with `Subaddress` generally being the most spatially accurate. See
#' [here](https://pro.arcgis.com/en/pro-app/latest/help/data/geocoding/what-is-included-in-the-geocoded-results-.htm)
#' (search `Addr_type`) for more details.}
#' }
#'
#' @param address (character) The address to geocode
#' @param max_results (numeric; default = `5L`) How many address candidates to return.
#' @return A one-row [sf::sf()] object containing the address and its coordinates.
#' @export
#'
#' @examples
#' \dontrun{
#' geocode(address = "Melbourne Town Hall")
#' geocode(address = "Melbourne Town Hall", 2)
#' }
geocode <- function(address, max_results = 5L) {
	assertthat::assert_that(
		is.character(address),
		is.numeric(max_results)
	)
	assertthat::assert_that(
		length(address) == 1L,
		length(max_results) == 1L,
		msg = "`address` and `max_results` must both be length 1"
	)
	# Create the URL to geocode
	stem <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine="

	max_results <- paste0("&maxLocations=", max_results)

	end <- paste0("&f=json&countryCode=AUS&outFields=*", max_results)

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

	# Internal function to iterate over all candidates
	prep_candidates <- function(x) {
		score <- x[["score"]]
		match_status <- switch(
			x[["attributes"]][["Status"]],
			"M" = "match",
			"T" = "tie",
			"U" = "unmatch"
		)
		address_type <- x[["attributes"]][["Addr_type"]]

		sfc <- sf::st_point(x = c(x[["location"]][["x"]], x[["location"]][["y"]])) |>
			sf::st_sfc(crs = 4326L)

		sf::st_sf(
			place = x[["address"]],
			address = x[["attributes"]][["LongLabel"]],
			rank = x[["attributes"]][["Rank"]],
			score = score,
			match_status = match_status,
			type = x[["attributes"]][["Type"]],
			address_type = address_type,
			geometry = sfc
		)
	}
	purrr::map(candidates, prep_candidates) |>
		purrr::list_rbind() |>
		sf::st_sf()
}
