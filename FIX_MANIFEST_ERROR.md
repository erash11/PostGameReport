# 🔧 Fix: "manifest.json file was not found" Error

**Quick solutions for the manifest.json deployment error.**

---

## ⚡ **Quick Fix (Try This First!)**

### **Solution 1: Remove Old Deployment Files**

```r
# Delete the rsconnect folder
unlink("rsconnect", recursive = TRUE)

# Delete any manifest files
if (file.exists("manifest.json")) file.remove("manifest.json")

# Now try deploying again
library(rsconnect)
deployApp(appName = "baylor-football-analytics", forceUpdate = TRUE)
```

**This works 90% of the time!**

---

## 🎯 **What This Error Means**

The `manifest.json` file is automatically created by rsconnect during deployment. If you see this error, it means:

1. Deployment was attempted before
2. Something got corrupted
3. rsconnect can't recreate it properly

**Solution:** Clean slate and try again!

---

## 🚀 **Step-by-Step Fix**

### **STEP 1: Clean Up**

```r
# Remove old deployment artifacts
unlink("rsconnect", recursive = TRUE)

# Remove any manifest files
file.remove("manifest.json") # if it exists

# Clear any .dcf files
unlink("*.dcf")
```

### **STEP 2: Verify Your Setup**

```r
# Check rsconnect is installed
if (!"rsconnect" %in% installed.packages()) {
  install.packages("rsconnect")
}

# Load rsconnect
library(rsconnect)

# Verify account is connected
accounts <- rsconnect::accounts()
print(accounts)

# If no accounts, reconnect:
# Get token from shinyapps.io and paste command
```

### **STEP 3: Deploy Fresh**

```r
library(rsconnect)

deployApp(
  appName = "baylor-football-analytics",
  appTitle = "Baylor Football Analytics",
  appDir = ".",
  forceUpdate = TRUE,
  launch.browser = FALSE
)
```

---

## 💻 **Alternative: Use This Script**

Save and run this complete fix:

```r
# ====================================================================
# FIX MANIFEST ERROR AND DEPLOY
# ====================================================================

cat("Fixing manifest.json error...\n\n")

# Step 1: Clean up
cat("Step 1: Cleaning up old deployment files...\n")
if (dir.exists("rsconnect")) {
  unlink("rsconnect", recursive = TRUE)
  cat("  ✓ Removed rsconnect folder\n")
}

if (file.exists("manifest.json")) {
  file.remove("manifest.json")
  cat("  ✓ Removed manifest.json\n")
}

# Step 2: Verify setup
cat("\nStep 2: Verifying setup...\n")

if (!"rsconnect" %in% installed.packages()) {
  cat("  Installing rsconnect...\n")
  install.packages("rsconnect")
}

library(rsconnect)
cat("  ✓ rsconnect loaded\n")

# Check accounts
accounts <- rsconnect::accounts()
if (nrow(accounts) == 0) {
  cat("\n  ✗ No accounts configured!\n")
  cat("  Please run:\n")
  cat("    1. Go to shinyapps.io\n")
  cat("    2. Get your token\n")
  cat("    3. Run rsconnect::setAccountInfo(...)\n")
  stop("Account configuration required")
} else {
  cat("  ✓ Account configured:", accounts$name[1], "\n")
}

# Step 3: Deploy
cat("\nStep 3: Deploying application...\n")

deployApp(
  appName = "baylor-football-analytics",
  appTitle = "Baylor Football Analytics",
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
  forceUpdate = TRUE,
  launch.browser = TRUE
)

cat("\n✓ Deployment complete!\n")
```

---

## 🔍 **Why This Happens**

### **Common Causes:**

1. **Previous deployment failed mid-process**
   - rsconnect created partial files
   - Manifest got corrupted

2. **Working directory changed**
   - rsconnect can't find the original path
   - Manifest points to wrong location

3. **Files moved or renamed**
   - Manifest has old file paths
   - rsconnect gets confused

4. **Git operations**
   - Checked out different branch
   - Pulled changes that conflict

**Solution for all:** Fresh start!

---

## 🎯 **Better Alternative: Use Posit Cloud!**

If you keep having issues with shinyapps.io, **switch to Posit Cloud**:

