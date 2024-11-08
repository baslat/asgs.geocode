## code to prepare `mbc2021` dataset goes here
library(readxl)
url <- "https://www.abs.gov.au/census/guide-census-data/mesh-block-counts/2021/Mesh%20Block%20Counts%2C%202021.xlsx"

tf <- tempfile(fileext = ".xlsx")

utils::download.file(url, , destfile = tf, mode = "wb")

sheets <- readxl::excel_sheets(tf) |>
	purrr::keep(~ grepl("Table", .x, fixed = TRUE))


clean_mb <- function(file, sheet) {
	readxl::read_excel(
		file,
		sheet = sheet,
		skip = 7L,
		col_names = c(
			"mb_code_2021",
			"mb_category",
			"area_albers_sqkm",
			"dwellings",
			"persons",
			"state_code"
		),
		col_types = c(
			"text",
			"text",
			"numeric",
			"numeric",
			"numeric",
			"text"
		)
	) |>
		tidyr::drop_na("state_code")
}

mbc2021 <- purrr::map(sheets, clean_mb, file = tf) |>
	purrr::list_rbind()

mbc2021

# Get MB to SA1
url_asgs <- "https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/allocation-files/MB_2021_AUST.xlsx"

tf2 <- tempfile(fileext = ".xlsx")

utils::download.file(url_asgs, , destfile = tf2, mode = "wb")

mb_asgs <- readxl::read_excel(tf2) |>
	janitor::clean_names() |>
	dplyr::select(mb_code_2021, dplyr::contains("sa"))

mbc2021 <- mbc2021 |>
 dplyr::left_join(mb_asgs, by = dplyr::join_by(mb_code_2021))

usethis::use_data(mbc2021, overwrite = TRUE)
