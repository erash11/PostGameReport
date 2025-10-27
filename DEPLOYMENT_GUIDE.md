# 🌍 Publishing Your Shiny App to the Web

Complete guide to deploying your Post-Game Report Generator online so anyone can access it from a web browser.

---

## 🎯 **Deployment Options**

| Option | Difficulty | Cost | Best For |
|--------|-----------|------|----------|
| **shinyapps.io** | ⭐ Easy | Free tier | Small teams, getting started |
| **Shiny Server** | ⭐⭐⭐ Medium | Free (self-host) | Full control, on-premise |
| **Posit Cloud** | ⭐ Easy | Paid | Cloud development |
| **RStudio Connect** | ⭐⭐⭐⭐ Hard | $$$ | Enterprise |
| **Docker + AWS/Azure** | ⭐⭐⭐⭐ Hard | $$ | Custom scaling |

**Recommendation:** Start with **shinyapps.io** (free tier, easiest setup)

---

## 📱 **Option 1: shinyapps.io (RECOMMENDED)**

### Free Tier Includes:
- ✅ 5 applications
- ✅ 25 active hours/month
- ✅ 1 GB storage
- ✅ Easy deployment
- ✅ SSL/HTTPS included

**Perfect for your use case!**

---

## 🚀 **Step-by-Step: Deploy to shinyapps.io**

### **STEP 1: Create Account**

1. Go to [shinyapps.io](https://www.shinyapps.io/)
2. Click "Sign Up"
3. Choose "Free" plan
4. Create account (or use GitHub login)

---

### **STEP 2: Install Required R Packages**

```r
# Install deployment tools
install.packages("rsconnect")
```

---

### **STEP 3: Connect Your Account**

1. **In shinyapps.io dashboard:**
   - Click your name (top right)
   - Click "Tokens"
   - Click "Show" next to your token
   - Click "Copy to clipboard"

2. **In R:**
   ```r
   library(rsconnect)

   # Paste the command from shinyapps.io (looks like this):
   rsconnect::setAccountInfo(
     name='YOUR_ACCOUNT_NAME',
     token='YOUR_TOKEN',
     secret='YOUR_SECRET'
   )
   ```

---

### **STEP 4: Prepare App for Deployment**

**Important:** Before deploying, create a deployment-ready version:

```r
# Run the preparation script
source("prepare_deployment.R")
```

This will:
- Check all required files
- Validate dependencies
- Create deployment manifest
- Test app locally

---

### **STEP 5: Deploy!**

```r
library(rsconnect)

# Deploy the app
deployApp(
  appName = "baylor-football-analytics",
  appTitle = "Baylor Football Analytics",
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

---

### **STEP 6: Access Your App**

After deployment completes, you'll get a URL:
```
https://YOUR_ACCOUNT.shinyapps.io/baylor-football-analytics/
```

**Share this URL with anyone!** They can use the app without installing R.

---

## ⚠️ **Important Considerations**

### **1. Data Loading**

**Issue:** cfbfastR downloads large datasets (can be slow on first load)

**Solution:**
```r
# Pre-cache data before deploying
source("data_loader.R")
load_cfb_data_cached(season = 2025, force_reload = TRUE)
load_team_info_cached(force_reload = TRUE)

# This creates cache files you can deploy with the app
```

**Then deploy cache folder:**
```r
deployApp(
  appFiles = c(
    # ... other files ...
    "cache/cfb_pbp_2025.rds",
    "cache/team_info.rds"
  )
)
```

### **2. PDF Generation**

**Issue:** pagedown requires Chrome/Chromium for PDF rendering

**Solutions:**

**Option A: Use HTML output instead** (recommended for web)
```r
# In generate_report.R, change output format:
output_format = "html_document"  # instead of pagedown::chrome_print
```

**Option B: Install Chromium on shinyapps.io**
```r
# Add to app.R before library() calls:
if (!file.exists("/usr/bin/chromium-browser")) {
  system("sudo apt-get update && sudo apt-get install -y chromium-browser")
}
```

### **3. File Storage**

**Issue:** shinyapps.io has limited persistent storage

**Solution:**
- Cache data in the deployed app
- Store generated reports temporarily (delete after download)
- Use external storage (AWS S3, Dropbox) for long-term storage

### **4. Active Hours**

**Free tier = 25 hours/month**

**Tips to stay under limit:**
- App only runs when someone is using it
- Auto-sleeps after 15 minutes of inactivity
- Monitor usage in shinyapps.io dashboard
- Upgrade to paid plan if needed ($9/month for 250 hours)

---

## 🔧 **Deployment Configuration**

### **Create `.Rprofile` for deployment settings:**

```r
# .Rprofile
# Settings for shinyapps.io deployment

# Increase timeout for data loading
options(shiny.maxRequestSize = 100*1024^2)  # 100MB
options(timeout = 300)  # 5 minutes

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))
```

---

## 📝 **Monitor Your App**

### In shinyapps.io Dashboard:

1. **Logs Tab**
   - View real-time logs
   - Debug errors
   - Monitor usage

2. **Metrics Tab**
   - Active hours used
   - Number of connections
   - Memory usage

3. **Settings Tab**
   - Change instance size
   - Set environment variables
   - Configure timeouts

---

## 🔄 **Updating Your Deployed App**

After making changes locally:

```r
# Re-deploy (will update existing app)
deployApp(
  appName = "baylor-football-analytics",
  forceUpdate = TRUE
)
```

Or use the deployment button in RStudio!

---

## 💰 **Pricing Tiers**

### Free Tier
- 5 apps
- 25 active hours/month
- 1GB storage
- **Best for:** Testing, small teams

### Starter ($9/month)
- 25 apps
- 250 active hours/month
- 3GB storage
- **Best for:** Regular use, small-medium teams

### Basic ($39/month)
- 100 apps
- 2000 active hours/month
- 10GB storage
- **Best for:** Heavy use, multiple teams

### Standard ($99/month)
- Unlimited apps
- 10,000 active hours/month
- 25GB storage
- **Best for:** Enterprise use

---

## 🛡️ **Security & Access Control**

### Password Protection (Paid Plans Only)

```r
# In shinyapps.io dashboard:
# Settings > Access > Require password
```

### Alternative: Add authentication to app

```r
# Install package
install.packages("shinymanager")

