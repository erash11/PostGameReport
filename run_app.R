#!/usr/bin/env Rscript
# ====================================================================
# SHINY APP LAUNCHER
# ====================================================================
# Simple script to launch the Shiny app
# Usage: Rscript run_app.R
# Or from R console: source("run_app.R")
# ====================================================================

# Check and install required packages
required_packages <- c(
  "shiny",
  "shinythemes",
  "shinyWidgets",
  "DT",
  "dplyr",
  "cfbfastR",
  "rmarkdown",
  "pagedown"
)

# Function to check and install packages
check_packages <- function(packages) {
  missing <- packages[!(packages %in% installed.packages()[,"Package"])]

  if(length(missing) > 0) {
    cat("Installing missing packages:", paste(missing, collapse = ", "), "\n")
    install.packages(missing, repos = "https://cloud.r-project.org/")
  }
}

# Check packages
cat("Checking required packages...\n")
check_packages(required_packages)

# Load shiny
library(shiny)

# Run the app
cat("\n")
cat("========================================\n")
cat("  Baylor Football Analytics App\n")
cat("========================================\n")
cat("\n")
cat("Launching Shiny app...\n")
cat("\n")
cat("The app will open in your default web browser.\n")
cat("Press Ctrl+C (or Cmd+C on Mac) to stop the app.\n")
cat("\n")
cat("========================================\n")
cat("\n")

# Launch app
runApp(
  appDir = ".",
  launch.browser = TRUE,
  host = "127.0.0.1",
  port = NULL  # Automatically find available port
)
