# library(rgl)
# library(future)
#
# tck <- read_fascicles("~/Downloads/laf_m_sub.tck")
# plan(multisession)
# tckc <- tck %>%
#   tidyr::nest(data = -StreamlineId) %>%
#   dplyr::mutate(data = furrr::future_map(
#     .x = data,
#     .f = rtists:::color_by_orientation,
#     .progress = TRUE
#   )) %>%
#   tidyr::unnest(cols = data)
# plan(sequential)
#
# aspect3d(4, 2.5, 1)
# axes3d()
#
# tckc %>%
#   tidyr::nest(data = -StreamlineId) %>%
#   pull(data) %>%
#   furrr::future_walk(~ {
#     lines3d(.x$X, .x$Y, .x$Z, col = .x$PointColor)
#   })
#
#
# # Approche reduc nb fibres ------------------------------------------------
#
# tck <- read_fascicles("~/Downloads/laf_m_sub.tck")
# tckn <- tck %>%
#   nest(StreamlineData = -StreamlineId)
# n <- nrow(tckn)
# d <- crossing(i = 1:n, j = 1:n) %>%
#   filter(i < j)
# spatial_dist <- function(s1, s2) {
#   sqrt(mean((s1$X - s2$X)^2 + (s1$Y - s2$Y)^2 + (s1$Z - s2$Z)^2))
# }
# library(future)
# plan(multisession, workers = 4)
# d <- d %>%
#   mutate(spatial_dist = furrr::future_map2_dbl(
#     i, j, ~ spatial_dist(
#       tckn$StreamlineData[[.x]],
#       tckn$StreamlineData[[.y]]
#     ), .progress = TRUE
#   ))
# plan(sequential)