# Add to app.R
library(shinymanager)

# Wrap UI with authentication
ui <- secure_app(ui)

# Set credentials
credentials <- data.frame(
  user = c("coach", "analyst"),
  password = c("password1", "password2"),
  stringsAsFactors = FALSE
)

# Add to server
server <- function(input, output, session) {
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  # ... rest of server code ...
}
```

---

## 🌐 **Option 2: Self-Hosted Shiny Server**

For full control and no usage limits.

### Requirements:
- Linux server (Ubuntu recommended)
- R installed
- Shiny Server software

### Quick Setup (Ubuntu):

```bash
# 1. Install R
sudo apt-get update
sudo apt-get install r-base

# 2. Install Shiny Server
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
sudo dpkg -i shiny-server-1.5.20.1002-amd64.deb

# 3. Install R packages
sudo su - -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

# 4. Copy your app to /srv/shiny-server/
sudo cp -R /path/to/your/app /srv/shiny-server/baylor-analytics

# 5. Access at http://your-server-ip:3838/baylor-analytics/
```

### Pros:
- ✅ No usage limits
- ✅ Full control
- ✅ No monthly fees (after server costs)
- ✅ Can run behind firewall

### Cons:
- ❌ Need to manage server
- ❌ Security updates
- ❌ Setup complexity

---

## ☁️ **Option 3: Docker + Cloud Hosting**

For maximum flexibility and scalability.

### Create Dockerfile:

```dockerfile
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('shiny', 'dplyr', 'ggplot2', 'cfbfastR'))"

# Copy app
COPY . /srv/shiny-server/

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

### Deploy to:
- **AWS Elastic Beanstalk**
- **Google Cloud Run**
- **Azure Container Instances**
- **DigitalOcean App Platform**

---

## 📊 **Performance Optimization for Web**

### 1. Pre-cache Data

```r
# Run before deployment
source("data_loader.R")
load_cfb_data_cached(season = 2025, force_reload = TRUE)

# Deploy cache/ folder with app
```

### 2. Lazy Loading

