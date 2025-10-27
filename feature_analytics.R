# ====================================================================
# ADVANCED FEATURE ANALYTICS
# ====================================================================
# This file contains advanced analytics features including:
# - Player-level statistics
# - Situational analytics (red zone, 3rd down, etc.)
# - Opponent tendency analysis
# - WPA and explosive play analysis
# - Game planning insights
# ====================================================================

library(dplyr)
library(tidyr)

# ====================================================================
# PLAYER-LEVEL ANALYTICS
# ====================================================================

#' Calculate Player Performance Statistics
#'
#' @param data Play-by-play data
#' @param min_plays Minimum plays to include player (default: 5)
#' @return Data frame with player statistics
calculate_player_stats <- function(data, min_plays = 5) {

  # Passing stats
  passing_stats <- data %>%
    filter(!is.na(passer_player_name), r_p == 'Pass') %>%
    group_by(passer_player_name) %>%
    summarize(
      position = "QB",
      plays = n(),
      completions = sum(completion, na.rm = TRUE),
      attempts = n(),
      yards = sum(completion_yds, na.rm = TRUE),
      touchdowns = sum(pass_td, na.rm = TRUE),
      interceptions = sum(int, na.rm = TRUE),
      avg_epa = mean(EPA, na.rm = TRUE),
      success_rate = mean(success, na.rm = TRUE),
      completion_pct = round(sum(completion, na.rm = TRUE) / n() * 100, 1)
    ) %>%
    filter(plays >= min_plays) %>%
    rename(player = passer_player_name)

  # Rushing stats
  rushing_stats <- data %>%
    filter(!is.na(rusher_player_name), r_p == 'Run') %>%
    group_by(rusher_player_name) %>%
    summarize(
      position = "RB/QB",
      plays = n(),
      yards = sum(yds_rushed, na.rm = TRUE),
      touchdowns = sum(rush_td, na.rm = TRUE),
      avg_yards = round(mean(yds_rushed, na.rm = TRUE), 2),
      avg_epa = mean(EPA, na.rm = TRUE),
      success_rate = mean(success, na.rm = TRUE),
      explosive_plays = sum(yds_rushed >= 12, na.rm = TRUE)
    ) %>%
    filter(plays >= min_plays) %>%
    rename(player = rusher_player_name)

  # Receiving stats
  receiving_stats <- data %>%
    filter(!is.na(receiver_player_name), r_p == 'Pass') %>%
    group_by(receiver_player_name) %>%
    summarize(
      position = "WR/TE",
      plays = n(),
      receptions = sum(completion, na.rm = TRUE),
      targets = n(),
      yards = sum(completion_yds[completion == 1], na.rm = TRUE),
      touchdowns = sum(pass_td, na.rm = TRUE),
      avg_yards = round(mean(completion_yds[completion == 1], na.rm = TRUE), 2),
      avg_epa = mean(EPA, na.rm = TRUE),
      success_rate = mean(success, na.rm = TRUE),
      explosive_plays = sum(completion_yds >= 20, na.rm = TRUE),
      catch_rate = round(sum(completion, na.rm = TRUE) / n() * 100, 1)
    ) %>%
    filter(plays >= min_plays) %>%
    rename(player = receiver_player_name)

  return(list(
    passing = passing_stats,
    rushing = rushing_stats,
    receiving = receiving_stats
  ))
}

#' Get Top Performers
#'
#' @param player_stats Output from calculate_player_stats
#' @param n Top N players (default: 5)
#' @return List of top performers by category
get_top_performers <- function(player_stats, n = 5) {

  list(
    top_passers_epa = player_stats$passing %>%
      arrange(desc(avg_epa)) %>%
      head(n),

    top_rushers_epa = player_stats$rushing %>%
      arrange(desc(avg_epa)) %>%
      head(n),

    top_receivers_epa = player_stats$receiving %>%
      arrange(desc(avg_epa)) %>%
      head(n),

    top_rushers_yards = player_stats$rushing %>%
      arrange(desc(yards)) %>%
      head(n),

    top_receivers_yards = player_stats$receiving %>%
      arrange(desc(yards)) %>%
      head(n)
  )
}

# ====================================================================
# SITUATIONAL ANALYTICS
# ====================================================================

#' Calculate Red Zone Efficiency
#'
#' @param data Play-by-play data
#' @return Data frame with red zone statistics
calculate_red_zone_stats <- function(data) {

  data %>%
    filter(yardline_100 <= 20) %>%
    group_by(pos_team) %>%
    summarize(
      red_zone_plays = n(),
      touchdowns = sum(off_td, na.rm = TRUE),
      td_rate = round(sum(off_td, na.rm = TRUE) / n() * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      success_rate = round(mean(success, na.rm = TRUE) * 100, 1),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1)
    ) %>%
    arrange(desc(td_rate))
}

