# 🌐 Deploy to Posit Connect (connect.posit.cloud)

**Complete guide for deploying to Posit Connect specifically.**

---

## 🎯 **Quick Answer**

**Deploy the SHINY APP (`app.R`)**, not the R Markdown file!

Here's why:
- ✅ **Shiny app** = Interactive web interface (users can generate reports)
- ❌ **RMD file** = Static template (no user interaction)

---

## 📊 **Understanding the Difference**

### **Option 1: Shiny App (`app.R`)** ⭐ **RECOMMENDED**

**What it is:**
- Interactive web application
- Point-and-click interface
- Users select week/opponents from dropdowns
- Generates reports on demand

**What users get:**
```
┌─────────────────────────────┐
│ Week: [1 ▼]                │
│ Opponent: [SMU ▼]          │
│ Next: [Samford ▼]          │
│                             │
│ [Generate Report]           │
│ [Download PDF]              │
└─────────────────────────────┘
```

**Perfect for:**
- Coaches generating weekly reports
- Self-service report generation
- Interactive use

### **Option 2: R Markdown (`BU_Post_2024.Rmd`)**

**What it is:**
- Static report template
- Requires parameters to be set in code
- Generates one specific report

**What users get:**
- A single static HTML/PDF document
- No interaction
- Would need to be regenerated manually for each game

**Use case:**
- Publishing a single report
- Not for interactive generation
- Limited usefulness

---

## ✅ **Deploy the Shiny App**

### **Step-by-Step for Posit Connect**

#### **Step 1: Access Posit Connect**

