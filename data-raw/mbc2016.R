## code to prepare `mbc2016` dataset goes here

url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&2016%20census%20mesh%20block%20counts.csv&2074.0&Data%20Cubes&1DED88080198D6C6CA2581520083D113&0&2016&04.07.2017&Latest"

mbc2016 <- readr::read_csv(
	file = url,
	skip = 1L,
	col_names = c(
		"mb_code_2016",
		"mb_category",
		"area_albers_sqkm",
		"dwellings",
		"persons",
		"state_code"
	),
	col_types = readr::cols(
		mb_code_2016 = readr::col_character(),
		mb_category = readr::col_character(),
		area_albers_sqkm = readr::col_double(),
		dwellings = readr::col_double(),
		persons = readr::col_double(),
		state_code = readr::col_character()
	)
)

usethis::use_data(mbc2016, overwrite = TRUE)
