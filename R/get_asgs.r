#' Get the ASGS of an `sf` object
#'
#' This function geocodes an [sf::sf()] object to the Australian Statistical
#' Geography Standard.
#'
#' @param .data (sf) The input data to geocode to ASGS
#' @inheritParams asgs_layer
#' @return an [sf::sf()] object containing the ASGS geometry and details
#' @export
#' @examples
#' \dontrun{
#' melbourne <- geocode("Melbourne Town Hall")
#' get_asgs(melbourne, "sa1", 2016)
#' }
get_asgs <- function(.data, geo, year) {
	# TODO add check or functions to deal with multiple rows
 url <- asgs_layer(year = year, geo = geo)

	bbox <- sf::st_bbox(.data)
	# Get the ASGS polygons
	res_raw <- esri2sf::esri2sf(url, bbox = bbox) |>
		# Spatial filter to get closer to the initial geometry (ie not its bbox)
		sf::st_filter(sf::st_transform(.data, crs = 4326L)) |>
		# Rename all columns to lower
		dplyr::rename_all(tolower)

 # Silence warning about spatially constant variables
 sf::st_agr(res_raw) <- "constant"
 sf::st_agr(.data) <- "constant"

 # Calculate the overlapping area
 # TODO is this meaningless when .data is a point inside the area?
	overlaps <- res_raw |>
		sf::st_intersection(.data) |>
		dplyr::mutate(intersect_area = sf::st_area(.data[["geoms"]])) |>
		sf::st_drop_geometry() |>
		dplyr::summarise(
			overlapping_area = as.numeric(sum(.data[["intersect_area"]])),
			.by = .data[["objectid"]]
		)

	res_raw |>
			dplyr::left_join(overlaps, by = "objectid") |>
			dplyr::mutate(overlapping_pct = .data[["overlapping_area"]] / .data[["shape_area"]]) |>
			dplyr::relocate(dplyr::all_of("overlapping_pct"), .after = dplyr::all_of("overlapping_area"))
}
