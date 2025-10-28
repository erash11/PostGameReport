# Generate manifest.json Using Posit Cloud

**This is the EASIEST and MOST RELIABLE way to create manifest.json for Posit Connect deployment.**

---

## Step-by-Step Instructions

### Step 1: Open Your Project in Posit Cloud

1. Go to **https://posit.cloud/**
2. Sign in (or create a free account)
3. Click **"New Project"** → **"New Project from Git Repository"**
4. Enter repository URL:
   ```
   https://github.com/erash11/PostGameReport
   ```
5. Click **"OK"**

**Important:** Make sure you're on the branch `claude/code-optimization-review-011CUYDAbmFRqz9wGSzVMsoD`

To check/switch branches in Posit Cloud:
- Look at the Git panel (top right)
- Or run in Terminal: `git checkout claude/code-optimization-review-011CUYDAbmFRqz9wGSzVMsoD`

---

### Step 2: Install All Required Packages

In the **R Console** (bottom left panel), copy and paste this:

```r
# Install all required packages
# This may take 5-10 minutes - be patient!
install.packages(c(
  "shiny",
  "shinythemes",
  "dplyr",
  "ggplot2",
  "cfbfastR",
  "rmarkdown",
  "yaml",
  "gt",
  "tidyr",
  "jsonlite",
  "scales",
  "ggrepel",
  "rsconnect"
))
```

**Wait for it to finish!** You'll see messages like:
```
* DONE (shiny)
* DONE (dplyr)
...
```

When you see the `>` prompt again, it's done.

---

### Step 3: Generate manifest.json ⚠️ CRITICAL STEP

Still in the **R Console**, run this **EXACT** command:

```r
# Generate the complete manifest with ALL dependencies
# CRITICAL: appPrimaryDoc MUST be "app.R" (the Shiny app)
rsconnect::writeManifest(
  appDir = ".",
  appFiles = c(
    "app.R",                    # PRIMARY FILE - the Shiny web app
    "helper_functions.R",
    "data_loader.R",
    "feature_analytics.R",
    "generate_report.R",        # Used by app.R, but NOT the entry point
    "BU_Post_2024.Rmd",
    "report_config.yaml",
    "TSU.png"
  ),
  appPrimaryDoc = "app.R"       # MUST BE app.R - this is the Shiny app!
)
```

**CRITICAL:** The `appPrimaryDoc = "app.R"` line tells Posit Connect to run the **Shiny web app** (app.R), NOT the command-line script (generate_report.R).

You should see:
```
✓ Created manifest.json
```

**Check it was created:** Look in the Files panel (bottom right) - you should see `manifest.json`

---

### Step 4: Verify the manifest.json

Quick check - in the R Console:

```r
# See how many packages are listed
manifest <- jsonlite::fromJSON("manifest.json")
length(manifest$packages)
```

You should see a number like **40-60** packages. If you see less than 20, something went wrong.

---

### Step 5: Commit and Push to GitHub

Open the **Terminal** in Posit Cloud:
- Click: **Tools** → **Terminal** → **New Terminal**

Then run these commands:

```bash
# Configure git (only needed first time)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add the manifest file
git add manifest.json

# Commit it
git commit -m "Add complete manifest.json with all dependencies for Posit Connect"

# Push to GitHub
git push origin claude/code-optimization-review-011CUYDAbmFRqz9wGSzVMsoD
```

**Note:** You may need to authenticate with GitHub. If it asks for credentials:
- Username: your GitHub username
- Password: use a Personal Access Token (not your password)
  - Generate token at: https://github.com/settings/tokens

---

### Step 6: Verify on GitHub

Go to your repository on GitHub and verify:
- `manifest.json` appears in the file list
- Open it and check it's ~500-1000 lines (a complete manifest is big!)
- It should list many packages like `cli`, `glue`, `rlang`, etc.

---

### Step 7: Deploy to Posit Connect ⚠️ IMPORTANT SETTINGS

Now you're ready! Deploy from GitHub to Posit Connect:

1. Go to **Posit Connect** (connect.posit.cloud)
2. Click **"Publish"** → **"Import from Git"**
3. Select your repository
4. Branch: `claude/code-optimization-review-011CUYDAbmFRqz9wGSzVMsoD`
5. **Content Type:** ⚠️ **Shiny Application** (not R Markdown!)
6. **Primary Document:** ⚠️ **app.R** (NOT generate_report.R!)
7. Click **"Deploy"**

**CRITICAL:** Make absolutely sure:
- ✅ Content Type = "Shiny Application"
- ✅ Primary Document = "app.R"
- ❌ NOT "generate_report.R" (that's a command-line script)

This time it should work! The complete manifest.json will tell Posit Connect to install all ~50+ packages with their dependencies, and it will run app.R (the Shiny web app).

---

## Troubleshooting

### "Package installation failed" in Step 2
- **Solution:** Try installing packages one at a time to identify which one is failing
- Some packages may need system dependencies - Posit Cloud should handle this automatically

### "Git push failed - permission denied"
- **Solution:** You need to set up authentication
- Use a Personal Access Token: https://github.com/settings/tokens
- Or set up SSH keys in Posit Cloud

### "manifest.json already exists"
- **Solution:** Delete the old one first:
  ```r
  file.remove("manifest.json")
  ```
- Then run the `writeManifest()` command again

### "Your application failed to start" - Trying to run generate_report.R
**This is the most common error!**

**Symptom:** Logs show generate_report.R usage help (--week, --opponent, etc.)

**Cause:** Deployment is trying to run the command-line script instead of the Shiny app

**Solutions:**
1. **Delete old manifest and regenerate:**
   ```r
   # In Posit Cloud R Console
   file.remove("manifest.json")
   source("fix_manifest_entry_point.R")  # This creates correct manifest
   ```

2. **Check Posit Connect deployment settings:**
   - Delete any failed/old deployments
   - Create a NEW deployment
   - When deploying, explicitly select:
     - Content Type: "Shiny Application"
     - Primary Document: "app.R"

3. **Verify manifest.json is correct:**
   ```r
   # In Posit Cloud R Console
   manifest <- jsonlite::fromJSON("manifest.json")
   manifest$metadata$entrypoint  # Should say "app.R"
   ```

### Still getting deployment errors?
- Check the Posit Connect logs carefully
- Make sure `app.R` exists and has `shinyApp(ui = ui, server = server)` at the end
- Verify all files listed in `appFiles` actually exist
- Try using the fix_manifest_entry_point.R script

---

## Why This Works

When you run `rsconnect::writeManifest()` in Posit Cloud:
- It scans your R files for package dependencies
- It looks at your **installed packages** to get exact versions
- It builds the **complete dependency tree** (all 40-60+ packages)
- It creates checksums for all files
- It specifies that `app.R` is the primary entry point

Posit Connect can then recreate this exact environment when deploying!

---

## Success!

Once deployed, your Shiny app will be live at a URL like:
```
https://connect.posit.cloud/content/your-content-id/
```

Share this URL with anyone who needs to generate Baylor football reports!

---

**Questions?** See:
- [DEPLOY_POSIT_CONNECT.md](DEPLOY_POSIT_CONNECT.md) - Full deployment guide
- [TROUBLESHOOTING_DEPLOYMENT.md](TROUBLESHOOTING_DEPLOYMENT.md) - Common issues
