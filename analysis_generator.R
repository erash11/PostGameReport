# ====================================================================
# AUTOMATED ANALYSIS TEXT GENERATOR
# ====================================================================
# This file contains functions that automatically generate analysis text
# based on actual game data, replacing hardcoded analysis sections.
# ====================================================================

#' Generate Win Probability Analysis
#'
#' @param win_plot_data Data frame with win probability over time
#' @param opp_name Opponent name
#' @param wp_column Name of the win probability column to analyze
#' @return Character string with analysis
generate_wp_analysis <- function(win_plot_data, opp_name, wp_column) {

  # Calculate key metrics
  avg_wp <- mean(win_plot_data[[wp_column]], na.rm = TRUE)
  max_wp <- max(win_plot_data[[wp_column]], na.rm = TRUE)
  min_wp <- min(win_plot_data[[wp_column]], na.rm = TRUE)

  # Determine momentum
  first_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 30], na.rm = TRUE)
  second_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem <= 30], na.rm = TRUE)

  # Generate text based on data
  if (avg_wp > 0.6) {
    dominance <- "dominated"
  } else if (avg_wp > 0.5) {
    dominance <- "maintained control against"
  } else {
    dominance <- "struggled against"
  }

  if (second_half_wp > first_half_wp + 0.1) {
    momentum <- "gained significant momentum in the second half"
  } else if (first_half_wp > second_half_wp + 0.1) {
    momentum <- "started strong but lost momentum in the second half"
  } else {
    momentum <- "maintained consistent performance throughout"
  }

  paste0(
    "Baylor ", momentum, ". ",
    "The Bears ", dominance, " ", opp_name, ", ",
    "with an average win probability of ", round(avg_wp * 100, 1), "%. ",
    "The win probability peaked at ", round(max_wp * 100, 1), "% and ",
    "dropped to a low of ", round(min_wp * 100, 1), "%."
  )
}

#' Generate Offensive EPA Analysis
#'
#' @param current_game_off_agg Current game offensive stats
#' @param bu_season_off_agg Season average offensive stats
#' @param power_four_off_agg Power 4 average stats
#' @return Character string with analysis
generate_offense_analysis <- function(current_game_off_agg, bu_season_off_agg, power_four_off_agg) {

  # Extract EPAs
  game_pass_epa <- current_game_off_agg$avg_pass_epa[1]
  game_run_epa <- current_game_off_agg$avg_run_epa[1]
  season_pass_epa <- bu_season_off_agg$avg_pass_epa[1]
  season_run_epa <- bu_season_off_agg$avg_run_epa[1]
  p4_pass_epa <- power_four_off_agg$avg_pass_epa[1]
  p4_run_epa <- power_four_off_agg$avg_run_epa[1]

  # Compare to season average
  pass_vs_season <- if(game_pass_epa > season_pass_epa) {
    "exceeded"
  } else {
    "fell short of"
  }

  run_vs_season <- if(game_run_epa > season_run_epa) {
    "exceeded"
  } else {
    "fell short of"
  }

  # Compare to Power 4
  pass_vs_p4 <- if(game_pass_epa > p4_pass_epa) {
    "outperformed"
  } else {
    "underperformed compared to"
  }

  run_vs_p4 <- if(game_run_epa > p4_run_epa) {
    "outperformed"
  } else {
    "underperformed compared to"
  }

  # Overall assessment
  if(game_pass_epa > season_pass_epa && game_run_epa > season_run_epa) {
    overall <- "had an excellent offensive performance"
  } else if(game_pass_epa > season_pass_epa || game_run_epa > season_run_epa) {
    overall <- "had a solid offensive showing"
  } else {
    overall <- "struggled offensively"
  }

  paste0(
    "Baylor ", overall, " with a passing EPA of ", round(game_pass_epa, 3),
    " and a rushing EPA of ", round(game_run_epa, 3), ". ",
    "The passing game ", pass_vs_season, " the season average (",
    round(season_pass_epa, 3), ") and ", pass_vs_p4, " Power 4 teams (",
    round(p4_pass_epa, 3), "). ",
    "The running game ", run_vs_season, " the season average (",
    round(season_run_epa, 3), ") and ", run_vs_p4, " Power 4 teams (",
    round(p4_run_epa, 3), ")."
  )
}

