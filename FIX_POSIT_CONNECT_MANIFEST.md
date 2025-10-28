# 🔧 Fix: Posit Connect "manifest.json required" Error

**Quick fix for deploying to Posit Connect (connect.posit.cloud)**

---

## ⚡ **QUICK FIX - Run This Now!**

In your R console (in Posit Cloud or RStudio):

```r
# Install rsconnect if needed
if (!require("rsconnect")) install.packages("rsconnect")

# Create the manifest.json file
rsconnect::writeManifest(appDir = ".")

# Now try publishing again from the UI
# Or deploy via code:
library(rsconnect)
rsconnect::deployApp(
  appDir = ".",
  appName = "baylor-football-analytics",
  server = "connect.posit.cloud",
  forceUpdate = TRUE
)
```

**This should fix it!**

---

## 📋 **Step-by-Step Fix**

### **Step 1: Generate manifest.json**

```r
# Load rsconnect
library(rsconnect)

# Create manifest in your project directory
rsconnect::writeManifest(
  appDir = ".",
  appFiles = c(
    "app.R",
    "helper_functions.R",
    "data_loader.R",
    "feature_analytics.R",
    "generate_report.R",
    "BU_Post_2024.Rmd",
    "report_config.yaml",
    "TSU.png"
  )
)
```

### **Step 2: Commit the manifest (if using Git)**

```r
# In terminal or R console
system("git add manifest.json")
system("git commit -m 'Add manifest.json for Posit Connect deployment'")
system("git push")
```

### **Step 3: Try Publishing Again**

**Option A: Via RStudio/Posit Cloud UI**
1. Click the "Publish" button again
2. Should work now!

**Option B: Via Code**
```r
library(rsconnect)

rsconnect::deployApp(
  appDir = ".",
  appName = "baylor-football-analytics",
  server = "connect.posit.cloud",
  forceUpdate = TRUE
)
```

---

## 🎯 **What This Does**

The `manifest.json` file tells Posit Connect:
- Which R packages your app needs
- Which versions to install
- Package dependencies
- R version requirements

**It's automatically generated from your code.**

---

## 🔍 **Why This Happened**

Posit Connect requires a manifest file to:
1. Know which packages to install
2. Ensure reproducible deployments
3. Cache dependencies for faster startup

**Solution:** Generate it once with `writeManifest()`, then commit it to Git.

---

## ✅ **Complete Fix Script**

Run this entire script in R console:

```r
# ====================================================================
# FIX POSIT CONNECT MANIFEST ERROR
# ====================================================================

cat("Fixing Posit Connect manifest.json error...\n\n")

# Step 1: Install/load rsconnect
if (!require("rsconnect")) {
  cat("Installing rsconnect...\n")
  install.packages("rsconnect")
}
library(rsconnect)
cat("✓ rsconnect loaded\n\n")

# Step 2: Create manifest.json
cat("Creating manifest.json...\n")
rsconnect::writeManifest(
  appDir = ".",
  appFiles = c(
    "app.R",
    "helper_functions.R",
    "data_loader.R",
    "feature_analytics.R",
    "generate_report.R",
    "BU_Post_2024.Rmd",
    "report_config.yaml",
    "TSU.png"
  ),
  appPrimaryDoc = "app.R"
)
cat("✓ manifest.json created\n\n")

# Step 3: Verify manifest exists
if (file.exists("manifest.json")) {
  cat("✓ manifest.json file confirmed\n\n")
} else {
  stop("❌ manifest.json was not created")
}

# Step 4: Deploy
cat("Deploying to Posit Connect...\n")
rsconnect::deployApp(
  appDir = ".",
  appName = "baylor-football-analytics",
  server = "connect.posit.cloud",
  forceUpdate = TRUE,
  launch.browser = TRUE
)

cat("\n✓ Deployment complete!\n")
```

---

## 📝 **Alternative: Use Publish Button After Creating Manifest**

If you prefer the UI:

```r
# Just create the manifest
rsconnect::writeManifest(appDir = ".")

# Then click "Publish" button in RStudio/Posit Cloud
# The manifest will be included automatically
```

---

## 🆘 **Still Getting Errors?**

### **Error: "Package X not found"**

**Solution:** Make sure all packages are loaded in `app.R`:

```r
# At the top of app.R, add:
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cfbfastR)
library(rmarkdown)
library(pagedown)
# ... etc
```

Then regenerate manifest:
```r
rsconnect::writeManifest(appDir = ".")
```

### **Error: "manifest.json is invalid"**

**Solution:** Delete and recreate:

```r
# Delete old manifest
file.remove("manifest.json")

# Create new one
rsconnect::writeManifest(appDir = ".")
```

### **Error: "Git commit required"**

If deploying from Git repository:

```bash
git add manifest.json
git commit -m "Add manifest for Posit Connect"
git push
```

Then try deploying again.

---

## 💡 **Pro Tips**

### **Keep manifest.json in Git**

Update `.gitignore` to NOT ignore manifest:

```
# .gitignore
# Don't ignore manifest for Posit Connect
# manifest.json  ← Comment this out or remove it
```

### **Regenerate After Package Changes**

Whenever you add new packages to your app:

```r
# Update manifest
rsconnect::writeManifest(appDir = ".")

# Commit changes
system("git add manifest.json")
system("git commit -m 'Update manifest with new packages'")
```

---

## 🎯 **Quick Decision Guide**

| Situation | Command |
|-----------|---------|
| **First time deploying** | `rsconnect::writeManifest(appDir = ".")` |
| **Added new packages** | `rsconnect::writeManifest(appDir = ".")` |
| **Manifest seems corrupt** | Delete manifest, run writeManifest again |
| **After creating manifest** | Click "Publish" button or use deployApp() |

---

## 📊 **Verification**

After creating manifest, verify it exists:

```r
# Check manifest exists
file.exists("manifest.json")  # Should be TRUE

# Look at manifest contents
jsonlite::fromJSON("manifest.json")
```

Should show:
- List of packages
- Version numbers
- File list
- R version

---

## ✅ **Checklist**

- [ ] Run `rsconnect::writeManifest(appDir = ".")`
- [ ] Verify `manifest.json` file created
- [ ] Commit to Git (if using Git)
- [ ] Try publishing again
- [ ] Should work now!

---

## 🎊 **Summary**

**The Error:** "A manifest.json file specifying R dependencies is required"

**The Fix:**
```r
rsconnect::writeManifest(appDir = ".")
```

**Then:** Try publishing again!

---

## 🚀 **Next Steps**

1. **Run the fix script above**
2. **Verify manifest.json is created**
3. **Click "Publish" again or run deployApp()**
4. **Should deploy successfully!**

**Your app will be live on Posit Connect!** 🎉

---

## 📚 **More Help**

- **Posit Connect Docs:** https://docs.posit.co/connect/user/
- **rsconnect Package:** https://rstudio.github.io/rsconnect/
- **Manifest Format:** https://docs.posit.co/connect/user/manifest/

**Need more help?** Check the full deployment guide: [DEPLOY_POSIT_CONNECT.md](DEPLOY_POSIT_CONNECT.md)
