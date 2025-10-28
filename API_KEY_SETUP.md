# API Key Setup Guide

Your Shiny app now requires an API key to fetch data from CollegeFootballData.com.

---

## Quick Start

### Step 1: Get Your API Key

1. Go to **https://collegefootballdata.com/**
2. Sign up or log in
3. Navigate to **API Keys** in your account
4. Generate a new key or copy your existing key

---

## For Posit Connect Deployment

### Add API Key as Environment Variable:

1. Open your app in **Posit Connect** web interface
2. Go to the **"Vars"** or **"Environment Variables"** tab
3. Click **"Add Variable"** or **"New Environment Variable"**
4. Enter:
   - **Name**: `CFBD_API_KEY`
   - **Value**: `your-actual-api-key-here`
5. Click **"Save"**
6. **Restart** or **Redeploy** your app

### Verify It Works:

After redeploying, check the logs. You should see:
```
✓ CFBD API key registered successfully
```

If you see a warning about missing API key, double-check:
- Variable name is exactly `CFBD_API_KEY` (case-sensitive)
- You saved and restarted the app
- The key is valid (test at https://collegefootballdata.com/)

---

## For Local Development (Optional)

If you want to run the app locally:

### Setup:

1. Copy the template file:
   ```bash
   cp .Renviron.example .Renviron
   ```

2. Edit `.Renviron` and replace `your-api-key-here` with your actual key:
   ```
   CFBD_API_KEY=your-actual-api-key-here
   ```

3. Restart your R session

4. Run the app:
   ```r
   shiny::runApp()
   ```

**IMPORTANT:** Never commit `.Renviron` to git! It's already in `.gitignore`.

---

## Troubleshooting

### Error: "CFBD API key not registered"

**Cause:** Environment variable not set or empty

**Fix:**
- In Posit Connect: Add the `CFBD_API_KEY` variable (see above)
- Locally: Create `.Renviron` file (see above)
- Restart the app/R session

### Error: "Invalid API key"

**Cause:** Key is incorrect or expired

**Fix:**
1. Go to https://collegefootballdata.com/
2. Generate a new API key
3. Update the environment variable
4. Restart

### Error: "Rate limit exceeded"

**Cause:** Too many API requests

**Fix:**
- The app uses caching to minimize API calls
- Wait a few minutes and try again
- Check if your API key has rate limits

---

## How It Works

The app automatically:
1. Looks for `CFBD_API_KEY` environment variable
2. Registers it with cfbfastR package
3. Uses it for all API requests
4. Caches data to minimize API calls

You only need to set the environment variable once in Posit Connect!

---

## Security Best Practices

- ✅ Store API keys in environment variables
- ✅ Use Posit Connect's built-in variable management
- ✅ Never commit API keys to git
- ✅ `.Renviron` is in `.gitignore`
- ❌ Don't hardcode keys in R files
- ❌ Don't share keys publicly

---

## Need Help?

- **API Key Issues:** Contact https://collegefootballdata.com/
- **Posit Connect Setup:** See Posit Connect documentation
- **App Issues:** Check the deployment logs in Posit Connect

---

**Quick Summary:**

1. Get API key from https://collegefootballdata.com/
2. Add to Posit Connect as `CFBD_API_KEY` environment variable
3. Restart app
4. Done! ✅