#' Calculate Third Down Efficiency
#'
#' @param data Play-by-play data
#' @return Data frame with 3rd down statistics
calculate_third_down_stats <- function(data) {

  data %>%
    filter(down == 3) %>%
    mutate(
      distance_category = case_when(
        distance <= 3 ~ "Short (1-3)",
        distance <= 7 ~ "Medium (4-7)",
        TRUE ~ "Long (8+)"
      )
    ) %>%
    group_by(pos_team, distance_category) %>%
    summarize(
      attempts = n(),
      conversions = sum(first_down, na.rm = TRUE),
      conversion_rate = round(mean(first_down, na.rm = TRUE) * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1)
    ) %>%
    arrange(pos_team, distance_category)
}

#' Calculate Fourth Down Decisions
#'
#' @param data Play-by-play data
#' @return Data frame with 4th down statistics
calculate_fourth_down_stats <- function(data) {

  data %>%
    filter(down == 4, !kickoff_play, !punt_play) %>%
    group_by(pos_team) %>%
    summarize(
      go_for_it_attempts = n(),
      conversions = sum(first_down, na.rm = TRUE),
      conversion_rate = round(mean(first_down, na.rm = TRUE) * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      touchdowns = sum(off_td, na.rm = TRUE),
      avg_distance = round(mean(distance, na.rm = TRUE), 1)
    ) %>%
    arrange(desc(conversion_rate))
}

#' Calculate Quarter-by-Quarter Performance
#'
#' @param data Play-by-play data
#' @return Data frame with performance by quarter
calculate_quarter_performance <- function(data) {

  data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      quarter = case_when(
        period == 1 ~ "Q1",
        period == 2 ~ "Q2",
        period == 3 ~ "Q3",
        period == 4 ~ "Q4",
        TRUE ~ "OT"
      )
    ) %>%
    group_by(pos_team, quarter) %>%
    summarize(
      plays = n(),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      success_rate = round(mean(success, na.rm = TRUE) * 100, 1),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      explosive_plays = sum((r_p == 'Pass' & off_yds >= 20) | (r_p == 'Run' & off_yds >= 12), na.rm = TRUE)
    ) %>%
    arrange(pos_team, quarter)
}

#' Calculate Goal Line Efficiency
#'
#' @param data Play-by-play data
#' @return Data frame with goal line statistics
calculate_goal_line_stats <- function(data) {

  data %>%
    filter(yardline_100 <= 5) %>%
    group_by(pos_team) %>%
    summarize(
      plays = n(),
      touchdowns = sum(off_td, na.rm = TRUE),
      td_rate = round(sum(off_td, na.rm = TRUE) / n() * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1)
    ) %>%
    arrange(desc(td_rate))
}

# ====================================================================
# OPPONENT TENDENCY ANALYSIS
# ====================================================================

#' Calculate Down and Distance Tendencies
#'
#' @param data Play-by-play data
#' @return Data frame with tendencies
calculate_down_distance_tendencies <- function(data) {

  data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      distance_category = case_when(
        distance <= 3 ~ "Short (1-3)",
        distance <= 7 ~ "Medium (4-7)",
        TRUE ~ "Long (8+)"
      )
    ) %>%
    group_by(pos_team, down, distance_category) %>%
    summarize(
      plays = n(),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      success_rate = round(mean(success, na.rm = TRUE) * 100, 1),
      tendency = case_when(
        mean(r_p == 'Pass', na.rm = TRUE) > 0.7 ~ "Pass Heavy",
        mean(r_p == 'Pass', na.rm = TRUE) < 0.3 ~ "Run Heavy",
        TRUE ~ "Balanced"
      )
    ) %>%
    arrange(pos_team, down, distance_category)
}

#' Calculate Field Position Tendencies
#'
#' @param data Play-by-play data
#' @return Data frame with field position tendencies
calculate_field_position_tendencies <- function(data) {

  data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      field_zone = case_when(
        yardline_100 >= 80 ~ "Own Territory (1-20)",
        yardline_100 >= 50 ~ "Between 20s (21-50)",
        yardline_100 >= 20 ~ "Opponent Territory (51-80)",
        TRUE ~ "Red Zone (81-100)"
      )
    ) %>%
    group_by(pos_team, field_zone) %>%
    summarize(
      plays = n(),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      success_rate = round(mean(success, na.rm = TRUE) * 100, 1)
    ) %>%
    arrange(pos_team, field_zone)
}

