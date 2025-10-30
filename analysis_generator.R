# ====================================================================
# AUTOMATED ANALYSIS TEXT GENERATOR - ENHANCED FOR COACHES
# ====================================================================
# This file contains functions that automatically generate analysis text
# based on actual game data, with coaching-relevant insights including:
# - Momentum shifts and critical moments
# - Situational performance (3rd down, red zone)
# - Game-changing plays (turnovers, explosive plays)
# - Success rates and efficiency metrics
# ====================================================================

#' Generate Win Probability Analysis with Momentum Insights
#'
#' @param win_plot_data Data frame with win probability over time
#' @param opp_name Opponent name
#' @param wp_column Name of the win probability column to analyze
#' @param current_game_data Raw play-by-play data for additional context
#' @return Character string with analysis
generate_wp_analysis <- function(win_plot_data, opp_name, wp_column, current_game_data = NULL) {

  # Calculate key metrics
  avg_wp <- mean(win_plot_data[[wp_column]], na.rm = TRUE)
  max_wp <- max(win_plot_data[[wp_column]], na.rm = TRUE)
  min_wp <- min(win_plot_data[[wp_column]], na.rm = TRUE)

  # Analyze quarter-by-quarter performance
  q1_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 45], na.rm = TRUE)
  q2_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 30 & win_plot_data$game_mins_rem <= 45], na.rm = TRUE)
  q3_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 15 & win_plot_data$game_mins_rem <= 30], na.rm = TRUE)
  q4_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem <= 15], na.rm = TRUE)

  quarters <- c(q1_wp, q2_wp, q3_wp, q4_wp)
  best_quarter <- which.max(quarters)
  worst_quarter <- which.min(quarters)

  # Identify momentum shifts
  wp_data <- win_plot_data %>%
    arrange(desc(game_mins_rem)) %>%
    mutate(wp_change = c(0, diff(!!sym(wp_column))))

  biggest_swing_idx <- which.max(wp_data$wp_change)
  biggest_swing_time <- wp_data$game_mins_rem[biggest_swing_idx]
  biggest_swing_value <- wp_data$wp_change[biggest_swing_idx]

  # Determine overall momentum
  first_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 30], na.rm = TRUE)
  second_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem <= 30], na.rm = TRUE)

  if (second_half_wp > first_half_wp + 0.1) {
    momentum <- "gained significant momentum in the second half"
  } else if (first_half_wp > second_half_wp + 0.1) {
    momentum <- "started strong but lost momentum in the second half"
  } else {
    momentum <- "maintained consistent performance throughout"
  }

  # Determine dominance
  if (avg_wp > 0.65) {
    dominance <- "dominated"
  } else if (avg_wp > 0.55) {
    dominance <- "controlled"
  } else if (avg_wp > 0.45) {
    dominance <- "competed evenly with"
  } else {
    dominance <- "struggled against"
  }

  # Build analysis text
  base_text <- paste0(
    "**Game Flow:** Baylor ", momentum, ", ", dominance, " ", opp_name,
    " with an average win probability of ", round(avg_wp * 100, 1), "%. ",
    "Win probability peaked at ", round(max_wp * 100, 1), "% and ",
    "dropped to a low of ", round(min_wp * 100, 1), "%. "
  )

  quarter_text <- paste0(
    "**Quarterly Performance:** Q", best_quarter, " was the strongest quarter (",
    round(quarters[best_quarter] * 100, 1), "% avg), ",
    if(best_quarter != worst_quarter) {
      paste0("while Q", worst_quarter, " needs improvement (",
             round(quarters[worst_quarter] * 100, 1), "% avg). ")
    } else {
      "with consistent execution across all quarters. "
    }
  )

  momentum_text <- if(biggest_swing_value > 0.1) {
    paste0(
      "**Critical Moment:** The biggest momentum shift occurred around ",
      round(biggest_swing_time, 0), " minutes remaining, gaining ",
      round(biggest_swing_value * 100, 1), "% win probability. "
    )
  } else { "" }

  paste0(base_text, quarter_text, momentum_text)
}

