# 🌐 Shiny Web App Guide

A simple, user-friendly web interface for generating post-game reports. **No coding required!**

---

## 🚀 Quick Start (3 Steps)

### 1. Install Required Packages (One-Time Setup)

Open R or RStudio and run:

```r
install.packages(c(
  "shiny",
  "shinythemes",
  "shinyWidgets",
  "DT",
  "dplyr",
  "cfbfastR",
  "rmarkdown",
  "pagedown"
))
```

### 2. Launch the App

**Option A: Use the Launcher Script (Easiest)**
```r
source("run_app.R")
```

**Option B: From RStudio**
- Open `app.R` in RStudio
- Click the "Run App" button in the top right

**Option C: From Command Line**
```bash
Rscript run_app.R
```

### 3. Generate Your Report!

The app will open in your web browser. Then:
1. Select the week number
2. Choose current opponent
3. Choose next opponent
4. Click "Generate Report"
5. Download your PDF!

---

## 📱 **App Interface Overview**

```
┌──────────────────────────────────────────────────────┐
│  🏈 Baylor Football Analytics                       │
│  Post-Game Report Generator                          │
├─────────────────┬────────────────────────────────────┤
│ Configuration   │  Status & Results                  │
│                 │                                     │
│ Week: [1]       │  ✓ Ready to Generate              │
│                 │                                     │
│ Opponent:       │  [Live status updates here]        │
│ [SMU ▼]        │                                     │
│                 │  [Download button appears          │
│ Next Opponent:  │   when report is ready]            │
│ [Samford ▼]    │                                     │
│                 │  ─── Tabs ───                      │
│ [ ] Force       │  Cache │ Reports │ Help │ About    │
│     Reload      │                                     │
│                 │                                     │
│ [Generate]      │                                     │
│                 │                                     │
│ ─ Cache ─       │                                     │
│ [Refresh] [Clear]                                    │
└─────────────────┴────────────────────────────────────┘
```

---

## 🎯 **Features**

### Main Features
- ✅ **Dropdown Selection** - Choose teams from a list (no typing errors!)
- ✅ **One-Click Generation** - Just click the button
- ✅ **Progress Tracking** - See real-time status updates
- ✅ **Instant Download** - PDF appears when ready
- ✅ **Built-in Help** - Help tab with instructions

### Tabs

#### 📊 **Cache Status Tab**
- View cached data files
- See file sizes and ages
- Quick cache refresh

#### 📁 **Recent Reports Tab**
- List of all generated reports
- File sizes and creation dates
- Easy access to previous reports

#### ❓ **Help Tab**
- Step-by-step instructions
- Tips for faster generation
- Troubleshooting guide

#### ℹ️ **About Tab**
- Feature list
- Version information
- Credits

---

## ⚡ **Performance**

### First Report Generation
- **Time**: 30-60 seconds
- **Why**: Downloads data from cfbfastR API
- **Status**: Shows "Processing..." message

### Subsequent Reports (Cached)
- **Time**: 5-10 seconds
- **Why**: Uses cached data
- **Tip**: Uncheck "Force reload" for speed

### Force Reload Option
- **When to use**: Need most current data
- **Time**: 30-60 seconds (downloads fresh data)
- **Tip**: Only use when absolutely necessary

---

## 🎓 **How to Use**

### Basic Workflow

1. **Start the App**
   ```r
   source("run_app.R")
   ```

2. **App Opens in Browser**
   - Automatically loads at http://127.0.0.1:XXXX

3. **Select Your Options**
   - Week number (1-20)
   - Current opponent (dropdown)
   - Next opponent (dropdown)

4. **Generate Report**
   - Click "Generate Report" button
   - Wait for processing (5-60 seconds)
   - Watch for success message

5. **Download**
   - Click "Download Report (PDF)" button
   - Save to your desired location

6. **Done!**
   - Close browser tab when finished
   - Stop app with Ctrl+C in console

### Advanced Options

#### Force Reload Data
- Check the box to download fresh data
- Use when you need the absolute latest stats
- Takes longer (30-60 seconds)

#### Cache Management
- **Refresh Cache Info**: Update cache status display
- **Clear Cache**: Delete all cached data
  - Next report will reload everything
  - Use to free up disk space

---

## 💡 **Tips & Tricks**

### Speed Tips
1. **Don't Force Reload** unless necessary
2. **Cache is good for 24 hours** - use it!
3. **First report is slow** - be patient
4. **Close other apps** for faster processing

### Workflow Tips
1. **Check Recent Reports tab** before generating duplicates
2. **Use Help tab** if you get stuck
3. **Keep app open** if generating multiple reports
4. **Download immediately** - don't lose your report

### Quality Tips
1. **Verify opponent names** match exactly
2. **Double-check week number** before generating
3. **Review cache status** to ensure data freshness
4. **Test with one report** before batch processing

---

## 🔧 **Troubleshooting**

### Common Issues

#### App Won't Start
```r
# Install missing packages
install.packages(c("shiny", "shinythemes", "shinyWidgets", "DT"))

# Try again
source("run_app.R")
```

#### "Team Not Found" Error
- Team name might not be in cfbfastR database
- Try a different spelling
- Check cfbfastR documentation for official names

#### Slow Generation
- **First time?** It's normal (30-60 seconds)
- **Force reload?** Uncheck it for speed
- **Cache full?** Clear it and try again

