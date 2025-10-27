#!/usr/bin/env Rscript
# ====================================================================
# DEPLOYMENT PREPARATION SCRIPT
# ====================================================================
# Prepares the Shiny app for deployment to shinyapps.io or other hosts
# Usage: source("prepare_deployment.R")
# ====================================================================

cat("\n")
cat("========================================\n")
cat("  Deployment Preparation\n")
cat("========================================\n")
cat("\n")

# ====================================================================
# 1. CHECK REQUIRED PACKAGES
# ====================================================================

cat("Step 1: Checking required packages...\n")

required_packages <- c(
  # Shiny packages
  "shiny",
  "shinythemes",
  "shinyWidgets",
  "DT",

  # Data manipulation
  "dplyr",
  "tidyr",

  # Visualization
  "ggplot2",
  "ggimage",
  "cowplot",
  "magick",

  # College football data
  "cfbfastR",

  # Report generation
  "rmarkdown",
  "pagedown",
  "flextable",
  "officer",

  # Other
  "yaml",
  "scales",
  "janitor",

  # Deployment (optional but recommended)
  "rsconnect"
)

missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(missing_packages) > 0) {
  cat("  WARNING: Missing packages:\n")
  for(pkg in missing_packages) {
    cat("    -", pkg, "\n")
  }
  cat("\n")

  answer <- readline("Install missing packages? (y/n): ")

  if(tolower(answer) == "y") {
    cat("  Installing missing packages...\n")
    install.packages(missing_packages, repos = "https://cloud.r-project.org/")
    cat("  ✓ Packages installed\n")
  } else {
    cat("  ✗ Deployment may fail without required packages\n")
  }
} else {
  cat("  ✓ All required packages installed\n")
}

cat("\n")

# ====================================================================
# 2. CHECK REQUIRED FILES
# ====================================================================

cat("Step 2: Checking required files...\n")

required_files <- c(
  "app.R",
  "helper_functions.R",
  "data_loader.R",
  "feature_analytics.R",
  "generate_report.R",
  "BU_Post_2024.Rmd",
  "report_config.yaml"
)

missing_files <- c()

for(file in required_files) {
  if(file.exists(file)) {
    cat("  ✓", file, "\n")
  } else {
    cat("  ✗", file, "(MISSING)\n")
    missing_files <- c(missing_files, file)
  }
}

if(length(missing_files) > 0) {
  cat("\n  ERROR: Missing required files. Cannot deploy.\n")
  stop("Deployment cancelled: Missing files")
}

cat("\n")

# ====================================================================
# 3. PRE-CACHE DATA (RECOMMENDED)
# ====================================================================

cat("Step 3: Pre-caching data...\n")
cat("  This will download data from cfbfastR and cache it.\n")
cat("  Deploying with cached data makes the app start faster.\n")
cat("\n")

answer <- readline("Pre-cache data for deployment? (y/n): ")

if(tolower(answer) == "y") {

  cat("  Loading data_loader.R...\n")
  source("data_loader.R")

  cat("  Downloading CFB play-by-play data (this may take 30-60 seconds)...\n")

  tryCatch({
    data_orig <- load_cfb_data_cached(season = 2025, force_reload = FALSE)
    cat("  ✓ Play-by-play data cached (", nrow(data_orig), " plays)\n", sep = "")

    team_info <- load_team_info_cached(force_reload = FALSE)
    cat("  ✓ Team info cached (", nrow(team_info), " teams)\n", sep = "")

  }, error = function(e) {
    cat("  ✗ Error caching data:", e$message, "\n")
    cat("  WARNING: App will download data on first run (slower start)\n")
  })
} else {
  cat("  ⊗ Skipped. App will download data on first run.\n")
}

cat("\n")

# ====================================================================
# 4. CHECK CACHE STATUS
# ====================================================================

cat("Step 4: Checking cache status...\n")

