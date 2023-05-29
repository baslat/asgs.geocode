#' The URLs for the ASGS Servers
#'
#' The folders ASGS2016 and ASGS2021 contain SEARCH services. The SEARCH
#' services contain layers for different geographies and years (eg the 2021
#' folder contains 2022 LGAs).
#' @return A named list of the URLs
asgs_servers <- function() {
	list(
		`2016` = "https://geo.abs.gov.au/arcgis/rest/services/ASGS2016/SEARCH/MapServer",
		`2021` = "https://geo.abs.gov.au/arcgis/rest/services/ASGS2021/SEARCH/MapServer"
	)
}
