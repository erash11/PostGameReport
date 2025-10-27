#!/usr/bin/env Rscript
# ====================================================================
# AUTOMATED REPORT GENERATION SCRIPT
# ====================================================================
# This script automates the generation of post-game reports
# Usage: Rscript generate_report.R --week 1 --opponent "SMU" --next "Samford"
# Or use the function: generate_weekly_report(week = 1, opponent = "SMU", next_opponent = "Samford")
# ====================================================================

library(yaml)
library(rmarkdown)
library(pagedown)

#' Generate Weekly Post-Game Report
#'
#' @param week Week number
#' @param opponent Current week's opponent
#' @param opponent_abbr Opponent abbreviation (optional, defaults to opponent)
#' @param next_opponent Next week's opponent
#' @param next_opponent_abbr Next opponent abbreviation (optional, defaults to next_opponent)
#' @param config_file Path to config file (default: "report_config.yaml")
#' @param template_file Path to Rmd template (default: "BU_Post_2024.Rmd")
#' @param output_dir Output directory (default: "./reports")
#' @param force_reload Force reload data from API (default: FALSE)
#' @return Path to generated report
generate_weekly_report <- function(week,
                                   opponent,
                                   opponent_abbr = NULL,
                                   next_opponent,
                                   next_opponent_abbr = NULL,
                                   config_file = "report_config.yaml",
                                   template_file = "BU_Post_2024.Rmd",
                                   output_dir = "./reports",
                                   force_reload = FALSE) {

  # Set defaults
  if (is.null(opponent_abbr)) opponent_abbr <- opponent
  if (is.null(next_opponent_abbr)) next_opponent_abbr <- next_opponent

  # Load configuration
  if (file.exists(config_file)) {
    config <- yaml::read_yaml(config_file)
    message("Loaded configuration from ", config_file)
  } else {
    config <- list()
    message("No config file found, using defaults")
  }

  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message("Created output directory: ", output_dir)
  }

  # Set parameters for report
  report_date <- format(Sys.Date(), "%Y%m%d")
  output_file <- file.path(
    output_dir,
    paste0("BU_vs_", opponent_abbr, "_Week", week, "_", report_date, ".pdf")
  )

  # Set environment variables for the report
  Sys.setenv(
    REPORT_WEEK = week,
    REPORT_OPP_NAME = opponent,
    REPORT_OPP_ABR = opponent_abbr,
    REPORT_NEXT_NAME = next_opponent,
    REPORT_NEXT_ABR = next_opponent_abbr,
    REPORT_FORCE_RELOAD = ifelse(force_reload, "TRUE", "FALSE")
  )

  message("\n========================================")
  message("Generating Post-Game Report")
  message("========================================")
  message("Week: ", week)
  message("Opponent: ", opponent, " (", opponent_abbr, ")")
  message("Next Opponent: ", next_opponent, " (", next_opponent_abbr, ")")
  message("Template: ", template_file)
  message("Output: ", output_file)
  message("Force Reload: ", force_reload)
  message("========================================\n")

  # Check if template exists
  if (!file.exists(template_file)) {
    stop("Template file not found: ", template_file)
  }

  # Render the report
  tryCatch({
    message("Rendering report...")
    start_time <- Sys.time()

    rmarkdown::render(
      input = template_file,
      output_file = basename(output_file),
      output_dir = output_dir,
      params = list(
        week = week,
        opponent = opponent,
        opponent_abbr = opponent_abbr,
        next_opponent = next_opponent,
        next_opponent_abbr = next_opponent_abbr
      ),
      quiet = FALSE
    )

    end_time <- Sys.time()
    elapsed <- round(difftime(end_time, start_time, units = "secs"), 1)

    message("\n========================================")
    message("Report Generated Successfully!")
    message("========================================")
    message("Location: ", output_file)
    message("Time: ", elapsed, " seconds")
    message("========================================\n")

    return(output_file)

  }, error = function(e) {
    message("\n========================================")
    message("ERROR: Report generation failed")
    message("========================================")
    message(e$message)
    message("========================================\n")
    stop(e)
  })
}

#' Generate Multiple Reports (Batch Processing)
#'
#' @param games_df Data frame with columns: week, opponent, opponent_abbr, next_opponent, next_opponent_abbr
#' @param config_file Path to config file
#' @param template_file Path to Rmd template
#' @param output_dir Output directory
#' @return Vector of paths to generated reports
generate_batch_reports <- function(games_df,
                                   config_file = "report_config.yaml",
                                   template_file = "BU_Post_2024.Rmd",
                                   output_dir = "./reports") {

  message("Generating ", nrow(games_df), " reports...")

  report_paths <- vector("character", nrow(games_df))

  for (i in 1:nrow(games_df)) {
    game <- games_df[i, ]

    message("\n\n##### REPORT ", i, " of ", nrow(games_df), " #####\n")

    report_paths[i] <- generate_weekly_report(
      week = game$week,
      opponent = game$opponent,
      opponent_abbr = game$opponent_abbr,
      next_opponent = game$next_opponent,
      next_opponent_abbr = game$next_opponent_abbr,
      config_file = config_file,
      template_file = template_file,
      output_dir = output_dir
    )
  }

  message("\n========================================")
  message("Batch Processing Complete!")
  message("========================================")
  message("Generated ", length(report_paths), " reports")
  message("========================================\n")

  return(report_paths)
}

