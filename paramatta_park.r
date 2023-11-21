# Goal: get the SA1s of Parramatta Park.
# Bonus: get PP polygon

library(sf)

# Let's get all the parkland around Parramatta Park

# Geocode it to a point
address <- "Parramatta Park, Parramatta NSW"
pt <- geocode(address)

# Expand the bounding box
bbox <- pt |>
	# Transform to use meters
	sf::st_transform(crs = 7845) |>
	# 500m buffer
	sf::st_buffer(dist = 500) |>
	# OSM needs this crs
	sf::st_transform("+proj=longlat +datum=WGS84") |>
	sf::st_bbox()

# Find the parks
feats_raw <- osm_find(bbox, "leisure", "park")

feats_raw

# OSM returns different geometries. We want polygon-flavoured ones
feats <- osm_bind(feats_raw, c("polygon", "multipolygons"))

# View it!
mapview::mapview(feats, zcol = "name")

pp <- feats |>
 dplyr::filter(name %in% c("Parramatta Park", "Parramatta Golfcourse", "Mays Hill")) |>
		dplyr::select(name)


mapview::mapview(pp)

asgs <- get_asgs(pp, "sa1", 2016)

mapview::mapview(asgs, zcol = "overlapping_area")

mapview::mapview(asgs) + mapview::mapview(pp, col.regions = "green")

# Need a function to show how much of the ASGS is within the park, and maybe some threshold argument?


# ? Can I get roads and parks with one query?


res_raw |>
	sf::st_intersection(.data) |>
	dplyr::mutate(intersect_area = sf::st_area(geoms)) |>
	sf::st_drop_geometry() |>
	dplyr::summarise(
			overlapping_area = sum(intersect_area),
			.by = objectid
		)

asgs |>
	dplyr::semi_join(sig_areas) |>
	mapview::mapview() + mapview::mapview(pp, col.regions = "green")
