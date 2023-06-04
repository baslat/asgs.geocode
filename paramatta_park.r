library(sak)
library(sf)

address <- "Parramatta Park, Parramatta NSW"

pt <- geocode(address)

mapview::mapview(pt)

bbox <- pt |>
	st_transform(crs = 7845) |>
	st_buffer(dist = 3000) |>
	sf::st_transform("+proj=longlat +datum=WGS84") |>
	st_bbox()



feats_raw <- osm_find(bbox, "leisure", "park")
feats <- osm_bind(feats_raw, "multipolygons")

pp <- feats |>
	dplyr::filter(stringr::str_detect(name, "Parramatta Park"))

mapview::mapview(pp)

asgs <- get_asgs(pp, 2016, "sa1")

mapview::mapview(asgs) + mapview::mapview(pp, col.regions = "green")
