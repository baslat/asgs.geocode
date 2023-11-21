## code to prepare `mbc2016` dataset goes here

url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&2016%20census%20mesh%20block%20counts.csv&2074.0&Data%20Cubes&1DED88080198D6C6CA2581520083D113&0&2016&04.07.2017&Latest"

nsw_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_nsw_csv.zip&1270.0.55.001&Data%20Cubes&1FC672E70A77D52FCA257FED0013A0F7&0&July%202016&12.07.2016&Latest"
vic_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_vic_csv.zip&1270.0.55.001&Data%20Cubes&F1EA82ECA7A762BCCA257FED0013A253&0&July%202016&12.07.2016&Latest"
qld_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_qld_csv.zip&1270.0.55.001&Data%20Cubes&A6A81C7C2CE74FAACA257FED0013A344&0&July%202016&12.07.2016&Latest"
sa_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_sa_csv.zip&1270.0.55.001&Data%20Cubes&5763C01CA9A3E566CA257FED0013A38D&0&July%202016&12.07.2016&Latest"
wa_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_wa_csv.zip&1270.0.55.001&Data%20Cubes&6C293909851DCBFFCA257FED0013A3BF&0&July%202016&12.07.2016&Latest"
tas_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_tas_csv.zip&1270.0.55.001&Data%20Cubes&A9B01B4DACD0BFEFCA257FED0013A3FC&0&July%202016&12.07.2016&Latest"
nt_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_nt_csv.zip&1270.0.55.001&Data%20Cubes&CA6464FAA0777F80CA257FED0013A429&0&July%202016&12.07.2016&Latest"
act_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_act_csv.zip&1270.0.55.001&Data%20Cubes&10AFEFD3A73B902ECA257FED0013A455&0&July%202016&12.07.2016&Latest"
ot_url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_ot_csv.zip&1270.0.55.001&Data%20Cubes&DE3FEF9908F4CF9BCA257FED0013A48F&0&July%202016&12.07.2016&Latest"

tdir <- tempdir()

urls <- c(
	nsw_url,
	vic_url,
	qld_url,
	sa_url,
	wa_url,
	tas_url,
	nt_url,
	act_url,
	ot_url
)


dl_unzip <- function(x, dir){
 sak::download_file(x, "zip", dir = dir) |>
		unzip(exdir = dir)
}

purrr::walk(urls, dl_unzip, dir = tdir)

mb_raw <- list.files(tdir, pattern = ".csv$") |>
	purrr::map(readr::read_csv) |>
	purrr::list_rbind()

mb_asgs <- mb_raw |>
	janitor::clean_names() |>
	dplyr::select(-sa1_7digitcode_2016, -sa2_5digitcode_2016, -mb_category_name_2016) |>
	dplyr::select(dplyr::starts_with(c("mb", "sa"))) |>
 dplyr::mutate(mb_code_2016 = as.character(mb_code_2016))

mbc2016_raw <- readr::read_csv(
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

mbc2016 <-  mbc2016_raw |>
	dplyr::full_join(mb_asgs)

usethis::use_data(mbc2016, overwrite = TRUE)
