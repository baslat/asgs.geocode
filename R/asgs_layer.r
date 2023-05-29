#' Return the ASGS layer ID
#'
#' This.
#'
#' @param year (numeric) the year of the ASGS
#' @param geo (character) the geographic level (eg "sa1", "SUA", "lga")
#' @return The ID of the layer
#' @export
asgs_layer <- function(year, geo) {
	wanted <- paste("ASGS", year, toupper(geo), "GEN", sep = "_")
	get_layers() |>
		dplyr::filter(.data[["name"]] == wanted) |>
		dplyr::pull(dplyr::all_of("id"))
}
