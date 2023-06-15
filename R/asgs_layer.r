#' Return the ASGS server and layer URL
#'
#' Give this function a year and a geography and it will return the URL to the
#' feature layer. See available year and geographies with [get_layers()].
#'
#' @param geo (character) the geographic level (eg "sa1", "SUA", "lga")
#' @param year (numeric) the year of the ASGS
#' @return The server and layer URL
#' @export
asgs_layer <- function(geo, year) {
	wanted <- paste("ASGS", year, toupper(geo), "GEN", sep = "_")

	get_layers() |>
		dplyr::filter(.data[["name"]] == wanted) |>
		tidyr::unite("server", c("url", "id"), sep = "/") |>
		dplyr::pull(dplyr::all_of("server"))
}