#### Report Failed to Generate
- Check opponent names are correct
- Ensure template file exists (BU_Post_2024.Rmd)
- Review error message in status box
- Check Help tab for solutions

#### Download Button Not Appearing
- Wait for "Success" message
- Check status box for errors
- Try generating again

#### Browser Doesn't Open
```r
# Manually open browser to:
# http://127.0.0.1:XXXX (check console for port number)
```

---

## 📁 **File Locations**

### App Files
- **app.R** - Main Shiny app
- **run_app.R** - Launcher script

### Generated Files
- **reports/** - All PDF reports
- **cache/** - Cached data files

### Other Files
- **BU_Post_2024.Rmd** - Report template
- **helper_functions.R** - Backend functions
- **generate_report.R** - Report generation logic

---

## 🆘 **Need Help?**

### In the App
1. Click the **Help** tab
2. Read step-by-step instructions
3. Check troubleshooting section

### Documentation
- **QUICKSTART.md** - 5-minute guide to R functions
- **README.md** - Complete documentation
- **example_usage.R** - Code examples

### Common Questions

**Q: Can I generate multiple reports at once?**
A: Not in the app. Use `generate_report.R --batch` for bulk processing.

**Q: Can I customize the report?**
A: Yes, edit `BU_Post_2024.Rmd` template.

**Q: How do I update team data?**
A: Check "Force reload" or click "Clear Cache" then regenerate.

**Q: Where are my reports saved?**
A: In the `reports/` directory. Check "Recent Reports" tab.

**Q: Can others use this on their computer?**
A: Yes! They just need to install R and run `run_app.R`.

---

## 🚀 **Advantages Over Command Line**

| Feature | Shiny App | Command Line |
|---------|-----------|--------------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ Click buttons | ⭐⭐ Type commands |
| **Learning Curve** | ⭐⭐⭐⭐⭐ None | ⭐⭐ Need R knowledge |
| **Error Prevention** | ⭐⭐⭐⭐⭐ Dropdowns | ⭐⭐ Manual typing |
| **Visual Feedback** | ⭐⭐⭐⭐⭐ Live status | ⭐⭐ Text output |
| **Cache Management** | ⭐⭐⭐⭐⭐ Click buttons | ⭐⭐⭐ Run commands |
| **Speed** | ⭐⭐⭐⭐ Fast | ⭐⭐⭐⭐⭐ Slightly faster |
| **Automation** | ⭐⭐⭐ Good | ⭐⭐⭐⭐⭐ Excellent |

**Bottom Line**: Use the **Shiny App** for ease of use. Use **command line** for automation and batch processing.

---

## 🎯 **Best Practices**

### For Coaches/Analysts
1. **Launch app at start of week**
2. **Generate report after game**
3. **Download immediately**
4. **Keep app open if generating multiple reports**
5. **Close app when done** (Ctrl+C)

### For Developers
1. **Use command line** for automation
2. **Edit templates directly** for customization
3. **Use batch mode** for multiple reports
4. **Keep Shiny for demos** and non-technical users

### For Teams
1. **One person runs the app** per week
2. **Share PDF** with coaching staff
3. **Archive reports** in organized folders
4. **Clear cache weekly** to free space

---

## 📸 **Screenshots & Walkthrough**

### Step 1: Launch
```
$ source("run_app.R")
Launching Shiny app...
Listening on http://127.0.0.1:3838
```

### Step 2: Configure
- Select Week: 1
- Opponent: SMU
- Next Opponent: Samford

### Step 3: Generate
- Click "Generate Report"
- See "Processing..." message
- Wait 5-60 seconds

### Step 4: Download
- Click "Download Report (PDF)"
- Save file
- Done!

---

## 🔄 **Workflow Example**

**Monday Morning (Week 1):**
```r
# Start app
source("run_app.R")

# Generate report
# Week: 1
# Opponent: SMU (just played)
# Next: Samford (upcoming)
# Click Generate → Download

# Close app (Ctrl+C)
```

**Next Monday (Week 2):**
```r
# Start app
source("run_app.R")

# Generate report
# Week: 2
# Opponent: Samford (just played)
# Next: Kansas (upcoming)
# Click Generate → Download

# Close app
```

---

## 🌟 **Why Use the Shiny App?**

✅ **No Coding Required** - Perfect for non-programmers
✅ **Visual Interface** - See what you're doing
✅ **Error Prevention** - Dropdowns prevent typos
✅ **Instant Feedback** - Know if it's working
✅ **User Friendly** - Coaches can run it themselves
✅ **Professional** - Looks polished and modern
✅ **Self-Contained** - Everything in one interface

---

## 🎓 **Training New Users**

### 5-Minute Training Script

1. **"This is the app interface"** (show)
2. **"Select your week, current opponent, and next opponent"** (demo)
3. **"Click this button to generate"** (click)
4. **"Wait for the success message"** (wait)
5. **"Download your PDF here"** (download)
6. **"That's it!"**

**Practice once, they'll know it forever.**

---

## 📧 **Support**

Having issues? Check:
1. **Help tab** in the app
2. **README.md** for full documentation
3. **example_usage.R** for code examples
4. **QUICKSTART.md** for command-line alternative

---

**Ready to start? Run the app:**

```r
source("run_app.R")
```

**Enjoy your user-friendly report generation! 🎉**