if(dir.exists("./cache")) {
  cache_files <- list.files("./cache", pattern = "\\.rds$", full.names = TRUE)

  if(length(cache_files) > 0) {
    total_size <- sum(file.size(cache_files)) / 1024^2  # MB

    cat("  ✓ Cache directory exists\n")
    cat("  ✓", length(cache_files), "cache file(s) found\n")
    cat("  ✓ Total cache size:", round(total_size, 2), "MB\n")

    cat("\n  Cache files:\n")
    for(file in cache_files) {
      size_mb <- round(file.size(file) / 1024^2, 2)
      cat("    -", basename(file), "(", size_mb, "MB )\n")
    }

  } else {
    cat("  ⊗ Cache directory exists but no cache files\n")
    cat("  App will download data on first run\n")
  }
} else {
  cat("  ⊗ No cache directory\n")
  cat("  App will create cache on first run\n")
}

cat("\n")

# ====================================================================
# 5. CREATE DEPLOYMENT FILE LIST
# ====================================================================

cat("Step 5: Creating deployment file list...\n")

deploy_files <- required_files

# Add cache files if they exist
if(dir.exists("./cache")) {
  cache_files <- list.files("./cache", pattern = "\\.rds$", full.names = FALSE)
  if(length(cache_files) > 0) {
    deploy_files <- c(deploy_files, file.path("cache", cache_files))
    cat("  ✓ Including", length(cache_files), "cache file(s)\n")
  }
}

# Add custom logos if they exist
if(file.exists("TSU.png")) {
  deploy_files <- c(deploy_files, "TSU.png")
  cat("  ✓ Including TSU.png\n")
}

# Save deployment file list
deployment_manifest <- list(
  files = deploy_files,
  timestamp = Sys.time(),
  r_version = R.version.string
)

saveRDS(deployment_manifest, ".deployment_manifest.rds")
cat("  ✓ Deployment manifest created\n")

cat("\n")

# ====================================================================
# 6. CHECK rsconnect SETUP
# ====================================================================

cat("Step 6: Checking rsconnect configuration...\n")

if("rsconnect" %in% installed.packages()[,"Package"]) {

  library(rsconnect)

  accounts <- rsconnect::accounts()

  if(nrow(accounts) > 0) {
    cat("  ✓ rsconnect configured\n")
    cat("  ✓ Connected accounts:\n")
    for(i in 1:nrow(accounts)) {
      cat("    -", accounts$name[i], "(", accounts$server[i], ")\n")
    }
  } else {
    cat("  ⊗ rsconnect installed but not configured\n")
    cat("\n")
    cat("  To configure:\n")
    cat("    1. Go to https://www.shinyapps.io/\n")
    cat("    2. Sign in or create account\n")
    cat("    3. Click your name > Tokens\n")
    cat("    4. Copy the setAccountInfo() command\n")
    cat("    5. Paste and run in R console\n")
  }

} else {
  cat("  ⊗ rsconnect not installed\n")
  cat("  Install with: install.packages('rsconnect')\n")
}

cat("\n")

# ====================================================================
# 7. TEST APP LOCALLY
# ====================================================================

cat("Step 7: Testing app locally...\n")

answer <- readline("Test app in browser before deploying? (y/n): ")

if(tolower(answer) == "y") {
  cat("  Launching app...\n")
  cat("  Close the browser and press Ctrl+C to continue\n")
  cat("\n")

  library(shiny)
  runApp(".", launch.browser = TRUE)

} else {
  cat("  ⊗ Skipped local test\n")
  cat("  WARNING: Recommended to test locally before deploying\n")
}

cat("\n")

# ====================================================================
# 8. GENERATE DEPLOYMENT COMMANDS
# ====================================================================

cat("Step 8: Deployment commands\n")
cat("\n")

cat("========================================\n")
cat("  Ready to Deploy!\n")
cat("========================================\n")
cat("\n")

cat("Option 1: Deploy with default settings\n")
cat("----------------------------------------\n")
cat("library(rsconnect)\n")
cat("deployApp(\n")
cat("  appName = 'baylor-football-analytics',\n")
cat("  appTitle = 'Baylor Football Analytics'\n")
cat(")\n")
cat("\n")

