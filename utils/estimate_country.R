library(sf)
library(rnaturalearth)

sf_use_s2(FALSE)

countries <- ne_countries(returnclass = "sf")
countries <- st_make_valid(countries)

# # Example coordinates
# longitude <- 21.0122  # Longitude for Warsaw, Poland
# latitude <- 52.2297   # Latitude for Warsaw, Poland
# 
# # Retrieve the country name
# country_name <- get_country_from_coords(longitude, latitude)
# 
# # Display the result
# print(country_name)


get_country_from_coords <- function(lon, lat){
  point <- st_as_sf(data.frame(lon = lon, lat = lat),
                    coords = c("lon", "lat"),
                    crs = 4326)
  matched <- suppressWarnings(st_join(point, countries))
  
  if (!is.null(matched$name) && !is.na(matched$name)) {
    return(matched$iso_a2)
  } else {
    return(NA)
  }
}


