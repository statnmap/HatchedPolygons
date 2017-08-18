## ----LibraryInstall------------------------------------------------------
# devtools::install_github("statnmap/HatchedPolygons")
# vignette("leaflet_shading_polygon", package = "HatchedPolygons")
# x.hatch <- hatched.SpatialPolygons(x, density = c(60, 90), angle = c(45, 135))

## ----SimplePolygon, message = FALSE--------------------------------------
library(HatchedPolygons)
library(dplyr)
library(sp)
library(sf)
library(raster)
# library(HatchedPolygons)

# Create two polygons: second would be a hole inside the first
xy = cbind(
  x = c(13.4, 13.4, 13.6, 13.6, 13.4),
  y = c(48.9, 49, 49, 48.9, 48.9)
    )
hole.xy <- cbind(
  x = c(13.5, 13.5, 13.45, 13.45, 13.5),
  y = c(48.98, 48.92, 48.92, 48.98, 48.98)
  )

par(bg = "white", mar = c(2, 2, 0.5, 0.5))
plot(xy)
polygon(xy, density = 5, lwd = 2, col = "grey20")
polygon(hole.xy, density = 5, lwd = 2, angle = -45, col = "blue")


## ------------------------------------------------------------------------
# Transform as SpatialPolygon to plot
xy.sp <- SpatialPolygons(list(
  Polygons(list(Polygon(xy), 
                Polygon(hole.xy, hole = TRUE)), "1"),
  Polygons(list(Polygon(hole.xy + 0.2, hole = TRUE),
    Polygon(xy + 0.2),
                Polygon(xy + 0.35)
                ), "2")
  ))

par(bg = "lightblue", mar = c(2, 2, 0.5, 0.5)) # default
plot(xy.sp, density = 10, col = c("red", "blue"), lwd = 2)

# Let's define a raster to be used as background
r <- raster(nrows = 50, ncols = 50)
extent(r) <- extent(xy.sp)
r <- setValues(r, 1:ncell(r))

# Draw again polygons with holes
par(bg = "lightblue", mar = c(2, 2, 0.5, 0.5))
image(r, col = rev(terrain.colors(50)))
plot(xy.sp, density = 10, col = c("red", "blue"), lwd = 2, add = TRUE)


## ----HatchedPolygon------------------------------------------------------
# Allows for different hatch densities and directions for each polygon
xy.sp.hatch <- hatched.SpatialPolygons(xy.sp, density = c(40, 60), angle = c(45, 135))
xy.sp.hatch

# Draw again polygons with holes
par(bg = "lightblue", mar = c(2, 2, 0.5, 0.5))
image(r, col = rev(terrain.colors(50)))
plot(xy.sp, col = c("blue", "red"), add = TRUE)
plot(xy.sp.hatch, col = c("cyan", "grey90")[as.numeric(xy.sp.hatch$ID)],
     lwd = 3, add = TRUE)


## ----Leaflet-------------------------------------------------------------
library(leaflet)

m <- leaflet() %>%
  addTiles(
    urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
          addPolygons(data = xy.sp, 
                    fillColor = c("transparent", "red"),
                    color = "#000000", 
                    opacity = 1, 
                    fillOpacity = 0.6, 
                    stroke = TRUE,
                    weight = 1.5
        ) %>%
  addPolylines(data = xy.sp.hatch,
               color = c("blue", "#FFF")[as.numeric(xy.sp.hatch$ID)])

# Save the map ----
# htmlwidgets::saveWidget(m, file = "Hatched_Polygon_Leaflet_alone.html")

m

## ---- message = FALSE----------------------------------------------------
library(ggplot2)
# Transform SpatialObject to be used by ggplot2
xy.sp.l <- broom::tidy(xy.sp)
xy.sp.hatch.l <- broom::tidy(xy.sp.hatch) %>%
  tidyr::separate(id, into = c("id", "SubPoly"))

ggplot(xy.sp.l) +
  geom_polygon(aes(x = long, y = lat, group = group, col = id), 
               fill = "transparent", size = 1.5) +
  geom_line(data = xy.sp.hatch.l, 
            aes(x = long, y = lat, group = group, col = id),
            size = 1) +
  guides(col = FALSE)
  
# http://stackoverflow.com/questions/12047643/geom-polygon-with-multiple-hole/12051278#12051278
# ggplot(xy.sp.l) +
#   geom_polygon(aes(x = long, y = lat, group = id, fill = id))


## ------------------------------------------------------------------------
# Transform as sf objects
xy.sp.hatch.sf <- sf::st_as_sf(xy.sp.hatch)
xy.sp.sf <- sf::st_as_sf(xy.sp)

# Create leaflet widget --------------------------------------------------------
m <- leaflet() %>%
  addTiles(
    urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
          addPolygons(data = xy.sp.sf, 
                    fillColor = c("transparent", "red"),
                    color = "#000000", 
                    opacity = 1, 
                    fillOpacity = 0.6, 
                    stroke = TRUE,
                    weight = 1.5
        ) %>%
  addPolylines(data = xy.sp.hatch.sf,
               color = c("blue", "#FFF")[as.numeric(xy.sp.hatch.sf$ID)])

m

