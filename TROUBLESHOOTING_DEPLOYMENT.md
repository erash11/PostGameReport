# 🔧 Deployment Troubleshooting

**Having trouble deploying? Common issues and solutions.**

---

## 🎯 **Quick Fix: Use Posit Cloud Instead**

If you're having trouble with shinyapps.io, **switch to Posit Cloud** - it's much easier!

**See:** [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)

**Why?**
- ✅ No rsconnect configuration
- ✅ One-click deployment
- ✅ Built-in RStudio in browser
- ✅ Easier troubleshooting
- ✅ Only $5/month (vs $9 for shinyapps.io)

---

## 🆘 **Common shinyapps.io Issues**

### **Issue 1: "rsconnect package not found"**

**Error:**
```
Error: could not find function "setAccountInfo"
```

**Solution:**
```r
# Install rsconnect
install.packages("rsconnect")

# Load it
library(rsconnect)

# Try again
rsconnect::setAccountInfo(...)
```

---

### **Issue 2: "Unable to connect to shinyapps.io"**

**Error:**
```
Error: Unable to connect to shinyapps.io
Connection timeout
```

**Possible Causes:**
- Firewall blocking connection
- Corporate proxy
- Network issues
- shinyapps.io service down

**Solutions:**

**A. Check Internet Connection**
```r
# Test connection
httr::GET("https://api.shinyapps.io/")
```

**B. Configure Proxy (if on corporate network)**
```r
# Set proxy
Sys.setenv(http_proxy = "http://proxy.company.com:8080")
Sys.setenv(https_proxy = "https://proxy.company.com:8080")

# Try deploying again
```

**C. Check shinyapps.io Status**
- Visit: https://status.posit.co/
- Check if service is operational

**D. Alternative: Use Posit Cloud**
- No connection issues
- Works from any network
- See DEPLOY_POSIT_CLOUD.md

---

### **Issue 3: "Token authentication failed"**

**Error:**
```
Error: Unable to authenticate with shinyapps.io
Invalid token
```

**Solution:**

1. **Get fresh token from shinyapps.io:**
   - Go to https://www.shinyapps.io/
   - Login
   - Click your name → Tokens
   - Click "Show" on your token
   - Click "Regenerate" (if needed)
   - Copy the full command

2. **Paste exact command in R:**
   ```r
   rsconnect::setAccountInfo(
     name='YOUR_ACCOUNT_NAME',
     token='YOUR_LONG_TOKEN_HERE',
     secret='YOUR_LONG_SECRET_HERE'
   )
   ```

3. **Verify connection:**
   ```r
   rsconnect::accounts()
   # Should show your account
   ```

---

### **Issue 4: "Application deployment failed"**

**Error:**
```
Error during application deployment
Package installation failed
```

**Common Causes:**

**A. Missing System Dependencies**

Some R packages need system libraries. shinyapps.io doesn't support all of them.

**Solution:** Switch to Posit Cloud or self-hosted server.

**B. Package Version Conflicts**

**Solution:**
```r
# Update all packages
update.packages(ask = FALSE)

# Try deploying again
deployApp(forceUpdate = TRUE)
```

**C. cfbfastR Installation Issues**

cfbfastR can be tricky on shinyapps.io.

**Solution:**
```r
# Try installing from CRAN
install.packages("cfbfastR")

# If that fails, use Posit Cloud (recommended)
```

---

### **Issue 5: "Object not found during deployment"**

**Error:**
```
Error: object 'generate_weekly_report' not found
```

**Cause:** Missing files or incorrect file paths

**Solution:**

**A. Check all files are included:**
```r
library(rsconnect)

deployApp(
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
  forceUpdate = TRUE
)
```

**B. Use preparation script:**
```r
source("prepare_deployment.R")
# Then deploy with generated script
source("deploy_app.R")
```

---

## 🔄 **Alternative: Switch to Posit Cloud**

### **If you've spent >30 minutes troubleshooting shinyapps.io:**

**Just use Posit Cloud instead!**

**Setup time:** 5 minutes
**Troubleshooting needed:** Usually none
**Cost:** $5/month (cheaper than shinyapps.io)

**See:** [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)

---

## 🎯 **Recommended Approach**

### **For Your Use Case:**

1. **First Choice: Posit Cloud** ⭐
   - Easiest deployment
   - Integrated workflow
   - Less troubleshooting
   - **Start here!**

2. **Second Choice: shinyapps.io**
   - If Posit Cloud doesn't work
   - If you need more hours
   - Follow full troubleshooting guide

3. **Third Choice: Self-hosted**
   - If you need full control
   - If you have IT resources
   - See DEPLOYMENT_GUIDE.md

---

## 📊 **Decision Matrix**

| If you have... | Use this... |
|---------------|-------------|
| Network/firewall issues | Posit Cloud |
| Package installation errors | Posit Cloud |
| Token auth problems | Posit Cloud |
| rsconnect errors | Posit Cloud |
| Timeout issues | Posit Cloud |
| Size limit issues | Posit Cloud |
| **Easy deployment needed** | **Posit Cloud** ✅ |

**Pattern noticed?** → Just use Posit Cloud! 😊

---

## ✅ **Quick Fixes Summary**

| Problem | Quick Fix |
|---------|-----------|
| rsconnect errors | Use Posit Cloud |
| Package won't install | Use Posit Cloud |
| Network timeout | Use Posit Cloud |
| Token issues | Regenerate token OR use Posit Cloud |
| App too large | Remove cache OR use Posit Cloud |
| pagedown errors | Use HTML output OR Posit Cloud |
| Deployment timeout | Pre-cache data OR use Posit Cloud |
| "Works locally, fails deployed" | Check logs OR use Posit Cloud |

**Notice a pattern?** 😉

---

## 🎊 **You Got This!**

Deployment can be tricky, but you have options:

1. **Try Posit Cloud** (recommended, easiest)
2. **Fix shinyapps.io issue** (use guide above)
3. **Ask for help** (community forums)

**Most people find Posit Cloud easier!**

**Ready to deploy?** → [DEPLOY_POSIT_CLOUD.md](DEPLOY_POSIT_CLOUD.md)
