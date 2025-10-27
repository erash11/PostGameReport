# ====================================================================
# HELPER FUNCTIONS FOR POST-GAME REPORT
# ====================================================================
# This file contains reusable functions to reduce code duplication
# and improve maintainability of the post-game report generation
# ====================================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(ggimage)

# ====================================================================
# DATA AGGREGATION FUNCTIONS
# ====================================================================

#' Calculate Team Aggregates by Game
#'
#' @param data Play-by-play data
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return Aggregated statistics by opponent
calculate_team_agg_by_game <- function(data, offense = TRUE) {

  if (offense) {
    result <- data %>%
      filter(!is.na(EPA), !is.na(success)) %>%
      group_by(def_pos_team) %>%
      summarize(
        avg_pass_epa = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      ) %>%
      rename(school = def_pos_team)
  } else {
    result <- data %>%
      filter(!is.na(EPA), !is.na(success)) %>%
      group_by(pos_team) %>%
      summarize(
        avg_pass_epa_allowed = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa_allowed = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_allowed_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_allowed_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      ) %>%
      rename(school = pos_team)
  }

  return(result)
}

#' Calculate Team Aggregates by Play
#'
#' @param data Play-by-play data
#' @param grouping_name Name for the grouping (e.g., "BU Season", "Power 4")
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return Aggregated statistics by play
calculate_team_agg_by_play <- function(data, grouping_name, offense = TRUE) {

  data <- data %>%
    filter(!is.na(EPA), !is.na(success), r_p %in% c('Run', 'Pass'))

  if (offense) {
    result <- data %>%
      mutate(grouping = grouping_name) %>%
      group_by(grouping) %>%
      summarise(
        avg_pass_epa = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      )
  } else {
    result <- data %>%
      mutate(grouping = grouping_name) %>%
      group_by(grouping) %>%
      summarise(
        avg_pass_epa_allowed = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa_allowed = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_allowed_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_allowed_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      )
  }

  return(result)
}

#' Calculate Team Aggregates by Down
#'
#' @param data Play-by-play data
#' @param grouping_name Name for the grouping
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return Aggregated statistics by down
calculate_team_agg_by_down <- function(data, grouping_name, offense = TRUE) {

  data <- data %>%
    filter(!is.na(EPA), !is.na(success), r_p %in% c('Run', 'Pass'))

  if (offense) {
    result <- data %>%
      mutate(grouping = grouping_name) %>%
      group_by(grouping) %>%
      summarise(
        avg_1st_pass_epa = mean(EPA[r_p == 'Pass' & down == 1], na.rm = TRUE),
        avg_1st_run_epa = mean(EPA[r_p == 'Run' & down == 1], na.rm = TRUE),
        avg_2nd_pass_epa = mean(EPA[r_p == 'Pass' & down == 2], na.rm = TRUE),
        avg_2nd_run_epa = mean(EPA[r_p == 'Run' & down == 2], na.rm = TRUE),
        avg_3rd_pass_epa = mean(EPA[r_p == 'Pass' & down == 3], na.rm = TRUE),
        avg_3rd_run_epa = mean(EPA[r_p == 'Run' & down == 3], na.rm = TRUE),
        avg_4th_pass_epa = mean(EPA[r_p == 'Pass' & down == 4], na.rm = TRUE),
        avg_4th_run_epa = mean(EPA[r_p == 'Run' & down == 4], na.rm = TRUE)
      )
  } else {
    result <- data %>%
      mutate(grouping = grouping_name) %>%
      group_by(grouping) %>%
      summarise(
        avg_1st_pass_epa_allowed = mean(EPA[r_p == 'Pass' & down == 1], na.rm = TRUE),
        avg_1st_run_epa_allowed = mean(EPA[r_p == 'Run' & down == 1], na.rm = TRUE),
        avg_2nd_pass_epa_allowed = mean(EPA[r_p == 'Pass' & down == 2], na.rm = TRUE),
        avg_2nd_run_epa_allowed = mean(EPA[r_p == 'Run' & down == 2], na.rm = TRUE),
        avg_3rd_pass_epa_allowed = mean(EPA[r_p == 'Pass' & down == 3], na.rm = TRUE),
        avg_3rd_run_epa_allowed = mean(EPA[r_p == 'Run' & down == 3], na.rm = TRUE),
        avg_4th_pass_epa_allowed = mean(EPA[r_p == 'Pass' & down == 4], na.rm = TRUE),
        avg_4th_run_epa_allowed = mean(EPA[r_p == 'Run' & down == 4], na.rm = TRUE)
      )
  }

  return(result)
}

