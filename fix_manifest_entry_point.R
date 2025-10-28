# ====================================================================
# CRITICAL FIX: Deployment Running Wrong File
# ====================================================================
#
# If Posit Connect is trying to run generate_report.R instead of app.R,
# your manifest.json has the wrong entry point.
#
# This script ensures manifest.json points to app.R (the Shiny app)
# NOT generate_report.R (the command-line script)
# ====================================================================

cat("====================================================================\n")
cat("FIXING MANIFEST.JSON - SETTING CORRECT ENTRY POINT\n")
cat("====================================================================\n\n")

# Check if we're in the right directory
if (!file.exists("app.R")) {
  stop("ERROR: app.R not found! Make sure you're in the PostGameReport directory.")
}

cat("✓ Found app.R\n\n")

# Install/load required packages
cat("Step 1: Loading rsconnect...\n")
if (!require("rsconnect", quietly = TRUE)) {
  cat("  Installing rsconnect...\n")
  install.packages("rsconnect", repos = "https://cran.rstudio.com/")
}
library(rsconnect)
cat("  ✓ rsconnect loaded\n\n")

# Delete old manifest if it exists
cat("Step 2: Removing old manifest.json (if exists)...\n")
if (file.exists("manifest.json")) {
  file.remove("manifest.json")
  cat("  ✓ Deleted old manifest.json\n\n")
} else {
  cat("  No old manifest found\n\n")
}

# Generate NEW manifest with CORRECT entry point
cat("Step 3: Generating NEW manifest.json...\n")
cat("  Primary file: app.R (the Shiny web app)\n")
cat("  NOT: generate_report.R (command-line script)\n\n")

rsconnect::writeManifest(
  appDir = ".",
  appFiles = c(
    "app.R",                    # PRIMARY FILE - THIS IS THE SHINY APP
    "helper_functions.R",
    "data_loader.R",
    "feature_analytics.R",
    "generate_report.R",        # Used by app.R, but NOT the entry point
    "BU_Post_2024.Rmd",
    "report_config.yaml",
    "TSU.png"
  ),
  appPrimaryDoc = "app.R"       # CRITICAL: This must be app.R!
)

cat("  ✓ manifest.json created\n\n")

# Verify the manifest
cat("Step 4: Verifying manifest.json...\n")
if (file.exists("manifest.json")) {

  # Read and check the manifest
  manifest <- jsonlite::fromJSON("manifest.json")

  # Check metadata
  if (!is.null(manifest$metadata$entrypoint)) {
    entry <- manifest$metadata$entrypoint
    cat(sprintf("  Entry point: %s\n", entry))

    if (entry == "app.R") {
      cat("  ✓✓✓ CORRECT! Entry point is app.R\n")
    } else {
      cat("  ✗✗✗ WRONG! Entry point should be app.R\n")
      stop("ERROR: manifest.json has wrong entry point!")
    }
  }

  # Check package count
  num_packages <- length(manifest$packages)
  cat(sprintf("  Packages listed: %d\n", num_packages))

  if (num_packages < 20) {
    cat("  ⚠ WARNING: Too few packages. Did all packages install?\n")
  } else {
    cat("  ✓ Good number of packages\n")
  }

  cat("\n")

} else {
  stop("ERROR: manifest.json was not created!")
}

cat("====================================================================\n")
cat("SUCCESS! manifest.json is now configured correctly.\n")
cat("====================================================================\n\n")

cat("VERIFY THIS:\n")
cat("  Entry Point: app.R (the Shiny web app)\n")
cat("  NOT: generate_report.R (command-line script)\n\n")

cat("NEXT STEPS:\n\n")
cat("1. Commit and push to GitHub:\n")
cat("   git add manifest.json\n")
cat("   git commit -m 'Fix manifest.json - set app.R as entry point'\n")
cat("   git push\n\n")

cat("2. Deploy to Posit Connect:\n")
cat("   - Delete any old/failed deployments\n")
cat("   - Create NEW deployment from GitHub\n")
cat("   - Content Type: Shiny Application\n")
cat("   - Primary Document: app.R (NOT generate_report.R!)\n\n")

cat("3. If it still tries to run generate_report.R:\n")
cat("   - In Posit Connect, go to deployment settings\n")
cat("   - Look for 'Primary Document' or 'Entry Point'\n")
cat("   - Change it to: app.R\n")
cat("   - Redeploy\n\n")

cat("====================================================================\n")
cat("Why this matters:\n")
cat("====================================================================\n\n")
cat("app.R              = Shiny web application (interactive website)\n")
cat("generate_report.R  = Command-line script (needs arguments)\n\n")
cat("Posit Connect needs to run app.R, which provides the web interface.\n")
cat("The app.R file will then call generate_report.R internally when needed.\n\n")

cat("✓ All done! Follow the steps above.\n\n")