#' Generate Offensive EPA Analysis with Situational Performance
#'
#' @param current_game_off_agg Current game offensive stats
#' @param bu_season_off_agg Season average offensive stats
#' @param power_four_off_agg Power 4 average stats
#' @param current_game_off_data Raw offensive play-by-play data
#' @return Character string with analysis
generate_offense_analysis <- function(current_game_off_agg, bu_season_off_agg, power_four_off_agg, current_game_off_data = NULL) {

  # Extract EPAs
  game_pass_epa <- current_game_off_agg$avg_pass_epa[1]
  game_run_epa <- current_game_off_agg$avg_run_epa[1]
  season_pass_epa <- bu_season_off_agg$avg_pass_epa[1]
  season_run_epa <- bu_season_off_agg$avg_run_epa[1]
  p4_pass_epa <- power_four_off_agg$avg_pass_epa[1]
  p4_run_epa <- power_four_off_agg$avg_run_epa[1]

  # Extract success rates
  game_pass_sr <- current_game_off_agg$success_rate_pass[1]
  game_run_sr <- current_game_off_agg$success_rate_run[1]
  season_pass_sr <- bu_season_off_agg$success_rate_pass[1]
  season_run_sr <- bu_season_off_agg$success_rate_run[1]

  # Overall assessment
  if(game_pass_epa > season_pass_epa && game_run_epa > season_run_epa) {
    overall <- "had an excellent offensive performance"
  } else if(game_pass_epa > season_pass_epa || game_run_epa > season_run_epa) {
    overall <- "had a solid offensive showing"
  } else {
    overall <- "struggled offensively"
  }

  # Build EPA comparison text
  epa_text <- paste0(
    "**EPA Performance:** Baylor ", overall, " with passing EPA of ", round(game_pass_epa, 3),
    " (", if(game_pass_epa > season_pass_epa) "↑" else "↓", " vs season ",
    round(season_pass_epa, 3), ") and rushing EPA of ", round(game_run_epa, 3),
    " (", if(game_run_epa > season_run_epa) "↑" else "↓", " vs season ",
    round(season_run_epa, 3), "). "
  )

  # Success rate analysis
  efficiency_text <- paste0(
    "**Efficiency:** Pass success rate of ", round(game_pass_sr * 100, 1), "% (",
    if(game_pass_sr > season_pass_sr) "↑" else "↓", " vs season ",
    round(season_pass_sr * 100, 1), "%). Run success rate of ",
    round(game_run_sr * 100, 1), "% (",
    if(game_run_sr > season_run_sr) "↑" else "↓", " vs season ",
    round(season_run_sr * 100, 1), "%). "
  )

  # Situational analysis (if raw data available)
  situational_text <- ""
  if (!is.null(current_game_off_data)) {
    # 3rd down analysis
    third_down_data <- current_game_off_data %>%
      filter(down == 3, !is.na(success)) %>%
      summarise(
        third_down_conv_rate = mean(success, na.rm = TRUE),
        third_down_attempts = n()
      )

    # Red zone analysis
    red_zone_data <- current_game_off_data %>%
      filter(yardline_100 <= 20, !is.na(EPA)) %>%
      summarise(
        red_zone_plays = n(),
        red_zone_epa = mean(EPA, na.rm = TRUE)
      )

    # Explosive plays
    explosive_plays <- current_game_off_data %>%
      filter(!is.na(yards_gained)) %>%
      filter((r_p == 'Pass' & yards_gained >= 20) | (r_p == 'Run' & yards_gained >= 10)) %>%
      nrow()

    total_plays <- current_game_off_data %>% filter(!is.na(r_p)) %>% nrow()
    explosive_rate <- if(total_plays > 0) explosive_plays / total_plays else 0

    if (third_down_data$third_down_attempts > 0 || red_zone_data$red_zone_plays > 0) {
      situational_text <- paste0(
        "**Key Situations:** ",
        if(third_down_data$third_down_attempts > 0) {
          paste0("3rd down conversions: ", round(third_down_data$third_down_conv_rate * 100, 1), "%. ")
        } else { "" },
        if(red_zone_data$red_zone_plays > 0) {
          paste0("Red zone EPA: ", round(red_zone_data$red_zone_epa, 3), ". ")
        } else { "" },
        if(total_plays > 0) {
          paste0("Explosive plays: ", explosive_plays, " (", round(explosive_rate * 100, 1), "%).")
        } else { "" }
      )
    }
  }

  paste0(epa_text, efficiency_text, situational_text)
}