#' Calculate Next Opponent Aggregates by Game
#'
#' @param data Play-by-play data for opponent
#' @param team_info_logo_join Logo join table
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return Aggregated statistics by week with logos
calculate_next_opp_agg_by_game <- function(data, team_info_logo_join, offense = TRUE) {

  data <- data %>%
    filter(!is.na(EPA), !is.na(success), !is.na(r_p))

  if (offense) {
    result <- data %>%
      group_by(week) %>%
      summarize(
        school = max(def_pos_team),
        avg_pass_epa = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      )
  } else {
    result <- data %>%
      group_by(week) %>%
      summarize(
        school = max(pos_team),
        avg_pass_epa_allowed = mean(EPA[r_p == 'Pass'], na.rm = TRUE),
        avg_run_epa_allowed = mean(EPA[r_p == 'Run'], na.rm = TRUE),
        success_rate_allowed_pass = mean(success[r_p == 'Pass'], na.rm = TRUE),
        success_rate_allowed_run = mean(success[r_p == 'Run'], na.rm = TRUE)
      )
  }

  # Join logos
  result <- left_join(result, team_info_logo_join, by = "school")
  result <- result %>% rename(opponent = school)

  return(result)
}

# ====================================================================
# THEME FUNCTIONS
# ====================================================================

#' Custom BU Theme for ggplot2
#'
#' @return A ggplot2 theme object
bu_theme <- function() {
  theme(
    legend.position = "bottom",
    panel.background = element_rect(fill = 'lightgray'),
    panel.grid.major = element_line(color = 'white', size = .01),
    panel.grid.minor = element_line(color = 'white', size = .01),
    panel.border = element_blank(),
    plot.title = element_text(size = 14, hjust = 0, face = "bold"),
    axis.title.x = element_text(margin = margin(t = 15)),
    axis.title.y = element_text(margin = margin(r = 15))
  )
}

# ====================================================================
# CHART GENERATION FUNCTIONS
# ====================================================================

#' Create EPA Comparison Bar Chart
#'
#' @param data Combined data for comparison
#' @param bu_color Baylor primary color
#' @param bu_alt_color Baylor alternate color
#' @param title Chart title
#' @param subtitle Chart subtitle
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return ggplot object
create_epa_comparison_chart <- function(data, bu_color, bu_alt_color,
                                       title, subtitle, offense = TRUE) {

  # Pivot data
  if (offense) {
    chart_data <- data[1:3] %>%
      pivot_longer(cols = 2:3, names_to = 'statistic', values_to = 'value')

    x_labels <- c('Pass', 'Run')
    y_label <- "EPA per play"
  } else {
    chart_data <- data[1:3] %>%
      pivot_longer(cols = 2:3, names_to = 'statistic', values_to = 'value')

    x_labels <- c('Pass', 'Run')
    y_label <- "EPA Allowed per play"
  }

  # Create plot
  p <- chart_data %>%
    ggplot(aes(x = statistic, y = value, fill = grouping)) +
    geom_bar(position = "dodge", stat = "identity", width = .8) +
    geom_text(aes(label = round(value, 2),
                  vjust = ifelse(offense,
                                ifelse(value <= 0, 1.5, -1),
                                ifelse(value >= 0, 1.5, -1))),
              position = position_dodge(width = 0.8),
              size = 4,
              color = "black",
              fontface = "italic") +
    scale_fill_manual(values = c(bu_alt_color, bu_color, "grey35")) +
    bu_theme() +
    labs(y = y_label, x = "", subtitle = subtitle, title = title) +
    guides(fill = guide_legend(title = "Key")) +
    geom_hline(yintercept = 0, size = .5, color = 'black') +
    scale_x_discrete(labels = x_labels)

  if (!offense) {
    p <- p + scale_y_reverse(limits = c(max(chart_data$value) + .03,
                                        min(chart_data$value) - .03))
  } else {
    p <- p + coord_cartesian(ylim = c(min(chart_data$value) - .03,
                                      max(chart_data$value) + .03))
  }

  return(p)
}