```r
# In app.R, load data only when needed
observe({
  if (is.null(state$teams)) {
    state$teams <- load_team_info_cached()
  }
})
```

### 3. Async Operations

```r
# Install future/promises
install.packages(c("future", "promises"))

# Use for long-running operations
library(future)
library(promises)

plan(multisession)

# In server
future({ generate_weekly_report(...) }) %...>%
  { showNotification("Report ready!") }
```

### 4. Progress Indicators

```r
# Add to server
withProgress(message = 'Generating report...', value = 0, {
  incProgress(0.2, detail = "Loading data")
  # ... load data ...

  incProgress(0.5, detail = "Creating visualizations")
  # ... create charts ...

  incProgress(0.8, detail = "Rendering PDF")
  # ... generate PDF ...

  incProgress(1.0, detail = "Complete!")
})
```

---

## 🎯 **Recommended Setup**

### For Your Use Case:

**Start with shinyapps.io Free Tier:**
```r
# 1. Create account
# 2. Connect RStudio
# 3. Pre-cache data
source("prepare_deployment.R")

# 4. Deploy
library(rsconnect)
deployApp(appName = "baylor-football-analytics")

# 5. Share URL with team
```

**Monitor usage for 1 month:**
- If under 25 hours → Stay on free
- If over 25 hours → Upgrade to $9/month

**Consider self-hosting if:**
- Need unlimited usage
- Want private/internal only
- Have IT infrastructure

---

## 📱 **Mobile Optimization**

The app is already responsive, but you can enhance mobile experience:

```r
# Add to UI in app.R
tags$head(
  tags$meta(name = "viewport", content = "width=device-width, initial-scale=1")
)
```

---

## 🔍 **Testing Before Deployment**

```r
# 1. Test locally first
source("run_app.R")

# 2. Test with limited resources (simulate shinyapps.io)
options(shiny.maxRequestSize = 30*1024^2)  # 30MB limit

# 3. Clear cache and test cold start
source("data_loader.R")
clear_cache()

# 4. Time the operations
system.time({
  load_cfb_data_cached(season = 2025)
})

# 5. If all good, deploy!
source("prepare_deployment.R")
deployApp()
```

---

## 📧 **Email Notifications**

Add email alerts when reports are generated:

```r
# Install package
install.packages("mailR")

# Add to server after successful generation
library(mailR)

send.mail(
  from = "app@yourdomain.com",
  to = "coach@baylor.edu",
  subject = paste("Report Generated: Week", input$week_number),
  body = paste("Report for", input$opponent, "is ready!"),
  smtp = list(host.name = "smtp.gmail.com", port = 465)
)
```

---

## 🎓 **Next Steps**

1. **Deploy to shinyapps.io** (use guide above)
2. **Share URL** with your team
3. **Monitor usage** for first month
4. **Gather feedback** from users
5. **Iterate and improve**

---

## 🆘 **Troubleshooting Deployment**

### Common Issues:

**"Package not found"**
```r
# Make sure all packages are in app.R
library(shiny)
library(dplyr)
# ... etc
```

**"App timeout on startup"**
```r
# Pre-cache data before deploying
# Or increase timeout in Settings
```

**"PDF generation fails"**
```r
# Switch to HTML output for web deployment
output_format = "html_document"
```

**"App won't start"**
```r
# Check logs in shinyapps.io dashboard
# Logs tab shows detailed errors
```

---

## 📚 **Resources**

- [shinyapps.io Documentation](https://docs.posit.co/shinyapps.io/)
- [Shiny Server Guide](https://docs.posit.co/shiny-server/)
- [Deploying Shiny Apps](https://shiny.rstudio.com/deploy/)
- [Performance Tuning](https://shiny.rstudio.com/articles/scaling-and-tuning.html)

---

## ✅ **Quick Deployment Checklist**

- [ ] Create shinyapps.io account
- [ ] Install rsconnect package
- [ ] Connect account (setAccountInfo)
- [ ] Run prepare_deployment.R
- [ ] Test app locally
- [ ] Deploy with deployApp()
- [ ] Test deployed app
- [ ] Share URL with team
- [ ] Monitor usage
- [ ] Celebrate! 🎉

---

**Ready to deploy? Let's do it!**

See `prepare_deployment.R` for automated setup.
