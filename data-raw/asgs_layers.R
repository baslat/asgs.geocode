## code to prepare `asgs_layers` dataset goes here
asgs_layers <- get_layers()

usethis::use_data(asgs_layers, overwrite = TRUE)