#' Create EPA Scatter Plot by Game
#'
#' @param data Game-by-game aggregated data
#' @param current_opp Current opponent name
#' @param title Chart title
#' @param subtitle Chart subtitle
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return ggplot object
create_epa_scatter_plot <- function(data, current_opp, title, subtitle, offense = TRUE) {

  if (offense) {
    x_var <- "avg_pass_epa"
    y_var <- "avg_run_epa"
    x_label <- "EPA per Pass"
    y_label <- "EPA per Rush"

    # Define quadrant colors
    quad_colors <- list(
      bottom_left = "lightpink",    # Weak Run, Weak Pass
      bottom_right = "#ffe385",     # Weak Run, Strong Pass
      top_left = "#ffe385",         # Strong Run, Weak Pass
      top_right = "lightgreen"      # Strong Run, Strong Pass
    )

    quad_labels <- list(
      top_left = "Strong Run\nWeak Pass",
      bottom_left = "Weak Pass\nWeak Run",
      top_right = "Strong Pass\n           Strong Run",
      bottom_right = "Strong Pass \n           Weak Run"
    )

    reverse_axes <- FALSE
  } else {
    x_var <- "avg_pass_epa_allowed"
    y_var <- "avg_run_epa_allowed"
    x_label <- "EPA Allowed per Pass"
    y_label <- "EPA Allowed per Rush"

    # Defense: lower is better
    quad_colors <- list(
      bottom_left = "lightgreen",   # Strong Run DEF, Strong Pass DEF
      bottom_right = "#FFE385",     # Strong Run DEF, Weak Pass DEF
      top_left = "#FFE385",         # Weak Run DEF, Strong Pass DEF
      top_right = "lightpink"       # Weak Run DEF, Weak Pass DEF
    )

    quad_labels <- list(
      top_left = "Weak Run DEF\nStrong Pass DEF",
      bottom_left = "Strong Run DEF\nStrong Pass DEF",
      top_right = "Weak Run DEF\nWeak Pass DEF",
      bottom_right = "Strong Run DEF\nWeak Pass DEF"
    )

    reverse_axes <- TRUE
  }

  x_mean <- mean(data[[x_var]], na.rm = TRUE)
  y_mean <- mean(data[[y_var]], na.rm = TRUE)

  # Create base plot
  p <- data %>%
    ggplot(aes(x = .data[[x_var]], y = .data[[y_var]])) +
    geom_rect(aes(xmin = -Inf, xmax = x_mean, ymin = -Inf, ymax = y_mean),
              fill = quad_colors$bottom_left, alpha = 0.2) +
    geom_rect(aes(xmin = x_mean, xmax = Inf, ymin = -Inf, ymax = y_mean),
              fill = quad_colors$bottom_right, alpha = 0.2) +
    geom_rect(aes(xmin = -Inf, xmax = x_mean, ymin = y_mean, ymax = Inf),
              fill = quad_colors$top_left, alpha = 0.2) +
    geom_rect(aes(xmin = x_mean, xmax = Inf, ymin = y_mean, ymax = Inf),
              fill = quad_colors$top_right, alpha = 0.2) +
    geom_point(alpha = 0) +
    geom_image(aes(image = logo), size = 0.05, asp = 16 / 9) +
    bu_theme() +
    theme(legend.position = "none") +
    labs(x = x_label, y = y_label, title = title, subtitle = subtitle) +
    geom_hline(yintercept = y_mean, linetype = 'dashed', size = .5, color = 'black') +
    geom_vline(xintercept = x_mean, linetype = 'dashed', size = .5, color = 'black')

  # Add circle around current opponent
  opp_data <- data %>% filter(opponent == current_opp)
  if (nrow(opp_data) > 0) {
    p <- p + annotate("path",
                      x = as.numeric(opp_data[[x_var]]) + .05 * cos(seq(0, 2*pi, length.out = 100)),
                      y = as.numeric(opp_data[[y_var]]) + .05 * sin(seq(0, 2*pi, length.out = 100)),
                      color = 'darkred', size = 1)
  }

  # Add quadrant labels
  p <- p +
    annotate("text", x = x_mean - 0.5, y = y_mean + 0.1,
             label = quad_labels$top_left, color = "black", size = 3,
             fontface = "plain", hjust = 0, vjust = 1) +
    annotate("text", x = x_mean - 0.5, y = y_mean - 0.1,
             label = quad_labels$bottom_left, color = "black", size = 3,
             fontface = "plain", hjust = 0, vjust = 0) +
    annotate("text", x = x_mean + 0.35, y = y_mean + 0.1,
             label = quad_labels$top_right, color = "black", size = 3,
             fontface = "plain", hjust = 1, vjust = 1) +
    annotate("text", x = x_mean + 0.25, y = y_mean - 0.05,
             label = quad_labels$bottom_right, color = "black", size = 3,
             fontface = "plain", hjust = 1, vjust = 0)

  # Reverse axes for defense
  if (reverse_axes) {
    p <- p + scale_y_reverse() + scale_x_reverse()
  }

  return(p)
}