1. Go to **[connect.posit.cloud](https://connect.posit.cloud/)**
2. Sign in with your account
3. Click **"Publish"** or **"New Content"**

#### **Step 2: Choose Deployment Method**

**Option A: From Posit Cloud (Easiest)**

If you're working in Posit Cloud (posit.cloud):
1. Open your project in Posit Cloud
2. Open `app.R`
3. Click the **"Publish"** button (blue icon, top right)
4. Choose **"Posit Connect"**
5. Select your Connect server
6. Click **"Publish"**

**Option B: From Local RStudio**

1. Open RStudio
2. Open your PostGameReport project
3. Open `app.R`
4. Click **"Publish"** button (blue icon)
5. Choose **"Posit Connect"**
6. Connect to connect.posit.cloud
7. Click **"Publish"**

**Option C: Using rsconnect Package**

```r
library(rsconnect)

# Connect to Posit Connect
rsconnect::connectUser(
  server = "connect.posit.cloud",
  account = "YOUR_ACCOUNT"
)

# Deploy the Shiny app
rsconnect::deployApp(
  appFiles = c(
    "app.R",                    # PRIMARY FILE (Shiny app)
    "helper_functions.R",
    "data_loader.R",
    "feature_analytics.R",
    "generate_report.R",
    "BU_Post_2024.Rmd",        # Template used by Shiny app
    "report_config.yaml",
    "TSU.png"
  ),
  appName = "baylor-football-analytics",
  server = "connect.posit.cloud",
  account = "YOUR_ACCOUNT"
)
```

#### **Step 3: When Asked "Select Content Type"**

**Choose: "Shiny Application"** ✅

**NOT: "R Markdown Document"** ❌

#### **Step 4: Select Primary File**

**Choose: `app.R`** ✅

**NOT: `BU_Post_2024.Rmd`** ❌

#### **Step 5: Configure Deployment**

**Title:** Baylor Football Analytics
**Description:** Interactive post-game report generator
**Access:** Choose your preference (public/private)

#### **Step 6: Deploy!**

Click **"Publish"** and wait for deployment (~1-2 minutes)

---

## 🎯 **What Gets Deployed**

### **Files Needed:**

**Must Include:**
- ✅ `app.R` (the Shiny app - your main file)
- ✅ `helper_functions.R` (functions)
- ✅ `data_loader.R` (data loading)
- ✅ `feature_analytics.R` (analytics)
- ✅ `generate_report.R` (report generation)
- ✅ `BU_Post_2024.Rmd` (template used by app)
- ✅ `report_config.yaml` (config)

**Optional:**
- ✅ `TSU.png` (custom logo)
- ✅ `cache/` folder (pre-cached data)

**Don't Include:**
- ❌ `run_app.R` (local launcher only)
- ❌ Documentation files (.md files)
- ❌ `example_usage.R`
- ❌ `prepare_deployment.R`

---

## 🔄 **How It Works**

### **The Shiny App (`app.R`) Architecture:**

```
User visits URL
    ↓
Sees web interface (app.R)
    ↓
Selects week/opponents in dropdowns
    ↓
Clicks "Generate Report"
    ↓
App calls generate_weekly_report()
    ↓
Which renders BU_Post_2024.Rmd
    ↓
PDF is created
    ↓
User downloads PDF
```

**The RMD file is used INSIDE the Shiny app, but you deploy the Shiny app itself.**

---

## ⚠️ **Common Mistakes**

### **❌ Mistake 1: Deploying RMD Directly**

**What happens:**
- Gets a static HTML page
- No user interaction
- Can't change parameters
- Not useful for weekly reports

**Solution:** Deploy `app.R` instead

### **❌ Mistake 2: Not Including Helper Files**

**Error:** "Could not find function..."

**Solution:** Include all helper R files in deployment

### **❌ Mistake 3: Wrong Primary File**

**What you select:** `BU_Post_2024.Rmd`
**What happens:** Static document, not interactive app

**Solution:** Select `app.R` as primary file

---

## 🎓 **Posit Connect vs Posit Cloud**

### **Clarification:**

**Posit Cloud** (posit.cloud)
- Cloud-based RStudio IDE
- For development
- Run code, edit files
- Can publish from here to Connect

**Posit Connect** (connect.posit.cloud)
- Hosting/deployment platform
- For sharing published content
- Users access deployed apps
- Production environment

### **Typical Workflow:**

```
1. Develop in Posit Cloud (or local RStudio)
     ↓
2. Publish to Posit Connect
     ↓
3. Share Connect URL with users
     ↓
4. Users access the app on Connect
```

---

## 💻 **Detailed Deployment from RStudio**

### **Step-by-Step with Screenshots:**

**1. Open `app.R` in RStudio**
- File browser → Click `app.R`

**2. Look for "Publish" button**
- Top right of editor window
- Blue icon with up arrow
- Next to "Run App" button

**3. Click "Publish"**

**4. First time: Connect to Posit Connect**
```
Publishing destination: [Select]

Options:
○ RStudio Connect
● Posit Connect Cloud  ← Select this
○ shinyapps.io

[Next]
```

**5. Enter Connect Details**
```
Server: connect.posit.cloud
Account: [Your account name]

[Connect Account]
```

**6. Select Files**
```
Publish From: /path/to/PostGameReport

Select files to include:
☑ app.R                    ← Main file
☑ helper_functions.R
☑ data_loader.R
☑ feature_analytics.R
☑ generate_report.R
☑ BU_Post_2024.Rmd
☑ report_config.yaml
☑ TSU.png
☐ README.md               ← Uncheck docs
☐ example_usage.R          ← Uncheck
☐ *.md files               ← Uncheck

[Publish]
```

**7. Wait for Deployment**
```
Preparing to deploy...
Uploading bundle...
Deploying bundle...
Building...
Launching...
Success!

Your content is now available at:
https://connect.posit.cloud/content/abc123/

[Open in Browser]
```

---

## 🌟 **After Deployment**

### **Your URL:**
```
https://connect.posit.cloud/content/YOUR_CONTENT_ID/
```

### **What Users See:**

**They visit the URL and see:**
1. Week selector dropdown
2. Current opponent dropdown
3. Next opponent dropdown
4. "Generate Report" button
5. Real-time progress
6. Download button when ready

**No R. No coding. Just clicks!**

---

## 🔄 **Updating Your Deployed App**

### **After Making Changes:**

**Option 1: From RStudio**
1. Open `app.R`
2. Click "Publish" button
3. Choose "Republish"
4. Wait ~30 seconds
5. Changes are live!

**Option 2: From Posit Cloud**
1. Make your edits
2. Click "Publish" button
3. Select same deployment
4. Confirm republish
5. Done!

**Option 3: Via Code**
```r
library(rsconnect)

# Redeploy to same location
rsconnect::deployApp(
  appName = "baylor-football-analytics",
  server = "connect.posit.cloud",
  forceUpdate = TRUE
)
```

---

## 💰 **Posit Connect Pricing**

### **Check your plan:**
- Some organizations have free access
- Others require paid subscription
- Contact your IT/admin about access

### **Typical Plans:**
- **Free tier:** Limited usage
- **Standard:** $5-15/month
- **Enterprise:** Custom pricing

---

## 🎯 **Decision Matrix**

| Want to Deploy... | Choose... | Primary File |
|-------------------|-----------|--------------|
| **Interactive web app** | **Shiny** | **app.R** ✅ |
| Weekly report tool | Shiny | app.R ✅ |
| Self-service generator | Shiny | app.R ✅ |
| User-friendly interface | Shiny | app.R ✅ |
| Single static report | R Markdown | BU_Post_2024.Rmd |
| One-time PDF | R Markdown | BU_Post_2024.Rmd |

**For your use case: SHINY (app.R)** ✅

---

## ✅ **Deployment Checklist**

- [ ] Open `app.R` in RStudio
- [ ] Click "Publish" button
- [ ] Select "Posit Connect Cloud"
- [ ] Choose content type: **"Shiny Application"**
- [ ] Select primary file: **`app.R`**
- [ ] Include all helper R files
- [ ] Include BU_Post_2024.Rmd (template)
- [ ] Include config and images
- [ ] Don't include documentation files
- [ ] Click "Publish"
- [ ] Wait for deployment
- [ ] Test the URL
- [ ] Share with team!

---

## 🆘 **Troubleshooting**

### **"Content type not recognized"**
**Solution:** Make sure you selected "Shiny Application" not "R Markdown"

### **"Primary file must be specified"**
**Solution:** Select `app.R` as the primary file

### **"Function not found"**
**Solution:** Make sure all helper R files are included in deployment

### **"Template not found"**
**Solution:** Include `BU_Post_2024.Rmd` in the deployment files

### **"Can't connect to Connect server"**
**Solution:** Verify you have access to connect.posit.cloud with your account

---

## 📚 **Additional Resources**

- **Posit Connect User Guide:** https://docs.posit.co/connect/user/
- **Publishing from RStudio:** https://docs.posit.co/connect/user/publishing/
- **Shiny on Connect:** https://docs.posit.co/connect/user/shiny/

---

## 🎊 **Summary**

**What to deploy:** Shiny app (`app.R`)
**Why:** Interactive interface for report generation
**How:** Click "Publish" button in RStudio
**Content type:** Shiny Application
**Primary file:** app.R

**The R Markdown file (BU_Post_2024.Rmd) gets included as a template, but you deploy the Shiny app itself!**

---

## 🚀 **Quick Start**

```
1. Open app.R in RStudio
2. Click "Publish" (blue button, top right)
3. Select "Posit Connect Cloud"
4. Choose "Shiny Application"
5. Primary file: app.R
6. Include all R files + BU_Post_2024.Rmd
7. Click "Publish"
8. Share the URL!
```

**That's it!** Your interactive report generator will be live on Posit Connect.

**Need help?** The "Publish" button wizard walks you through each step! 🎉
