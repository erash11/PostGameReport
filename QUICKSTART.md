# Quick Start Guide

Get started with the Post-Game Report system in 5 minutes!

## 📦 Installation

### 1. Install Required Packages

```r
# Run this once to install all dependencies
install.packages(c(
  "dplyr", "tidyr", "ggplot2", "cfbfastR",
  "flextable", "pagedown", "scales", "officer",
  "cowplot", "magick", "ggimage", "tidyverse",
  "ggdark", "janitor", "grid", "yaml", "rmarkdown"
))
```

## 🚀 Generate Your First Report

### Option 1: From R Console (Easiest)

```r
# Source the report generator
source("generate_report.R")

# Generate report for Week 1
generate_weekly_report(
  week = 1,
  opponent = "SMU",
  next_opponent = "Samford"
)

# That's it! Check ./reports/ for the PDF
```

### Option 2: From Command Line

```bash
Rscript generate_report.R --week 1 --opponent "SMU" --next "Samford"
```

### Option 3: Batch Mode (Multiple Reports)

1. Edit `report_config.yaml`:
```yaml
games:
  - week: 1
    opponent: "SMU"
    opponent_abbr: "SMU"
    next_opponent: "Samford"
    next_opponent_abbr: "Samford"
  - week: 2
    opponent: "Samford"
    opponent_abbr: "SAM"
    next_opponent: "Kansas"
    next_opponent_abbr: "KU"
```

2. Run batch generation:
```bash
Rscript generate_report.R --batch
```

## 🎯 Try Advanced Features

### Player Statistics

```r
source("feature_analytics.R")

# Calculate player stats
player_stats <- calculate_player_stats(current_game_off_data)

# View top receivers
print(player_stats$receiving)
```

### Opponent Tendencies

```r
# Analyze what opponent likes to do
tendencies <- calculate_down_distance_tendencies(next_season_off_data)
print(tendencies)
```

### Identify Advantages

```r
# Find matchup exploits
exploits <- identify_exploits(
  bu_season_off_agg,
  next_season_def_agg,
  power_four_off_agg,
  power_four_def_agg
)
print(exploits$recommendation)
```

## 📁 Project Structure

After first run, you'll have:

```
PostGameReport/
├── BU_Post_2024.Rmd          # Your report template
├── generate_report.R          # Run this to make reports
├── helper_functions.R         # Auto-used by template
├── feature_analytics.R        # Advanced features
├── data_loader.R             # Data caching
├── report_config.yaml        # Configuration
├── cache/                    # Auto-created data cache
│   └── cfb_pbp_2025.rds     # Cached data
└── reports/                  # Auto-created output
    └── BU_vs_SMU_Week1.pdf  # Your report!
```

## ⚡ Performance Tips

### First Run
- Downloads data from cfbfastR API (~30-60 seconds)
- Automatically caches for future use

### Subsequent Runs
- Uses cached data (~5-10 seconds)
- Cache expires after 24 hours

### Force Refresh
```r
generate_weekly_report(
  week = 1,
  opponent = "SMU",
  next_opponent = "Samford",
  force_reload = TRUE
)
```

## 🔧 Customization

### Change Team Colors

Edit in `BU_Post_2024.Rmd`:
```r
bu_color <- "#003015"       # Your team's primary color
bu_alt_color <- "#FFB81C"   # Your team's secondary color
```

### Add Custom Logo

1. Save logo as PNG in project directory
2. Reference in template:
```r
custom_logo <- image_read("my_logo.png")
```

### Configure Cache Settings

Edit `report_config.yaml`:
```yaml
data:
  cache_enabled: true
  cache_dir: "./cache"
  cache_refresh_hours: 24    # Adjust refresh time
```

## 🆘 Troubleshooting

### "Cannot find function..."
```r
# Make sure you sourced the files
source("helper_functions.R")
source("feature_analytics.R")
source("data_loader.R")
```

### "Template not found"
```r
# Check template exists
file.exists("BU_Post_2024.Rmd")  # Should be TRUE
```

### Slow Data Loading
```r
# Check cache status
source("data_loader.R")
get_cache_status()

# Cache should exist after first run
```

### Clear Everything and Start Fresh
```r
source("data_loader.R")
clear_cache()  # Removes all cached data
```

## 📚 Next Steps

1. **Read the full README.md** for all features
2. **Check example_usage.R** for code examples
3. **Customize your template** (BU_Post_2024.Rmd)
4. **Set up weekly config** (report_config.yaml)

## 💡 Pro Tips

1. **Weekly Workflow**:
   - Update `report_config.yaml` with new game
   - Run `generate_report.R --batch`
   - Done!

2. **Multiple Teams**:
   - Duplicate template
   - Change team name in config
   - Run separately

3. **Advanced Analysis**:
   - Use `example_usage.R` as starting point
   - Combine multiple analytics functions
   - Export to CSV for Excel analysis

## 🎓 Learning Resources

- **Full Documentation**: See README.md
- **Function Reference**: Check function headers in source files
- **Examples**: Run example_usage.R line by line

---

**Need Help?** Check the documentation or review example_usage.R

**Ready to go?** Run your first report:
```r
source("generate_report.R")
generate_weekly_report(week = 1, opponent = "SMU", next_opponent = "Samford")
```
