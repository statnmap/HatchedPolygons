#' Return a SpatialLinesDataframe as hatched area for a SpatialPolygons
#'
#' @inheritParams graphics::polygon
#' @param x SpatialPolygons* from library sp
#' @import sp
#' @importFrom methods is as
#' @importFrom methods slot
#' @importFrom sf st_is
#' @importFrom sf st_as_sf
#'
#' @export

hatched.SpatialPolygons <-
  function(x,
           density = 10, angle = 45,
           fillOddEven = FALSE) {
    
    type <- NULL
    
    
    if (is(x, "SpatialPolygons")) {
      n <- length(slot(x, "polygons"))
      polys <- slot(x, "polygons")
      pO <- slot(x, "plotOrder")
      type <- "sp"
    } else if (st_is(x, c("POLYGON", "MULTIPOLYGON"))[1]) {
      # n <- length(x)
      # To do
      x <- as(x, "Spatial")
      n <- length(slot(x, "polygons"))
      polys <- slot(x, "polygons")
      pO <- slot(x, "plotOrder")
      type <- "sf"
    } else {
      stop("Not a sp::SpatialPolygons or sf::*POLYGON object")
    }
    
    
    if (length(density) != n)
      density <- rep(density, n, n)
    if (length(angle) != n)
      angle <- rep(angle, n, n)
    all.Lines <- list()
    all.Lines.ID <- numeric(0)
    
    for (j in pO) {
      all.Lines.tmp <- polygonRingHolesLines(
        polys[[j]],
        density = density[j], angle = angle[j],
        ID = polys[[j]]@ID,
        fillOddEven = fillOddEven
      )
      if(length(all.Lines.tmp)==0)
        next()
      
      all.Lines.ID <- c(all.Lines.ID, rep(polys[[j]]@ID, length(all.Lines.tmp)))
      all.Lines[length(all.Lines) + 1:length(all.Lines.tmp)] <- all.Lines.tmp
    }
    # Correct ID
    SpatialLinesDF <- SpatialLinesDataFrame(
      SpatialLines(all.Lines),
      data = data.frame(ID = all.Lines.ID),
      match.ID = FALSE)
    
    if (type == "sf") {
      SpatialLinesDF_sf <- st_as_sf(SpatialLinesDF)
      return(SpatialLinesDF_sf)
    } else {
      return(SpatialLinesDF)
    }
  }