#' Calculate Game Script Tendencies
#'
#' @param data Play-by-play data
#' @return Data frame with tendencies by game situation
calculate_game_script_tendencies <- function(data) {

  data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      score_diff = pos_score - def_score,
      game_situation = case_when(
        score_diff > 14 ~ "Leading by 2+ Scores",
        score_diff > 7 ~ "Leading by 1 Score",
        score_diff >= -7 ~ "Close Game (±7)",
        score_diff >= -14 ~ "Trailing by 1 Score",
        TRUE ~ "Trailing by 2+ Scores"
      )
    ) %>%
    group_by(pos_team, game_situation) %>%
    summarize(
      plays = n(),
      pass_rate = round(mean(r_p == 'Pass', na.rm = TRUE) * 100, 1),
      run_rate = round(mean(r_p == 'Run', na.rm = TRUE) * 100, 1),
      avg_epa = round(mean(EPA, na.rm = TRUE), 3),
      success_rate = round(mean(success, na.rm = TRUE) * 100, 1)
    ) %>%
    arrange(pos_team, desc(plays))
}

# ====================================================================
# WPA AND EXPLOSIVE PLAY ANALYSIS
# ====================================================================

#' Calculate Win Probability Added (WPA)
#'
#' @param data Play-by-play data with WP columns
#' @param team Team name
#' @param home_team Name of home team
#' @return Data frame with WPA statistics
calculate_wpa_stats <- function(data, team, home_team) {

  is_home <- team == home_team

  data %>%
    filter(pos_team == team | def_pos_team == team) %>%
    mutate(
      # Calculate WPA based on whether team is home or away
      wpa = if (is_home) {
        home_wp_after - home_wp_before
      } else {
        away_wp_after - away_wp_before
      },
      # Adjust sign if team is on defense
      wpa = ifelse(def_pos_team == team, -wpa, wpa)
    ) %>%
    filter(!is.na(wpa)) %>%
    arrange(desc(abs(wpa))) %>%
    select(play_text, down, distance, yardline_100, r_p, off_yds, wpa, EPA)
}

#' Get Top WPA Plays
#'
#' @param wpa_data Output from calculate_wpa_stats
#' @param n Top N plays (default: 10)
#' @return Top plays by WPA
get_top_wpa_plays <- function(wpa_data, n = 10) {

  list(
    positive = wpa_data %>%
      filter(wpa > 0) %>%
      arrange(desc(wpa)) %>%
      head(n),

    negative = wpa_data %>%
      filter(wpa < 0) %>%
      arrange(wpa) %>%
      head(n),

    overall = wpa_data %>%
      arrange(desc(abs(wpa))) %>%
      head(n)
  )
}

#' Calculate Explosive Play Analysis
#'
#' @param data Play-by-play data
#' @return Data frame with explosive play statistics
calculate_explosive_plays <- function(data) {

  data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      is_explosive = (r_p == 'Pass' & off_yds >= 20) | (r_p == 'Run' & off_yds >= 12)
    ) %>%
    group_by(pos_team) %>%
    summarize(
      total_plays = n(),
      explosive_plays = sum(is_explosive, na.rm = TRUE),
      explosive_rate = round(mean(is_explosive, na.rm = TRUE) * 100, 1),
      avg_explosive_yards = round(mean(off_yds[is_explosive], na.rm = TRUE), 1),
      explosive_pass = sum(is_explosive & r_p == 'Pass', na.rm = TRUE),
      explosive_run = sum(is_explosive & r_p == 'Run', na.rm = TRUE),
      explosive_touchdowns = sum(off_td[is_explosive], na.rm = TRUE)
    ) %>%
    arrange(desc(explosive_rate))
}

#' List All Explosive Plays
#'
#' @param data Play-by-play data
#' @param team Team name (optional, NULL for all teams)
#' @return Data frame with all explosive plays
list_explosive_plays <- function(data, team = NULL) {

  result <- data %>%
    filter(!is.na(r_p)) %>%
    mutate(
      is_explosive = (r_p == 'Pass' & off_yds >= 20) | (r_p == 'Run' & off_yds >= 12)
    ) %>%
    filter(is_explosive) %>%
    select(pos_team, def_pos_team, play_text, r_p, off_yds, EPA, success, off_td)

  if (!is.null(team)) {
    result <- result %>% filter(pos_team == team)
  }

  return(result %>% arrange(desc(off_yds)))
}

# ====================================================================
# DRIVE EFFICIENCY METRICS
# ====================================================================

