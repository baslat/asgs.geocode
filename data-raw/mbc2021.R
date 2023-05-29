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

usethis::use_data(mbc2021, overwrite = TRUE)
