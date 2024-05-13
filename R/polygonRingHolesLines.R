#' Get SpatialLines of one Polygons feature
#'
#' @inheritParams graphics::polygon
#' @param Sr An object of class Polygons
#' @param ID Number or string identifying the Polygon inside Polygons
#'
#' @import sp
#' @importFrom methods as
#' @importFrom methods is
#' @importFrom methods slot
#' @importFrom sf st_intersection
#' @importFrom sf st_as_sfc

polygonRingHolesLines <- function(Sr,
                                  density = 0.5,
                                  angle = 45,
                                  ID = 1,
                                  fillOddEven = FALSE) {
  if (!is(Sr, "Polygons"))
    stop("Not an Polygons object")
  
  if (!is.null(density)) hatch <- TRUE
  else hatch <- FALSE
  pO <- slot(Sr, "plotOrder")
  polys <- slot(Sr, "Polygons")
  
  if (hatch) {
    all.Lines <- list()
    for (i in pO) {
      if (!slot(polys[[i]], "hole")) {
        # Transform polygon as parallel lines
        lines.hatch <- polygon.fullhatch(slot(polys[[i]], "coords"),
                                         density = density, angle = angle, fillOddEven = fillOddEven)
        
        if(length(lines.hatch)==0)
        {
          warning("Polygon too small to contain any lines.  Consider increasing 'density'.")
          next()
        }

        # Transform as SpatialLines
        Lines.i <- SpatialLines(list(Lines(
          apply(lines.hatch, 1,
                function(x) Line(cbind(c(x[1], x[3]), c(x[2], x[4])))),
          ID = i)))
        
        # Clean Lines if over a "hole"
        #
        # Lines.i.holes <- rgeos::gIntersection(Lines.i, SpatialPolygons(list(Sr)),
        #                                       drop_lower_td = TRUE)
        Lines.i.holes <- st_intersection(
          Lines.i  |> st_as_sfc(), 
          SpatialPolygons(list(Sr)) |> st_as_sfc()
        ) |> as("Spatial")
                
        if (!is.null(Lines.i.holes)) {
          Lines.i.holes@lines[[1]]@ID <- paste0(ID, ".", i)
          all.Lines[[length(all.Lines) + 1]] <- Lines.i.holes@lines[[1]]
        }
      }
    }
  }
  return(all.Lines)
}

