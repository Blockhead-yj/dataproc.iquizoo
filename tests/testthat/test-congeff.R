set.seed(1)
n_subject <- 100
data <- tidyr::expand_grid(
  id = seq_len(n_subject),
  n = sample(0:60, n_subject, replace = TRUE)
) %>%
  tidyr::uncount(n, .id = "Trial") %>%
  dplyr::mutate(
    Type = sample(
      c("Incongruent", "Congruent"),
      dplyr::n(),
      replace = TRUE
    ),
    ACC = sample(c(0, 1), dplyr::n(), replace = TRUE),
    RT = rexp(dplyr::n(), 0.001)
  )
data_miss_cond <- tibble(
  id = rep(1:2, each = 8),
  Type = "Incongruent",
  ACC = sample(c(0, 1), 16, replace = TRUE),
  RT = rexp(16, 0.001)
)
data_part_miss_cond <- tibble(
  id = rep(1:2, each = 8),
  Type = c(
    rep("Incongruent", 8),
    rep("Incongruent", 4),
    rep("Congruent", 4)
  ),
  ACC = sample(c(0, 1), 16, replace = TRUE),
  RT = rexp(16, 0.001)
)

test_that("Default behavior works", {
  expect_snapshot(preproc_data(data, congeff, by = "id"))
})

test_that("All single condition", {
  expect_snapshot(preproc_data(data_miss_cond, congeff, by = "id"))
})

test_that("Part subject single condition", {
  expect_snapshot(preproc_data(data_part_miss_cond, congeff, by = "id"))
})

test_that("Works with multiple grouping variables", {
  data <- dplyr::mutate(data, id1 = id + 1)
  expect_snapshot(preproc_data(data, congeff, by = c("id", "id1")))
})