#' Calculate Drive Efficiency
#'
#' @param data Play-by-play data
#' @return Data frame with drive-level statistics
calculate_drive_efficiency <- function(data) {

  data %>%
    filter(!is.na(drive_id)) %>%
    group_by(drive_id, pos_team) %>%
    summarize(
      plays = n(),
      yards = sum(off_yds, na.rm = TRUE),
      drive_epa = sum(EPA, na.rm = TRUE),
      start_yardline = first(yardline_100),
      end_yardline = last(yardline_100),
      scored = max(scoring_play, na.rm = TRUE),
      touchdown = max(off_td, na.rm = TRUE),
      first_downs = sum(first_down, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    group_by(pos_team) %>%
    summarize(
      drives = n(),
      avg_plays = round(mean(plays, na.rm = TRUE), 1),
      avg_yards = round(mean(yards, na.rm = TRUE), 1),
      avg_drive_epa = round(mean(drive_epa, na.rm = TRUE), 2),
      scoring_drives = sum(scored, na.rm = TRUE),
      scoring_pct = round(mean(scored, na.rm = TRUE) * 100, 1),
      td_drives = sum(touchdown, na.rm = TRUE),
      td_pct = round(mean(touchdown, na.rm = TRUE) * 100, 1)
    )
}

# ====================================================================
# GAME PLANNING & EXPLOIT IDENTIFICATION
# ====================================================================

#' Identify Matchup Exploits
#'
#' @param bu_off_stats Baylor offensive stats
#' @param opp_def_stats Opponent defensive stats
#' @param p4_off_stats Power 4 offensive stats
#' @param p4_def_stats Power 4 defensive stats
#' @return Data frame with exploit opportunities
identify_exploits <- function(bu_off_stats, opp_def_stats, p4_off_stats, p4_def_stats) {

  exploits <- data.frame(
    category = c("Pass Offense vs Pass Defense", "Run Offense vs Run Defense"),
    bu_strength = c(
      bu_off_stats$avg_pass_epa > p4_off_stats$avg_pass_epa,
      bu_off_stats$avg_run_epa > p4_off_stats$avg_run_epa
    ),
    opp_weakness = c(
      opp_def_stats$avg_pass_epa_allowed > p4_def_stats$avg_pass_epa_allowed,
      opp_def_stats$avg_run_epa_allowed > p4_def_stats$avg_run_epa_allowed
    ),
    bu_epa = c(
      round(bu_off_stats$avg_pass_epa, 3),
      round(bu_off_stats$avg_run_epa, 3)
    ),
    opp_epa_allowed = c(
      round(opp_def_stats$avg_pass_epa_allowed, 3),
      round(opp_def_stats$avg_run_epa_allowed, 3)
    ),
    p4_avg_off = c(
      round(p4_off_stats$avg_pass_epa, 3),
      round(p4_off_stats$avg_run_epa, 3)
    ),
    p4_avg_def = c(
      round(p4_def_stats$avg_pass_epa_allowed, 3),
      round(p4_def_stats$avg_run_epa_allowed, 3)
    )
  ) %>%
    mutate(
      exploit_opportunity = bu_strength & opp_weakness,
      advantage_score = (bu_epa - p4_avg_off) - (opp_epa_allowed - p4_avg_def),
      recommendation = case_when(
        exploit_opportunity & advantage_score > 0.1 ~ "Strong Exploit - Prioritize",
        exploit_opportunity ~ "Moderate Exploit - Utilize",
        bu_strength ~ "Use Strength - Neutral Matchup",
        opp_weakness ~ "Target Weakness - Neutral Matchup",
        TRUE ~ "Difficult Matchup - Be Strategic"
      )
    )

  return(exploits)
}

#' Generate Tendency-Based Recommendations
#'
#' @param tendency_data Output from calculate_down_distance_tendencies
#' @return Data frame with recommendations
generate_tendency_recommendations <- function(tendency_data) {

  tendency_data %>%
    mutate(
      recommendation = case_when(
        tendency == "Pass Heavy" & success_rate < 40 ~
          paste0("Opponent passes ", pass_rate, "% on ", down, " & ", distance_category,
                " but only ", success_rate, "% success. Prepare for pass, but vulnerable."),

        tendency == "Run Heavy" & success_rate < 40 ~
          paste0("Opponent runs ", run_rate, "% on ", down, " & ", distance_category,
                " but only ", success_rate, "% success. Stack the box."),

        tendency == "Pass Heavy" & success_rate >= 40 ~
          paste0("Opponent passes ", pass_rate, "% on ", down, " & ", distance_category,
                " with ", success_rate, "% success. Strong pass defense needed."),

        tendency == "Run Heavy" & success_rate >= 40 ~
          paste0("Opponent runs ", run_rate, "% on ", down, " & ", distance_category,
                " with ", success_rate, "% success. Focus run stopping."),

        TRUE ~ paste0("Balanced attack on ", down, " & ", distance_category, ".")
      )
    )
}
