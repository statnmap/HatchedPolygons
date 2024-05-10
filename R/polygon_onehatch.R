#' Create one line for hatch area of one polygon
#'
#' @inheritParams graphics::polygon
#'
#' @param ..debug.hatch for drawing when debugging function
#' @param x0 parameter as issued from \code{\link{polygon.fullhatch}}
#' @param y0 parameter as issued from \code{\link{polygon.fullhatch}}
#' @param xd parameter as issued from \code{\link{polygon.fullhatch}}
#' @param yd parameter as issued from \code{\link{polygon.fullhatch}}
#'
#' @importFrom graphics points
#' @importFrom graphics arrows

polygon.onehatch <- function(x, y, x0, y0, xd, yd, ..debug.hatch = FALSE,
                             fillOddEven = FALSE,
                             ...) {
  if (..debug.hatch) {
    graphics::points(x0, y0)
    graphics::arrows(x0, y0, x0 + xd, y0 + yd)
  }
  halfplane <- as.integer(xd * (y - y0) - yd * (x -
                                                  x0) <= 0)
  cross <- halfplane[-1L] - halfplane[-length(halfplane)]
  does.cross <- cross != 0
  if (!any(does.cross))
    return()
  x1 <- x[-length(x)][does.cross]
  y1 <- y[-length(y)][does.cross]
  x2 <- x[-1L][does.cross]
  y2 <- y[-1L][does.cross]
  t <- (((x1 - x0) * (y2 - y1) - (y1 - y0) * (x2 -
                                                x1))/(xd * (y2 - y1) - yd * (x2 - x1)))
  o <- order(t)
  tsort <- t[o]
  crossings <- cumsum(cross[does.cross][o])
  if (fillOddEven)
    crossings <- crossings%%2
  drawline <- crossings != 0
  lx <- x0 + xd * tsort
  ly <- y0 + yd * tsort
  lx1 <- lx[-length(lx)][drawline]
  ly1 <- ly[-length(ly)][drawline]
  lx2 <- lx[-1L][drawline]
  ly2 <- ly[-1L][drawline]
  # segments(lx1, ly1, lx2, ly2, ...)
  # get lines
  data.frame(lx1 = lx1, ly1 = ly1, lx2 = lx2, ly2 = ly2)
}