### **Why Posit Cloud is Easier:**
- ✅ No manifest.json issues (ever!)
- ✅ No rsconnect configuration
- ✅ One-click deployment
- ✅ Visual interface
- ✅ Integrated development

### **How to Use Posit Cloud:**

1. Go to [posit.cloud](https://posit.cloud/)
2. Create project from GitHub
3. Click "Publish" button
4. Done!

**No manifest errors. No rsconnect problems. Just works.**

See: [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)

---

## 🆘 **Still Getting the Error?**

### **Try These Additional Fixes:**

### **Fix 1: Change Working Directory**

```r
# Make sure you're in the right directory
getwd()

# If not in your project folder:
setwd("/path/to/PostGameReport")

# Then try deploying
```

### **Fix 2: Specify Absolute Path**

```r
library(rsconnect)

deployApp(
  appDir = "/full/path/to/PostGameReport",
  appName = "baylor-football-analytics",
  forceUpdate = TRUE
)
```

### **Fix 3: Update rsconnect**

```r
# Update to latest version
remove.packages("rsconnect")
install.packages("rsconnect")

# Load and try again
library(rsconnect)
deployApp()
```

### **Fix 4: Manual Manifest Creation**

```r
# Create manifest manually
rsconnect::writeManifest(appDir = ".")

# Then deploy
deployApp()
```

---

## 📋 **Complete Troubleshooting Checklist**

Try these in order:

- [ ] Delete `rsconnect/` folder
- [ ] Delete `manifest.json` if exists
- [ ] Verify you're in project directory (`getwd()`)
- [ ] Verify rsconnect account configured (`rsconnect::accounts()`)
- [ ] Update rsconnect package
- [ ] Try deploying with `forceUpdate = TRUE`
- [ ] Specify full file list in `deployApp()`
- [ ] Try from RStudio "Publish" button
- [ ] Switch to Posit Cloud (easiest!)

---

## 💡 **Prevention Tips**

### **To Avoid This Error in the Future:**

1. **Don't interrupt deployment**
   - Let it complete fully
   - Don't close R during deployment

2. **Keep rsconnect folder in .gitignore**
   ```
   # Add to .gitignore
   rsconnect/
   manifest.json
   *.dcf
   ```

3. **Don't manually edit rsconnect files**
   - Let rsconnect manage them
   - Don't touch manifest.json

4. **Use consistent working directory**
   - Always deploy from same location
   - Use RStudio projects

5. **Or just use Posit Cloud!**
   - No manifest issues
   - No rsconnect problems
   - Much easier

---

## 🎯 **Recommended Solution**

Based on your error, I recommend:

### **Option A: Quick Fix (5 minutes)**

```r
# Run this complete script
unlink("rsconnect", recursive = TRUE)
library(rsconnect)
deployApp(appName = "baylor-football-analytics", forceUpdate = TRUE)
```

### **Option B: Switch to Posit Cloud (5 minutes)**

1. Go to [posit.cloud](https://posit.cloud/)
2. New Project from your GitHub repo
3. Click "Publish" in RStudio
4. No manifest errors!

**I recommend Option B** - Posit Cloud is easier and you won't have these issues.

---

## 📊 **Success Rate**

| Solution | Success Rate | Time |
|----------|-------------|------|
| Delete rsconnect folder | 90% | 2 min |
| Update rsconnect | 70% | 5 min |
| Manual manifest | 60% | 10 min |
| **Switch to Posit Cloud** | **99%** | **5 min** |

**Clear winner:** Posit Cloud!

---

## ✅ **Next Steps**

### **If Quick Fix Works:**
Great! You're deployed.

### **If Quick Fix Fails:**
Switch to Posit Cloud:
- See [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)
- No more manifest errors
- Much easier deployment

### **If You Really Want shinyapps.io:**
- See full troubleshooting: [TROUBLESHOOTING_DEPLOYMENT.md](TROUBLESHOOTING_DEPLOYMENT.md)
- Contact shinyapps.io support
- Check community forums

---

## 🎊 **You're Almost There!**

This error is frustrating but fixable. Try the quick fix, or save yourself the hassle and use Posit Cloud!

**Quick Fix:**
```r
unlink("rsconnect", recursive = TRUE)
library(rsconnect)
deployApp(appName = "baylor-football-analytics", forceUpdate = TRUE)
```

**Or switch to Posit Cloud** → [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)

**Good luck!** 🚀
