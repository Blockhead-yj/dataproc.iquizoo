# prepare data
set.seed(1)
data <- tidyr::expand_grid(
  id = 1:100,
  Block = 1:8
) %>%
  dplyr::mutate(n = sample(0:50, dplyr::n(), replace = TRUE)) %>%
  tidyr::uncount(n, .id = "Trial") %>%
  dplyr::mutate(
    StimType = sample(
      c("Incongruent", "Congruent"),
      dplyr::n(),
      replace = TRUE
    ),
    Task = dplyr::case_when(
      Block %in% c(1, 8) ~ "T1",
      Block %in% c(2, 7) ~ "T2",
      TRUE ~ sample(c("T1", "T2"), dplyr::n(), replace = TRUE)
    ),
    ACC = sample(c(0, 1), dplyr::n(), replace = TRUE),
    RT = rexp(dplyr::n(), 0.001)
  ) %>%
  tidyr::complete(
    Block, tidyr::nesting(id),
    fill = list(
      Trial = 1,
      StimType = "Congruent",
      Task = "T1",
      ACC = -1,
      RT = 0
    )
  ) %>%
  dplyr::mutate(
    TaskType = dplyr::case_when(
      Block %in% c(1:2, 7:8) ~ "Pure",
      Trial == 1 ~ "Filler",
      Task == dplyr::lag(Task) ~ "Repeat",
      TRUE ~ "Switch"
    )
  )
data_miss_cond <- tibble(
  id = rep(1:2, each = 8),
  Block = rep(1:8, 2),
  StimType = "Incongruent",
  Task = "T1",
  TaskType = rep(c(rep("Pure", 2), rep("Repeat", 4), rep("Pure", 2)), 2),
  ACC = sample(c(0, 1), 16, replace = TRUE),
  RT = rexp(16, 0.001)
)
data_part_miss_cond <- tibble(
  id = rep(1:2, each = 8),
  Block = rep(1:8, 2),
  StimType = c(
    rep("Incongruent", 8),
    rep("Incongruent", 4),
    rep("Congruent", 4)
  ),
  Task = "T1",
  TaskType = c(
    c(rep("Pure", 2), rep("Repeat", 4), rep("Pure", 2)),
    c(rep("Pure", 2), rep("Repeat", 2), rep("Switch", 2), rep("Pure", 2))
  ),
  ACC = sample(c(0, 1), 16, replace = TRUE),
  RT = rexp(16, 0.001)
)

test_that("Default behavior works", {
  expect_snapshot(preproc_data(data, complexswitch, by = "id"))
})

test_that("All single condition", {
  expect_snapshot(preproc_data(data_miss_cond, complexswitch, by = "id"))
})

test_that("Part subject single condition", {
  expect_snapshot(preproc_data(data_part_miss_cond, complexswitch, by = "id"))
})

test_that("Works with multiple grouping variables", {
  data <- dplyr::mutate(data, id1 = id + 1)
  expect_snapshot(preproc_data(data, complexswitch, by = c("id", "id1")))
})
