set.seed(1)
n_subject <- 100
data <- tidyr::expand_grid(
  id = seq_len(n_subject),
  YellowDur = runif(8, 3000, 15000)
) %>%
  dplyr::mutate(
    StillDurList = purrr::map(
      YellowDur,
      ~ {
        repeat {
          n <- sample(1:10, 1)
          dur <- rexp(n, 0.001)
          if (sum(dur) < .x) break
        }
        round(dur)
      }
    ),
    StillDur = purrr::map_chr(
      StillDurList,
      ~ stringr::str_c(.x, collapse = "-")
    ),
    StillLight = purrr::map_chr(
      StillDurList,
      ~ sample(c("Yellow", "Green"), length(.x), replace = TRUE) %>%
        stringr::str_c(collapse = "-")
    )
  ) %>%
  dplyr::select(-StillDurList)
# some rare cases produce negative durations by error
data_negtive_dur <- tibble(
  id = 1,
  YellowDur = runif(8, 3000, 15000)
) %>%
  dplyr::mutate(
    StillDurList = purrr::map(
      YellowDur,
      ~ {
        repeat {
          n <- sample(1:10, 1)
          dur <- runif(n, -500, 1000)
          if (sum(dur) < .x) break
        }
        round(dur)
      }
    ),
    StillDur = purrr::map_chr(
      StillDurList,
      ~ stringr::str_c(.x, collapse = "-")
    ),
    StillLight = purrr::map_chr(
      StillDurList,
      ~ sample(c("Yellow", "Green"), length(.x), replace = TRUE) %>%
        stringr::str_c(collapse = "-")
    )
  ) %>%
  dplyr::select(-StillDurList)


test_that("Default behavior works", {
  expect_snapshot(preproc_data(data, driving, by = "id"))
})

test_that("Works with multiple grouping variables", {
  data <- dplyr::mutate(data, id1 = id + 1)
  expect_snapshot(preproc_data(data, driving, by = c("id", "id1")))
})

test_that("No error for negative duration case (but produces `NA`s)", {
  expect_snapshot(preproc_data(data_negtive_dur, driving, by = "id"))
})
