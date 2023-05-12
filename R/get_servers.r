#' Get the list of servers from the ABS ArcGIS REST API
#'
#' @return A character vector of the servers
#' @export
get_servers <- function() {
	# Scrape the page for a list of servers, could be useful for future validation.
    rvest::read_html("https://geo.abs.gov.au/arcgis/rest/services/") |>
		rvest::html_nodes("ul") |>
		rvest::html_nodes("a") |>
		rvest::html_text()
}
