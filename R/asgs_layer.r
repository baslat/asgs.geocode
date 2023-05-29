#' Return the ASGS server and layer URL
#'
#' Give this function a year and a geography and it will return the URL to the
#' feature layer. See available year and geographies with [get_layers()].
#'
#' @param year (numeric) the year of the ASGS
#' @param geo (character) the geographic level (eg "sa1", "SUA", "lga")
#' @return The server and layer URL
#' @export
asgs_layer <- function(year, geo) {
	wanted <- paste("ASGS", year, toupper(geo), "GEN", sep = "_")

	get_layers() |>
		dplyr::filter(.data[["name"]] == wanted) |>
		tidyr::unite("server", c("url", "id"), sep = "/") |>
		dplyr::pull(dplyr::all_of("server"))
}
