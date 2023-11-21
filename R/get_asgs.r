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
 url <- asgs_layer(geo = geo, year = year)

  bbox <- sf::st_bbox(.data)
  # Get the ASGS polygons
  res_raw <- esri2sf::esri2sf(
			url,
			bbox = bbox,
			# where = "OBJECTID=1"
			resultRecordCount = 2000,
			exceededTransferLimit = "true"
		) |>
			# Spatial filter to get closer to the initial geometry (ie not its bbox)
			# Need make valid for loops like islands
			sf::st_make_valid() |>
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

asgs2 <- function(.data, geo, year) {
	base_url <- asgs_layer(year = year, geo = geo) |>
		paste0("/query")

	bbox <- sf::st_bbox(.data) |>
		toString() |>
		urltools::url_encode()

	orig_crs <- sf::st_crs(.data)$epsg

# Going to need to get the count first
the_count <- urltools::param_set(base_url, key = "geometry", value = bbox) |>
	param_set(key = "inSR", value = orig_crs) |>
	param_set(key = "returnCountOnly", value = "true") |>
	param_set(key = "f", value = "json") |>
	readLines(warn = FALSE) |>
	jsonify::from_json()

# Then if the count is more than 2000, need to split over multiple queries


 query <- urltools::param_set(base_url, key = "geometry", value = bbox) |>
		param_set(key = "inSR", value = orig_crs) %>%
		param_set(key = "resultRecordCount", value = 5000) %>%
		param_set(key = "spatialRel", value = "esriSpatialRelIntersects") %>%
		param_set(key = "f", value = "geojson") %>%
		param_set(key = "outFields", value = "*") %>%
		param_set(key = "geometryType", value = "esriGeometryEnvelope") %>%
		param_set(key = "returnGeometry", value = "true") %>%
		param_set(key = "returnTrueCurves", value = "false") %>%
		param_set(key = "returnIdsOnly", value = "false") %>%
		param_set(key = "returnCountOnly", value = "false") %>%
		param_set(key = "returnZ", value = "false") %>%
		param_set(key = "returnM", value = "false") %>%
		param_set(key = "returnDistinctValues", value = "false") %>%
		param_set(key = "returnExtentOnly", value = "false") %>%
		param_set(key = "featureEncoding", value = "esriDefault") |>
		param_set(key = "maxRecordCountFactor", value = 5)

	# Use readlines first to silence the warning about incomplete final line
	res_raw <- readLines(query, warn = FALSE) |>
		geojsonsf::geojson_sf() |>
		sf::st_make_valid() |>
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
			dplyr::mutate(intersect_area = sf::st_area(.data[["geometry"]])) |>
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