#' Create Down & Distance Comparison Chart
#'
#' @param data Combined data with Power 4 comparison
#' @param team_color Team primary color
#' @param title Chart title
#' @param subtitle Chart subtitle
#' @param offense Logical, TRUE for offense, FALSE for defense
#' @return ggplot object
create_down_distance_chart <- function(data, team_color, title, subtitle, offense = TRUE) {

  # Pivot data
  chart_data <- data %>%
    pivot_longer(cols = 2:length(colnames(data)),
                 names_to = 'statistic',
                 values_to = 'value')

  if (offense) {
    x_label <- "EPA per play"
    axis_labels <- c('1st Down Pass', '1st Down Run', '2nd Down Pass',
                    '2nd Down Run', '3rd Down Pass', '3rd Down Run',
                    '4th Down Pass', '4th Down Run')
    hjust_calc <- "ifelse(value >= 0, -0.2, 1.2)"
  } else {
    x_label <- "EPA Allowed per play"
    axis_labels <- c('1st Down Pass', '1st Down Run', '2nd Down Pass',
                    '2nd Down Run', '3rd Down Pass', '3rd Down Run',
                    '4th Down Pass', '4th Down Run')
    hjust_calc <- "ifelse(value <= 0, -0.2, 1.2)"
  }

  p <- chart_data %>%
    ggplot(aes(x = value, y = statistic, fill = grouping)) +
    geom_bar(position = "dodge", stat = "identity", width = .8) +
    geom_text(aes(label = round(value, 2),
                  hjust = if (offense) ifelse(value >= 0, -0.2, 1.2) else ifelse(value <= 0, -0.2, 1.2)),
              position = position_dodge(width = 0.8),
              size = 3.5,
              color = "black",
              fontface = "bold") +
    scale_fill_manual(values = c(team_color, "grey35")) +
    bu_theme() +
    labs(y = "", x = x_label, subtitle = subtitle, title = title) +
    guides(fill = guide_legend(title = "Key")) +
    geom_hline(yintercept = 0, size = .5, color = 'black') +
    scale_y_discrete(labels = axis_labels)

  if (!offense) {
    p <- p + scale_x_reverse()
  }

  return(p)
}

# ====================================================================
# DATA VALIDATION FUNCTIONS
# ====================================================================

#' Validate Play-by-Play Data Quality
#'
#' @param data Play-by-play data
#' @return List of data quality issues
validate_data <- function(data) {
  checks <- list(
    total_rows = nrow(data),
    missing_epa = sum(is.na(data$EPA)),
    missing_success = sum(is.na(data$success)),
    missing_rp = sum(is.na(data$r_p)),
    invalid_down = sum(data$down > 4, na.rm = TRUE),
    negative_distance = sum(data$distance < 0, na.rm = TRUE),
    pct_missing_epa = round(sum(is.na(data$EPA)) / nrow(data) * 100, 2)
  )

  if (checks$invalid_down > 0 || checks$negative_distance > 0) {
    warning("Data quality issues detected:")
    print(checks)
  }

  return(checks)
}

# ====================================================================
# UTILITY FUNCTIONS
# ====================================================================

#' Join Team Logos to Data
#'
#' @param data Data with school column
#' @param team_info_logo_join Logo join table
#' @param custom_logo_path Optional custom logo path for teams not in package
#' @param custom_logo_team Optional team name for custom logo
#' @return Data with logos joined
join_logos <- function(data, team_info_logo_join,
                       custom_logo_path = NULL, custom_logo_team = NULL) {

  result <- left_join(data, team_info_logo_join, by = "school")

  if (!is.null(custom_logo_path) && !is.null(custom_logo_team)) {
    result <- result %>%
      mutate(logo = ifelse(school == custom_logo_team & is.na(logo),
                          custom_logo_path, logo))
  }

  return(result)
}
