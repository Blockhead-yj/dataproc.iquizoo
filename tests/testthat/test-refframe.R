set.seed(1)
data <- tidyr::expand_grid(
  id = seq_len(100),
  tibble(
    Type = c("Allocentric", "Egocentric"),
    n = 15
  )
) %>%
  tidyr::uncount(n) %>%
  dplyr::mutate(Dist = runif(dplyr::n(), 0, 200))

test_that("Default behavior works", {
  expect_snapshot(preproc_data(data, refframe, by = "id"))
})

test_that("Works with multiple grouping variables", {
  data <- dplyr::mutate(data, id1 = id + 1)
  expect_snapshot(preproc_data(data, refframe, by = c("id", "id1")))
})