#' Generate Defensive EPA Analysis
#'
#' @param current_game_def_agg Current game defensive stats
#' @param bu_season_def_agg Season average defensive stats
#' @param power_four_def_agg Power 4 average stats
#' @return Character string with analysis
generate_defense_analysis <- function(current_game_def_agg, bu_season_def_agg, power_four_def_agg) {

  # Extract EPAs (negative is better for defense)
  game_pass_epa <- current_game_def_agg$avg_pass_epa_allowed[1]
  game_run_epa <- current_game_def_agg$avg_run_epa_allowed[1]
  season_pass_epa <- bu_season_def_agg$avg_pass_epa_allowed[1]
  season_run_epa <- bu_season_def_agg$avg_run_epa_allowed[1]
  p4_pass_epa <- power_four_def_agg$avg_pass_epa_allowed[1]
  p4_run_epa <- power_four_def_agg$avg_run_epa_allowed[1]

  # Compare (lower is better for defense)
  pass_vs_season <- if(game_pass_epa < season_pass_epa) {
    "improved upon"
  } else {
    "fell short of"
  }

  run_vs_season <- if(game_run_epa < season_run_epa) {
    "improved upon"
  } else {
    "fell short of"
  }

  pass_vs_p4 <- if(game_pass_epa < p4_pass_epa) {
    "performed better than"
  } else {
    "performed worse than"
  }

  run_vs_p4 <- if(game_run_epa < p4_run_epa) {
    "performed better than"
  } else {
    "performed worse than"
  }

  # Overall
  if(game_pass_epa < season_pass_epa && game_run_epa < season_run_epa) {
    overall <- "had a strong defensive performance"
  } else if(game_pass_epa < season_pass_epa || game_run_epa < season_run_epa) {
    overall <- "had a mixed defensive performance"
  } else {
    overall <- "struggled defensively"
  }

  paste0(
    "Baylor ", overall, " with a pass defense EPA of ", round(game_pass_epa, 3),
    " and a run defense EPA of ", round(game_run_epa, 3), ". ",
    "The pass defense ", pass_vs_season, " the season average (",
    round(season_pass_epa, 3), ") and ", pass_vs_p4, " Power 4 teams (",
    round(p4_pass_epa, 3), "). ",
    "The run defense ", run_vs_season, " the season average (",
    round(season_run_epa, 3), ") and ", run_vs_p4, " Power 4 teams (",
    round(p4_run_epa, 3), ")."
  )
}

#' Generate Next Opponent Offensive Analysis
#'
#' @param next_opp_off_agg Next opponent's offensive stats
#' @param power_four_off_agg Power 4 average stats
#' @param next_opp_name Next opponent name
#' @return Character string with analysis
generate_next_opp_offense_analysis <- function(next_opp_off_agg, power_four_off_agg, next_opp_name) {

  # Extract EPAs
  opp_pass_epa <- next_opp_off_agg$avg_pass_epa[1]
  opp_run_epa <- next_opp_off_agg$avg_run_epa[1]
  p4_pass_epa <- power_four_off_agg$avg_pass_epa[1]
  p4_run_epa <- power_four_off_agg$avg_run_epa[1]

  # Compare to Power 4
  pass_comparison <- if(opp_pass_epa > p4_pass_epa) {
    paste0("above the Power 4 average (", round(p4_pass_epa, 3), ")")
  } else {
    paste0("below the Power 4 average (", round(p4_pass_epa, 3), ")")
  }

  run_comparison <- if(opp_run_epa > p4_run_epa) {
    paste0("above the Power 4 average (", round(p4_run_epa, 3), ")")
  } else {
    paste0("below the Power 4 average (", round(p4_run_epa, 3), ")")
  }

  # Determine strength
  if(opp_pass_epa > p4_pass_epa && opp_run_epa > p4_run_epa) {
    strength <- "poses a significant offensive threat"
  } else if(opp_pass_epa > p4_pass_epa || opp_run_epa > p4_run_epa) {
    strength <- "has shown offensive capabilities in certain areas"
  } else {
    strength <- "has struggled offensively compared to conference peers"
  }

  paste0(
    next_opp_name, " ", strength, ". ",
    "Their passing offense has an EPA of ", round(opp_pass_epa, 3), ", ",
    pass_comparison, ". ",
    "Their rushing offense has an EPA of ", round(opp_run_epa, 3), ", ",
    run_comparison, "."
  )
}

#' Generate Next Opponent Defensive Analysis
#'
#' @param next_opp_def_agg Next opponent's defensive stats
#' @param power_four_def_agg Power 4 average stats
#' @param next_opp_name Next opponent name
#' @return Character string with analysis
generate_next_opp_defense_analysis <- function(next_opp_def_agg, power_four_def_agg, next_opp_name) {

  # Extract EPAs (negative is better for defense)
  opp_pass_epa <- next_opp_def_agg$avg_pass_epa_allowed[1]
  opp_run_epa <- next_opp_def_agg$avg_run_epa_allowed[1]
  p4_pass_epa <- power_four_def_agg$avg_pass_epa_allowed[1]
  p4_run_epa <- power_four_def_agg$avg_run_epa_allowed[1]

  # Compare to Power 4 (lower is better)
  pass_comparison <- if(opp_pass_epa < p4_pass_epa) {
    paste0("better than the Power 4 average (", round(p4_pass_epa, 3), ")")
  } else {
    paste0("worse than the Power 4 average (", round(p4_pass_epa, 3), ")")
  }

  run_comparison <- if(opp_run_epa < p4_run_epa) {
    paste0("better than the Power 4 average (", round(p4_run_epa, 3), ")")
  } else {
    paste0("worse than the Power 4 average (", round(p4_run_epa, 3), ")")
  }

  # Determine strength
  if(opp_pass_epa < p4_pass_epa && opp_run_epa < p4_run_epa) {
    strength <- "has a formidable defense"
  } else if(opp_pass_epa < p4_pass_epa || opp_run_epa < p4_run_epa) {
    strength <- "has shown defensive strength in certain areas"
  } else {
    strength <- "has defensive vulnerabilities that can be exploited"
  }

  paste0(
    next_opp_name, " ", strength, ". ",
    "Their pass defense allows an EPA of ", round(opp_pass_epa, 3), ", ",
    pass_comparison, ". ",
    "Their run defense allows an EPA of ", round(opp_run_epa, 3), ", ",
    run_comparison, "."
  )
}
