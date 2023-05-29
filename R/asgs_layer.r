#' Return the ASGS layer ID
#'
#' @param year The year of the ASGS
#' @param geo The geographic level (eg "sa1", "SUA")
#' @return The ID of the layer
#' @export
asgs_layer <- function(year, geo) {
	wanted <- paste("ASGS", year, toupper(geo), "GEN", sep = "_")
	get_layers() |>
		dplyr::filter(.data[["name"]] == wanted) |>
		dplyr::pull(dplyr::all_of("id"))
}
