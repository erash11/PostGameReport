# ====================================================================
# DATA LOADING AND CACHING MODULE
# ====================================================================
# This file handles data loading with caching to improve performance
# ====================================================================

library(cfbfastR)

# ====================================================================
# API KEY SETUP
# ====================================================================
# Register CFBD API key if available in environment
# Get your free API key at: https://collegefootballdata.com/
# Set the CFBD_API_KEY environment variable in Posit Connect

cfbd_api_key <- Sys.getenv("CFBD_API_KEY")

if (nzchar(cfbd_api_key)) {
  # Register the API key with cfbfastR
  tryCatch({
    cfbfastR::register_cfbd(api_key = cfbd_api_key)
    message("✓ CFBD API key registered successfully")
  }, error = function(e) {
    warning("Failed to register CFBD API key: ", e$message)
  })
} else {
  warning(
    "CFBD_API_KEY environment variable not set.\n",
    "  Get a free API key at: https://collegefootballdata.com/\n",
    "  Set it as an environment variable in Posit Connect settings."
  )
}

#' Load CFB Play-by-Play Data with Caching
#'
#' @param season Season year (default: 2025)
#' @param force_reload Logical, force reload from API (default: FALSE)
#' @param cache_dir Directory for cache files (default: "./cache")
#' @return Play-by-play data
load_cfb_data_cached <- function(season = 2025, force_reload = FALSE, cache_dir = "./cache") {

  # Create cache directory if it doesn't exist
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
    message("Created cache directory: ", cache_dir)
  }

  cache_file <- file.path(cache_dir, paste0("cfb_pbp_", season, ".rds"))

  # Check if cache exists and is recent (less than 1 day old)
  if (file.exists(cache_file) && !force_reload) {
    file_age <- difftime(Sys.time(), file.info(cache_file)$mtime, units = "hours")

    if (file_age < 24) {
      message("Loading data from cache (", round(file_age, 1), " hours old)...")
      data <- readRDS(cache_file)
      message("Loaded ", nrow(data), " plays from cache")
      return(data)
    } else {
      message("Cache is older than 24 hours, reloading from API...")
    }
  }

  # Load from API
  message("Loading play-by-play data from cfbfastR API...")
  data <- load_cfb_pbp(seasons = season, epa_wpa = TRUE)

  # Save to cache
  saveRDS(data, cache_file)
  message("Saved ", nrow(data), " plays to cache")
  message("Cache location: ", cache_file)

  return(data)
}

#' Load Team Info with Caching
#'
#' @param force_reload Logical, force reload from API
#' @param cache_dir Directory for cache files
#' @return Team info data
load_team_info_cached <- function(force_reload = FALSE, cache_dir = "./cache") {

  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  cache_file <- file.path(cache_dir, "team_info.rds")

  # Check if cache exists and is recent (less than 7 days old)
  if (file.exists(cache_file) && !force_reload) {
    file_age <- difftime(Sys.time(), file.info(cache_file)$mtime, units = "days")

    if (file_age < 7) {
      message("Loading team info from cache...")
      return(readRDS(cache_file))
    }
  }

  # Load from API
  message("Loading team info from cfbfastR API...")
  team_info <- cfbd_team_info()

  # Save to cache
  saveRDS(team_info, cache_file)
  message("Saved team info to cache")

  return(team_info)
}

#' Clear Cache Files
#'
#' @param cache_dir Directory for cache files
#' @param season Optional, specific season to clear (NULL clears all)
clear_cache <- function(cache_dir = "./cache", season = NULL) {

  if (!dir.exists(cache_dir)) {
    message("Cache directory does not exist")
    return(invisible())
  }

  if (is.null(season)) {
    # Clear all cache files
    cache_files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)
    message("Clearing ", length(cache_files), " cache files...")
    file.remove(cache_files)
    message("Cache cleared")
  } else {
    # Clear specific season
    cache_file <- file.path(cache_dir, paste0("cfb_pbp_", season, ".rds"))
    if (file.exists(cache_file)) {
      file.remove(cache_file)
      message("Cleared cache for season ", season)
    } else {
      message("No cache file found for season ", season)
    }
  }
}

#' Get Cache Status
#'
#' @param cache_dir Directory for cache files
#' @return Data frame with cache status
get_cache_status <- function(cache_dir = "./cache") {

  if (!dir.exists(cache_dir)) {
    message("Cache directory does not exist")
    return(data.frame())
  }

  cache_files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(cache_files) == 0) {
    message("No cache files found")
    return(data.frame())
  }

  status <- data.frame(
    file = basename(cache_files),
    size_mb = round(file.size(cache_files) / 1024^2, 2),
    modified = file.info(cache_files)$mtime,
    age_hours = round(difftime(Sys.time(), file.info(cache_files)$mtime, units = "hours"), 1)
  )

  return(status)
}
