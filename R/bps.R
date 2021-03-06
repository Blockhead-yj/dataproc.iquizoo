#' Behavioral Pattern Separation (BPS) task
#'
#' This function mainly calculates the "*BPS score*" developed by Stark et. al.
#' (2013).
#'
#' @templateVar by low
#' @templateVar vars_input TRUE
#' @template params-template
#' @return A [tibble][tibble::tibble-package] contains following values:
#'   \item{pc}{Percent of correct responses.}
#'   \item{p_sim_foil}{Percent of similar responses for "foil" stimuli.}
#'   \item{p_sim_lure}{Percent of similar responses for "lure" stimuli.}
#'   \item{p_sim_target}{Percent of similar responses for "target" stimuli.}
#'   \item{bps_score}{BPS score.}
#' @export
bps <- function(data, by, vars_input) {
  data_cor <- data %>%
    dplyr::filter(tolower(.data[[vars_input[["name_phase"]]]]) == "test")
  pc_all <- data_cor %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) %>%
    dplyr::summarise(
      pc = mean(.data[[vars_input[["name_acc"]]]] == 1),
      .groups = "drop"
    )
  bps_score <- data_cor %>%
    dplyr::group_by(dplyr::across(
      dplyr::all_of(c(by, vars_input[["name_type"]]))
    )) %>%
    dplyr::summarise(
      p_sim = mean(tolower(.data[[vars_input[["name_resp"]]]]) == "similar")
    ) %>%
    tidyr::pivot_wider(
      names_from = .data[[vars_input[["name_type"]]]],
      names_prefix = "p_sim_",
      values_from = "p_sim"
    ) %>%
    dplyr::mutate(bps_score = .data[["p_sim_lure"]] - .data[["p_sim_foil"]])
  dplyr::left_join(pc_all, bps_score, by = by)
}