#' Generate Defensive EPA Analysis with Game-Changing Plays
#'
#' @param current_game_def_agg Current game defensive stats
#' @param bu_season_def_agg Season average defensive stats
#' @param power_four_def_agg Power 4 average stats
#' @param current_game_def_data Raw defensive play-by-play data
#' @return Character string with analysis
generate_defense_analysis <- function(current_game_def_agg, bu_season_def_agg, power_four_def_agg, current_game_def_data = NULL) {

  # Extract EPAs (negative is better for defense)
  game_pass_epa <- current_game_def_agg$avg_pass_epa_allowed[1]
  game_run_epa <- current_game_def_agg$avg_run_epa_allowed[1]
  season_pass_epa <- bu_season_def_agg$avg_pass_epa_allowed[1]
  season_run_epa <- bu_season_def_agg$avg_run_epa_allowed[1]
  p4_pass_epa <- power_four_def_agg$avg_pass_epa_allowed[1]
  p4_run_epa <- power_four_def_agg$avg_run_epa_allowed[1]

  # Extract success rates
  game_pass_sr_allowed <- current_game_def_agg$success_rate_allowed_pass[1]
  game_run_sr_allowed <- current_game_def_agg$success_rate_allowed_run[1]
  season_pass_sr_allowed <- bu_season_def_agg$success_rate_allowed_pass[1]
  season_run_sr_allowed <- bu_season_def_agg$success_rate_allowed_run[1]

  # Overall assessment
  if(game_pass_epa < season_pass_epa && game_run_epa < season_run_epa) {
    overall <- "had a strong defensive performance"
  } else if(game_pass_epa < season_pass_epa || game_run_epa < season_run_epa) {
    overall <- "had a mixed defensive performance"
  } else {
    overall <- "struggled defensively"
  }

  # Build EPA text
  epa_text <- paste0(
    "**EPA Allowed:** Baylor ", overall, " with pass defense EPA of ", round(game_pass_epa, 3),
    " (", if(game_pass_epa < season_pass_epa) "↑ improved" else "↓", " vs season ",
    round(season_pass_epa, 3), ") and run defense EPA of ", round(game_run_epa, 3),
    " (", if(game_run_epa < season_run_epa) "↑ improved" else "↓", " vs season ",
    round(season_run_epa, 3), "). "
  )

  # Success rate analysis
  efficiency_text <- paste0(
    "**Opponent Success Rate:** ", round(game_pass_sr_allowed * 100, 1), "% passing allowed (",
    if(game_pass_sr_allowed < season_pass_sr_allowed) "↑ improvement" else "↓",
    " vs season ", round(season_pass_sr_allowed * 100, 1), "%). ",
    round(game_run_sr_allowed * 100, 1), "% rushing allowed (",
    if(game_run_sr_allowed < season_run_sr_allowed) "↑ improvement" else "↓",
    " vs season ", round(season_run_sr_allowed * 100, 1), "%). "
  )

  # Game-changing plays (if raw data available)
  impact_text <- ""
  if (!is.null(current_game_def_data)) {
    # Turnovers
    turnovers <- current_game_def_data %>%
      filter(!is.na(turnover), turnover == TRUE) %>%
      nrow()

    # 3rd down stops
    third_down_def <- current_game_def_data %>%
      filter(down == 3, !is.na(success)) %>%
      summarise(
        third_down_stops = mean(!success, na.rm = TRUE),
        third_down_attempts = n()
      )

    # Big plays allowed
    big_plays_allowed <- current_game_def_data %>%
      filter(!is.na(yards_gained)) %>%
      filter((r_p == 'Pass' & yards_gained >= 20) | (r_p == 'Run' & yards_gained >= 10)) %>%
      nrow()

    impact_parts <- c()

    if (turnovers > 0) {
      impact_parts <- c(impact_parts, paste0(turnovers, " turnover", if(turnovers > 1) "s" else "", " forced"))
    }

    if (third_down_def$third_down_attempts > 0) {
      impact_parts <- c(impact_parts, paste0("3rd down stops: ", round(third_down_def$third_down_stops * 100, 1), "%"))
    }

    if (big_plays_allowed > 0) {
      impact_parts <- c(impact_parts, paste0(big_plays_allowed, " big play", if(big_plays_allowed > 1) "s" else "", " allowed"))
    }

    if (length(impact_parts) > 0) {
      impact_text <- paste0("**Game Impact:** ", paste(impact_parts, collapse = ", "), ". ")
    }
  }

  paste0(epa_text, efficiency_text, impact_text)
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

  # Success rates
  opp_pass_sr <- next_opp_off_agg$success_rate_pass[1]
  opp_run_sr <- next_opp_off_agg$success_rate_run[1]

  # Determine strengths
  pass_strength <- if(opp_pass_epa > p4_pass_epa) "above average" else "below average"
  run_strength <- if(opp_run_epa > p4_run_epa) "above average" else "below average"

  # Overall threat level
  if(opp_pass_epa > p4_pass_epa && opp_run_epa > p4_run_epa) {
    threat <- "poses a significant offensive threat with a balanced attack"
  } else if(opp_pass_epa > p4_pass_epa) {
    threat <- "relies heavily on their passing game"
  } else if(opp_run_epa > p4_run_epa) {
    threat <- "features a strong running game"
  } else {
    threat <- "has struggled offensively compared to conference peers"
  }

  # Build text
  paste0(
    "**Offensive Profile:** ", next_opp_name, " ", threat, ". ",
    "Passing EPA: ", round(opp_pass_epa, 3), " (", pass_strength, ", ",
    round(opp_pass_sr * 100, 1), "% success rate). ",
    "Rushing EPA: ", round(opp_run_epa, 3), " (", run_strength, ", ",
    round(opp_run_sr * 100, 1), "% success rate). ",
    "**Defensive Focus:** ",
    if(opp_pass_epa > opp_run_epa) {
      "Limit their passing attack and force them to run."
    } else {
      "Stop the run and make them one-dimensional."
    }
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

  # Success rates allowed
  opp_pass_sr_allowed <- next_opp_def_agg$success_rate_allowed_pass[1]
  opp_run_sr_allowed <- next_opp_def_agg$success_rate_allowed_run[1]

  # Determine strengths (lower is better for defense)
  pass_def_strength <- if(opp_pass_epa < p4_pass_epa) "strong" else "vulnerable"
  run_def_strength <- if(opp_run_epa < p4_run_epa) "strong" else "vulnerable"

  # Overall assessment
  if(opp_pass_epa < p4_pass_epa && opp_run_epa < p4_run_epa) {
    strength <- "has a formidable defense"
  } else if(opp_pass_epa < p4_pass_epa) {
    strength <- "has a strong pass defense but is vulnerable against the run"
  } else if(opp_run_epa < p4_run_epa) {
    strength <- "has a strong run defense but can be exploited through the air"
  } else {
    strength <- "has defensive vulnerabilities in both phases"
  }

  # Build text
  paste0(
    "**Defensive Profile:** ", next_opp_name, " ", strength, ". ",
    "Pass defense EPA: ", round(opp_pass_epa, 3), " (", pass_def_strength, ", allows ",
    round(opp_pass_sr_allowed * 100, 1), "% success rate). ",
    "Run defense EPA: ", round(opp_run_epa, 3), " (", run_def_strength, ", allows ",
    round(opp_run_sr_allowed * 100, 1), "% success rate). ",
    "**Offensive Game Plan:** ",
    if(opp_pass_epa > opp_run_epa) {
      "Attack through the air where they're more vulnerable."
    } else {
      "Establish the run game to exploit their weakness."
    }
  )
}
