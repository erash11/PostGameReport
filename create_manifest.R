#!/usr/bin/env Rscript
# ====================================================================
# CREATE MANIFEST.JSON FOR POSIT CONNECT DEPLOYMENT
# ====================================================================
#
# Purpose: Generate manifest.json file required by Posit Connect
#          when deploying from GitHub
#
# Usage:
#   Rscript create_manifest.R
#
# What this does:
#   1. Installs/loads rsconnect package
#   2. Generates manifest.json with all required dependencies
#   3. Lists all app files needed for deployment
#   4. Tells you what to do next (commit and push)
#
# When to run this:
#   - Before your first deployment to Posit Connect
#   - After adding new R packages to your app
#   - If manifest.json gets corrupted or deleted
#
# ====================================================================

cat("====================================================================\n")
cat("CREATING MANIFEST.JSON FOR POSIT CONNECT\n")
cat("====================================================================\n\n")

# Step 1: Install/load rsconnect
cat("Step 1: Checking rsconnect package...\n")
if (!require("rsconnect", quietly = TRUE)) {
  cat("  Installing rsconnect...\n")
  install.packages("rsconnect", repos = "https://cran.rstudio.com/")
}
library(rsconnect)
cat("  ✓ rsconnect loaded\n\n")

# Step 2: Generate manifest.json
cat("Step 2: Generating manifest.json...\n")

# Define all files needed for deployment
app_files <- c(
  "app.R",                    # PRIMARY FILE - Shiny app
  "helper_functions.R",       # Reusable functions
  "data_loader.R",           # Caching system
  "feature_analytics.R",     # Advanced analytics
  "generate_report.R",       # Report generation
  "BU_Post_2024.Rmd",        # Report template
  "report_config.yaml",      # Configuration
  "TSU.png"                  # Logo image
)

# Create manifest
rsconnect::writeManifest(
  appDir = ".",
  appFiles = app_files,
  appPrimaryDoc = "app.R"
)

cat("  ✓ manifest.json created\n\n")

# Step 3: Verify manifest exists
cat("Step 3: Verifying manifest.json...\n")
if (file.exists("manifest.json")) {
  cat("  ✓ manifest.json file confirmed\n")

  # Show file size
  file_size <- file.info("manifest.json")$size
  cat(sprintf("  ✓ File size: %d bytes\n", file_size))

  # Show basic info
  manifest_data <- jsonlite::fromJSON("manifest.json")
  num_packages <- length(manifest_data$packages)
  cat(sprintf("  ✓ Packages listed: %d\n", num_packages))

} else {
  cat("  ✗ ERROR: manifest.json was not created\n")
  stop("Failed to create manifest.json")
}

cat("\n====================================================================\n")
cat("SUCCESS! manifest.json has been created.\n")
cat("====================================================================\n\n")

cat("NEXT STEPS:\n\n")
cat("1. Commit the manifest.json file to Git:\n")
cat("   git add manifest.json\n")
cat("   git commit -m \"Add manifest.json for Posit Connect deployment\"\n\n")
cat("2. Push to GitHub:\n")
cat("   git push\n\n")
cat("3. Now deploy to Posit Connect from GitHub\n")
cat("   The manifest.json will be included automatically!\n\n")

cat("====================================================================\n")
cat("IMPORTANT NOTES:\n")
cat("====================================================================\n\n")
cat("- Run this script LOCALLY (on your computer), not in Posit Cloud\n")
cat("- Run it whenever you add new R packages to your app\n")
cat("- Keep manifest.json in your Git repository (don't ignore it)\n")
cat("- Posit Connect needs this file to know which packages to install\n\n")

cat("Questions? See:\n")
cat("  - FIX_POSIT_CONNECT_MANIFEST.md\n")
cat("  - DEPLOY_POSIT_CONNECT.md\n\n")

cat("✓ All done! Follow the steps above to complete deployment.\n\n")