cat("Option 2: Deploy with specific files\n")
cat("----------------------------------------\n")
cat("library(rsconnect)\n")
cat("deployApp(\n")
cat("  appName = 'baylor-football-analytics',\n")
cat("  appTitle = 'Baylor Football Analytics',\n")
cat("  appFiles = c(\n")
for(i in 1:length(deploy_files)) {
  comma <- ifelse(i < length(deploy_files), ",", "")
  cat("    '", deploy_files[i], "'", comma, "\n", sep = "")
}
cat("  ),\n")
cat("  forceUpdate = TRUE\n")
cat(")\n")
cat("\n")

cat("Option 3: Save deployment script\n")
cat("----------------------------------------\n")

answer <- readline("Save deployment script to deploy_app.R? (y/n): ")

if(tolower(answer) == "y") {

  deploy_script <- paste0(
    "# Auto-generated deployment script\n",
    "# Generated: ", Sys.time(), "\n\n",
    "library(rsconnect)\n\n",
    "deployApp(\n",
    "  appName = 'baylor-football-analytics',\n",
    "  appTitle = 'Baylor Football Analytics',\n",
    "  appFiles = c(\n"
  )

  for(i in 1:length(deploy_files)) {
    comma <- ifelse(i < length(deploy_files), ",", "")
    deploy_script <- paste0(deploy_script, "    '", deploy_files[i], "'", comma, "\n")
  }

  deploy_script <- paste0(
    deploy_script,
    "  ),\n",
    "  forceUpdate = TRUE,\n",
    "  launch.browser = TRUE\n",
    ")\n"
  )

  writeLines(deploy_script, "deploy_app.R")

  cat("  ✓ Deployment script saved to deploy_app.R\n")
  cat("  Run with: source('deploy_app.R')\n")

} else {
  cat("  ⊗ Deployment script not saved\n")
}

cat("\n")

# ====================================================================
# 9. DEPLOYMENT CHECKLIST
# ====================================================================

cat("========================================\n")
cat("  Deployment Checklist\n")
cat("========================================\n")
cat("\n")

checklist <- data.frame(
  Item = c(
    "Required packages installed",
    "Required files present",
    "Data pre-cached",
    "rsconnect configured",
    "App tested locally",
    "Deployment script ready"
  ),
  Status = c(
    ifelse(length(missing_packages) == 0, "✓", "✗"),
    ifelse(length(missing_files) == 0, "✓", "✗"),
    ifelse(dir.exists("./cache") && length(list.files("./cache", pattern = "\\.rds$")) > 0, "✓", "⊗"),
    ifelse("rsconnect" %in% installed.packages()[,"Package"] && nrow(rsconnect::accounts()) > 0, "✓", "⊗"),
    "▢",  # User needs to confirm
    ifelse(file.exists("deploy_app.R"), "✓", "⊗")
  ),
  stringsAsFactors = FALSE
)

for(i in 1:nrow(checklist)) {
  cat(checklist$Status[i], checklist$Item[i], "\n")
}

cat("\n")

# ====================================================================
# 10. FINAL INSTRUCTIONS
# ====================================================================

cat("========================================\n")
cat("  Next Steps\n")
cat("========================================\n")
cat("\n")

cat("1. If rsconnect not configured:\n")
cat("   - Go to https://www.shinyapps.io/\n")
cat("   - Create account (free tier available)\n")
cat("   - Get token and run setAccountInfo()\n")
cat("\n")

cat("2. Deploy the app:\n")
if(file.exists("deploy_app.R")) {
  cat("   source('deploy_app.R')\n")
} else {
  cat("   library(rsconnect)\n")
  cat("   deployApp(appName = 'baylor-football-analytics')\n")
}
cat("\n")

cat("3. After deployment:\n")
cat("   - Test the live app\n")
cat("   - Share the URL with your team\n")
cat("   - Monitor usage in shinyapps.io dashboard\n")
cat("\n")

cat("========================================\n")
cat("  Preparation Complete!\n")
cat("========================================\n")
cat("\n")

cat("For detailed deployment instructions, see:\n")
cat("  - DEPLOYMENT_GUIDE.md\n")
cat("  - https://docs.posit.co/shinyapps.io/\n")
cat("\n")

# Return deployment info
invisible(list(
  files = deploy_files,
  packages = required_packages,
  manifest = deployment_manifest
))
