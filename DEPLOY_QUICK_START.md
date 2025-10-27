# ⚡ Quick Deploy to Web

**Super fast guide to publish your Shiny app online in 10 minutes.**

---

## 🚀 **3 Steps to Deploy**

### **STEP 1: Setup (One-Time, 2 minutes)**

1. **Go to [shinyapps.io](https://www.shinyapps.io/)**
2. **Click "Sign Up"** → Choose **Free** plan
3. **Get your token:**
   - Click your name (top right)
   - Click "Tokens"
   - Click "Show"
   - Click "Copy to clipboard"

4. **In R, paste the token:**
```r
# Install deployment tool
install.packages("rsconnect")

# Paste YOUR token command (looks like this):
library(rsconnect)
rsconnect::setAccountInfo(
  name='YOUR_NAME',
  token='YOUR_TOKEN',
  secret='YOUR_SECRET'
)
```

**Done! Now you can deploy.**

---

### **STEP 2: Prepare (2 minutes)**

```r
# Run preparation script
source("prepare_deployment.R")

# Follow prompts:
# - Install missing packages? → y
# - Pre-cache data? → y (recommended)
# - Test locally? → y (if first time)
# - Save deployment script? → y
```

This will:
- ✅ Check everything is ready
- ✅ Download and cache data
- ✅ Create deployment script

---

### **STEP 3: Deploy! (5 minutes)**

**Option A: Use the generated script**
```r
source("deploy_app.R")
```

**Option B: Deploy manually**
```r
library(rsconnect)

deployApp(
  appName = "baylor-football-analytics",
  appTitle = "Baylor Football Analytics",
  forceUpdate = TRUE
)
```

**Wait 2-5 minutes** while it deploys...

**You'll get a URL:**
```
https://YOUR_NAME.shinyapps.io/baylor-football-analytics/
```

**Share this URL with anyone!** 🎉

---

## 📱 **That's It!**

Your app is now live on the internet. Anyone can access it with the URL.

**No server setup. No hosting fees (free tier). No maintenance.**

---

## 🔄 **Update Deployed App**

Made changes? Re-deploy:

```r
# Just run deploy again
source("deploy_app.R")

# Or
library(rsconnect)
deployApp(appName = "baylor-football-analytics", forceUpdate = TRUE)
```

---

## 💰 **Free Tier Limits**

- 5 apps
- 25 hours/month active use
- App sleeps after 15 min idle
- Auto-wakes when someone visits

**Perfect for weekly report generation!**

Upgrade to $9/month for 250 hours if needed.

---

## 🆘 **Troubleshooting**

### "Package not found"
```r
# Install missing packages
source("prepare_deployment.R")
```

### "Deployment failed"
```r
# Check logs at shinyapps.io dashboard
# Usually means missing package or file
```

### "App is slow"
```r
# Pre-cache data before deploying
source("prepare_deployment.R")
# Answer 'y' to pre-cache data
```

### "Can't find token"
```r
# Go to shinyapps.io
# Your name > Tokens > Show > Copy
# Paste in R console
```

---

## 📊 **Monitor Your App**

**shinyapps.io Dashboard:**
- See how many people use it
- Check hours used (stay under 25/month for free)
- View error logs
- Download usage stats

**URL:** https://www.shinyapps.io/admin/

---

## 🎯 **Pro Tips**

1. **Pre-cache data** → Faster app startup
2. **Test locally first** → Catch errors before deploying
3. **Use short app names** → Easier to share URL
4. **Monitor hours** → Don't exceed free tier
5. **Re-deploy often** → Easy to update

---

## 📞 **Need More Help?**

- **Full Guide:** See DEPLOYMENT_GUIDE.md
- **shinyapps.io Docs:** https://docs.posit.co/shinyapps.io/
- **Shiny Help:** https://shiny.rstudio.com/

---

## ✅ **Deployment Checklist**

Before deploying, make sure:

- [ ] Created shinyapps.io account
- [ ] Got and pasted token
- [ ] Ran `prepare_deployment.R`
- [ ] All checks passed (✓)
- [ ] Tested app locally
- [ ] Ready to deploy!

Then:
- [ ] Run `deploy_app.R` or `deployApp()`
- [ ] Wait for deployment
- [ ] Test live URL
- [ ] Share with team
- [ ] Celebrate! 🎉

---

## 🌐 **Your Live App**

After deployment, you'll have:

**URL Pattern:**
```
https://YOUR_ACCOUNT.shinyapps.io/baylor-football-analytics/
```

**Example:**
```
https://johndoe.shinyapps.io/baylor-football-analytics/
```

**Share this URL** with coaches, analysts, anyone!

They can:
- Generate reports (no R required!)
- Download PDFs
- View analytics
- All from their browser

---

## 🎓 **Training Users**

Tell your team:

1. **"Go to this URL"** (send them the link)
2. **"Select your options"** (week, opponents)
3. **"Click Generate"** (big button)
4. **"Download PDF"** (when ready)

**That's all they need to know!**

---

## 💡 **Why This is Great**

✅ **No installation** - Works in any browser
✅ **No coding** - Just clicks
✅ **Always available** - 24/7 access
✅ **Auto-updated** - Re-deploy pushes changes
✅ **Mobile friendly** - Works on phones/tablets
✅ **Free tier** - No cost for light use

---

**Ready? Let's deploy!**

```r
source("prepare_deployment.R")
```

**Then:**

```r
source("deploy_app.R")
```

**Done! 🚀**
