#' Get ABS ASGS Layers
#'
#' Get a data frame of the ABS ASGS layers available for geocoding.
#'
#' @return A data frame of the ABS ASGS layers
#'
#' @examples
#' layers <- get_layers()
#' # What LGA years are available? 2016-2022!
#' dplyr::filter(layers, geo == "lga")
#'
#' # What's available for 2018? LGA, CED and SED!
#' dplyr::filter(layers, year == 2018)
#'
#' @export
get_layers <- function() {
	prep_layers <- function(url) {
		lay <- esri2sf::esriLayers(url)

		tibble::tibble(lay[["layers"]]) |>
			dplyr::mutate(
				year = as.numeric(stringr::str_extract(name, "\\d{4}")),
				geo = tolower(stringr::str_extract(name, "(?<=\\d{4}_).*(?=_)")),
				url = url
			) |>
			dplyr::select(dplyr::all_of(c("id", "year", "geo", "name", "description", "url")))
	}

	purrr::map(asgs_servers(), prep_layers) |>
		purrr::list_rbind()
}
