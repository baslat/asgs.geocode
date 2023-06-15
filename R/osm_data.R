#' Query OpenStreetMap (OSM) for features
#'
#' Get the SF details for each requested feature. The list of OSM features is
#' \href{https://wiki.openstreetmap.org/wiki/Map_features}{here}. Use in
#' conjunction with \code{osm_bind}.
#'
#' @param bbox (bounding box) the area to be queried. Must have a CRS of
#' `"+proj=longlat +datum=WGS84"`
#' @param feature_key (character) the feature key to query, for example
#' "highway" or "leisure". Feature keys can be found here
#' \code{osmdata::available_features()}
#' @param feature_values (character; default = `NULL`) a vector of feature values to query, passed
#'   to \code{osmdata::add_osm_feature()}. Use \code{NULL} to return all values
#'   of your feature.
#'
#' @return a list of \code{sf} objects, technically an \code{osmdata} object
#' @export
#'
#' @examples
#' \dontrun{
#' # Let's get all the parkland around Parramatta Park
#' # Geocode it to a point
#' address <- "Parramatta Park, Parramatta NSW"
#' pt <- geocode(address)
#'
#' # Expand the bounding box
#' bbox <- pt |>
#' 	# Transform to use meters
#' 	sf::st_transform(crs = 7845) |>
#' 	# 500m buffer
#' 	sf::st_buffer(dist = 500) |>
#' 	# OSM needs this crs
#' 	sf::st_transform("+proj=longlat +datum=WGS84") |>
#' 	sf::st_bbox()
#'
#' # Find the parks
#' feats_raw <- osm_find(bbox, "leisure", "park")
#' # OSM returns different geometries. We want polygon-flavoured ones
#' feats <- osm_bind(feats_raw, c("polygons", "multipolygons"))
#'
#' # View it!
#' mapview::mapview(feats, zcol = "name")
#' }
osm_find <- function(bbox, feature_key, feature_values = NULL) {
	# Check for installed package
	rlang::check_installed("osmdata") # nolint

	# Check CRS of bounding box
	bbox_crs <- sf::st_crs(bbox)

	assertthat::assert_that(
		bbox_crs[["input"]] == "+proj=longlat +datum=WGS84",
		msg = "The CRS of your bounding box is incorrect. Use the following code to get a bbox with the CRS OSM requires:\n\nsf::st_transform(sf_object, '+proj=longlat +datum=WGS84') |> sf::st_bbox()\n\n" # nolint
	)

	# Set the OSM query connection
	bbox |>
		osmdata::opq(timeout = 50L) |>
		osmdata::add_osm_feature(
			key = feature_key,
			value = feature_values
		) |>
		osmdata::osmdata_sf(quiet = TRUE)
}



#' Bind the results of an OpenStreetMap (OSM) feature query
#'
#' An OSM query returns a list of SFs of different types. This function binds
#' the ones you want together. If a requested geometry is NULL it will not be
#' returned, obviously. You need to use a CRS with latitude and longitude, not
#' decimal degrees.
#'
#' @param sf_list (\code{osmdata} object) as returned by
#'   \code{osm_query_features}
#' @param types (character vector) which SF types do you want. Valid options:
#'   lines, points, polygons, multilines, multipolygons
#' @param crs (numeric, default = 4326) which CRS should the result be?
#'   \code{osmdata} returns 4326 by default, but in order to intersect two sfs
#'   they must have the same crs, and if you are dealing with Australian
#'   geographies you may like to use 7844.
#'
#' @return a \code{sf}
#' @export
#'
osm_bind <- function(
	sf_list,
	types = c("points", "lines", "polygons", "multilines", "multipolygons"),
	crs = 4326L
) { # nolint
	# Check the inputs
	assertthat::assert_that(inherits(sf_list, "osmdata"))

	types <- rlang::arg_match(types, multiple = TRUE)

	# Add prefix to make names correct
 types_prefix <- paste0("osm_", types)

	# Filter sf_list to just what was requested
	kept_sf <- sf_list[types_prefix] |>
		purrr::discard(.p = is.null)

	# Bind the final results
	if (length(kept_sf) == 1L) {
		final_sf <- kept_sf[[1L]]
	} else {
		final_sf <- dplyr::bind_rows(kept_sf)
	}

	# Break for invalid selection
	if (length(final_sf) == 0L) {
		valid_geoms <- sf_list |>
			purrr::discard(.p = is.null) |>
			names() |>
			purrr::keep(
				.p = stringr::str_starts,
				pattern = "osm_"
			) |>
			purrr::map(
				stringr::str_remove,
				pattern = "osm_"
			) |>
			paste(collapse = ", ")


		stop("The geometries you requested were all NULL.
         The valid choices for your sf_list are: ", valid_geoms)
	}

	final_sf |>
		sf::st_make_valid() |>
		sf::st_transform(crs = crs)
}

#' Summarise OpenStreetMap (OSM) features by group
#'
#' Generally you will do this after querying the OSM features, binding the
#' results, intersecting with an irregular polygon (e.g. a burnscar).
#'
#' Requires the geometry column to be called geometry (and not geos or
#' some-such).
#'
#' @param osm_sf (\code{sf}) SF data you want to summarise.
#' @param ... (unquoted character; optional) columns to group by
#' @param .f (character) summary function. At the moment only "length", "area"
#'   or "count". Assumes the underlying data are additive.
#' @param units (character, default = NULL) units to summarise to, usually "km"
#'   or "km^2. If left blank it will use some variant of meters.
#'
#' @return a simple tibble with the grouped columns and an additional summary
#'   column
#' @export
#'
osm_summarise <- function(osm_sf, ..., .f, units = NULL) {
	# Class check
	assertthat::assert_that(inherits(osm_sf, "sf"))
	assertthat::assert_that(length(.f) == 1L)
	assertthat::assert_that(.f %in% c("length", "area", "count"))

	# Group by relevant columns
	if (!missing(...)) {
		osm_sf <- dplyr::group_by(osm_sf, ..., .add = TRUE)
	}

	# Use .f to build an expression (ie the code to be run)
	fun_raw <- paste0("sf::st_", .f, "(.data$geometry)")
	fun <- rlang::expr(!!fun_raw)

	if (.f %in% c("length", "area")) {
		# Run the summary function and assign to dynamic variable name
		summary_df <- osm_sf |>
			dplyr::mutate(summary = eval(parse(text = fun))) |>
			# Can't use strip_geometry as it doesn't respect groups
			sf::st_set_geometry(NULL) |>
			dplyr::summarise({{ .f }} := sum(summary))
	} else {
		summary_df <- osm_sf |>
			# Can't use strip_geometry as it doesn't respect groups
			sf::st_set_geometry(NULL) |>
			dplyr::count(name = "count")
	}


	if (!is.null(units)) {
		units(summary_df[[.f]]) <- units
	}

	return(summary_df)
}