#' Load Games from Config File
#'
#' @param config_file Path to config file
#' @return Data frame of games
load_games_from_config <- function(config_file = "report_config.yaml") {

  if (!file.exists(config_file)) {
    stop("Config file not found: ", config_file)
  }

  config <- yaml::read_yaml(config_file)

  if (is.null(config$games) || length(config$games) == 0) {
    stop("No games found in config file")
  }

  games_df <- do.call(rbind, lapply(config$games, function(game) {
    data.frame(
      week = game$week,
      opponent = game$opponent,
      opponent_abbr = game$opponent_abbr,
      next_opponent = game$next_opponent,
      next_opponent_abbr = game$next_opponent_abbr,
      stringsAsFactors = FALSE
    )
  }))

  return(games_df)
}

# ====================================================================
# COMMAND LINE INTERFACE
# ====================================================================

if (!interactive()) {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0) {
    cat("
Usage: Rscript generate_report.R [OPTIONS]

Options:
  --week N              Week number (required)
  --opponent NAME       Current opponent name (required)
  --opponent-abbr ABR   Opponent abbreviation (optional)
  --next NAME           Next opponent name (required)
  --next-abbr ABR       Next opponent abbreviation (optional)
  --config FILE         Config file path (default: report_config.yaml)
  --template FILE       Template file path (default: BU_Post_2024.Rmd)
  --output DIR          Output directory (default: ./reports)
  --force-reload        Force reload data from API
  --batch               Generate all reports from config file
  --help                Show this help message

Examples:
  # Generate single report
  Rscript generate_report.R --week 1 --opponent \"SMU\" --next \"Samford\"

  # Generate with custom config
  Rscript generate_report.R --week 1 --opponent \"SMU\" --next \"Samford\" --config my_config.yaml

  # Force reload data
  Rscript generate_report.R --week 1 --opponent \"SMU\" --next \"Samford\" --force-reload

  # Generate all reports from config
  Rscript generate_report.R --batch
")
    quit(status = 0)
  }

  # Parse arguments
  week <- NULL
  opponent <- NULL
  opponent_abbr <- NULL
  next_opponent <- NULL
  next_opponent_abbr <- NULL
  config_file <- "report_config.yaml"
  template_file <- "BU_Post_2024.Rmd"
  output_dir <- "./reports"
  force_reload <- FALSE
  batch_mode <- FALSE

  i <- 1
  while (i <= length(args)) {
    arg <- args[i]

    if (arg == "--week") {
      week <- as.numeric(args[i + 1])
      i <- i + 2
    } else if (arg == "--opponent") {
      opponent <- args[i + 1]
      i <- i + 2
    } else if (arg == "--opponent-abbr") {
      opponent_abbr <- args[i + 1]
      i <- i + 2
    } else if (arg == "--next") {
      next_opponent <- args[i + 1]
      i <- i + 2
    } else if (arg == "--next-abbr") {
      next_opponent_abbr <- args[i + 1]
      i <- i + 2
    } else if (arg == "--config") {
      config_file <- args[i + 1]
      i <- i + 2
    } else if (arg == "--template") {
      template_file <- args[i + 1]
      i <- i + 2
    } else if (arg == "--output") {
      output_dir <- args[i + 1]
      i <- i + 2
    } else if (arg == "--force-reload") {
      force_reload <- TRUE
      i <- i + 1
    } else if (arg == "--batch") {
      batch_mode <- TRUE
      i <- i + 1
    } else if (arg == "--help") {
      # Help already shown above
      quit(status = 0)
    } else {
      stop("Unknown argument: ", arg)
    }
  }

  # Generate report(s)
  if (batch_mode) {
    games_df <- load_games_from_config(config_file)
    generate_batch_reports(games_df, config_file, template_file, output_dir)
  } else {
    # Validate required arguments
    if (is.null(week) || is.null(opponent) || is.null(next_opponent)) {
      stop("Missing required arguments. Use --help for usage information.")
    }

    generate_weekly_report(
      week = week,
      opponent = opponent,
      opponent_abbr = opponent_abbr,
      next_opponent = next_opponent,
      next_opponent_abbr = next_opponent_abbr,
      config_file = config_file,
      template_file = template_file,
      output_dir = output_dir,
      force_reload = force_reload
    )
  }
}
