# Baylor Football Post-Game Analytics Report

Comprehensive football analytics system for generating post-game reports with advanced metrics, visualizations, and game planning insights.

## 🎯 Features

### Core Analytics
- **EPA (Expected Points Added)** analysis by game, play type, and down
- **Win Probability** tracking throughout the game
- **Success Rate** metrics for offense and defense
- **Opponent Comparison** vs Power 4 averages

### Advanced Features (NEW!)
- **Player-Level Statistics**: Individual performance tracking for QBs, RBs, and WRs
- **Situational Analytics**: Red zone, 3rd down, 4th down, and goal line efficiency
- **Opponent Tendencies**: Down & distance, field position, and game script analysis
- **WPA Analysis**: Win probability added for critical plays
- **Explosive Play Tracking**: Identification and analysis of big plays
- **Drive Efficiency**: Drive-level metrics and scoring analysis
- **Exploit Identification**: Automated matchup advantage detection
- **Game Planning Insights**: Data-driven recommendations

### Automation & Efficiency
- **Shiny Web App**: Point-and-click interface for non-technical users (NEW!)
- **Data Caching**: Automatic caching to reduce API calls and improve speed
- **Reusable Functions**: Modular code design for easy maintenance
- **Batch Processing**: Generate multiple reports at once
- **Custom Themes**: Consistent, professional visualizations
- **Command-Line Interface**: Easy report generation from terminal

## 📁 Project Structure

```
PostGameReport/
├── BU_Post_2024.Rmd           # Main report template
├── TSU.png                    # Custom team logo
│
├── WEB APP (NEW!)
├── app.R                      # Shiny web interface
├── run_app.R                  # App launcher
├── SHINY_APP_GUIDE.md         # Web app documentation
├── prepare_deployment.R       # Deployment preparation script
├── DEPLOYMENT_GUIDE.md        # Full deployment guide
├── DEPLOY_QUICK_START.md      # Quick deployment (10 min)
│
├── CORE SYSTEM
├── helper_functions.R         # Reusable aggregation & chart functions
├── data_loader.R              # Data loading with caching
├── feature_analytics.R        # Advanced analytics features
├── generate_report.R          # Automated report generation
├── report_config.yaml         # Configuration file
│
├── DOCUMENTATION
├── README.md                  # This file
├── QUICKSTART.md              # 5-minute guide
├── example_usage.R            # Code examples
│
└── OUTPUT (auto-created)
    ├── cache/                 # Data cache directory
    └── reports/               # PDF reports
```

## 🌐 NEW: Web App Interface (Easiest!)

**The easiest way to generate reports - no coding required!**

```r
# Launch the Shiny web app
source("run_app.R")
```

The app will open in your browser with a simple point-and-click interface:
- Select week and opponents from dropdowns
- Click "Generate Report" button
- Download your PDF!

**Perfect for coaches and non-technical users.** See [SHINY_APP_GUIDE.md](SHINY_APP_GUIDE.md) for details.

### 🌍 Deploy to Web (Share with Anyone!)

Publish your Shiny app online so anyone can access it:

```r
# 1. Prepare for deployment
source("prepare_deployment.R")

# 2. Deploy to shinyapps.io (free!)
source("deploy_app.R")

# 3. Share your URL with the team!
```

**Result:** `https://yourname.shinyapps.io/baylor-football-analytics/`

Anyone with the URL can generate reports - no R installation needed! See [DEPLOY_QUICK_START.md](DEPLOY_QUICK_START.md) for step-by-step guide.

---

## 🚀 Quick Start (Command Line)

### 1. Generate a Single Report

#### From R Console:
```r
source("generate_report.R")

generate_weekly_report(
  week = 1,
  opponent = "SMU",
  next_opponent = "Samford"
)
```

#### From Command Line:
```bash
Rscript generate_report.R --week 1 --opponent "SMU" --next "Samford"
```

### 2. Generate Reports from Config File

Edit `report_config.yaml`:
```yaml
games:
  - week: 1
    opponent: "SMU"
    opponent_abbr: "SMU"
    next_opponent: "Samford"
    next_opponent_abbr: "Samford"
```

Then run:
```bash
Rscript generate_report.R --batch
```

### 3. Use Advanced Features

```r
source("feature_analytics.R")

# Player statistics
player_stats <- calculate_player_stats(bu_off_data)
top_performers <- get_top_performers(player_stats, n = 5)

# Situational analytics
red_zone <- calculate_red_zone_stats(current_game_data)
third_down <- calculate_third_down_stats(current_game_data)

# Opponent tendencies
tendencies <- calculate_down_distance_tendencies(next_season_off_data)
recommendations <- generate_tendency_recommendations(tendencies)

# Exploit identification
exploits <- identify_exploits(bu_season_off_agg, next_season_def_agg,
                              power_four_off_agg, power_four_def_agg)
```

## 📊 Available Analytics Functions

### Helper Functions (`helper_functions.R`)
- `calculate_team_agg_by_game()` - Aggregate stats by game
- `calculate_team_agg_by_play()` - Aggregate stats by play
- `calculate_team_agg_by_down()` - Aggregate stats by down
- `create_epa_comparison_chart()` - EPA comparison visualizations
- `create_epa_scatter_plot()` - Scatter plot with quadrants
- `create_down_distance_chart()` - Down & distance charts
- `bu_theme()` - Custom ggplot2 theme

### Data Loading (`data_loader.R`)
- `load_cfb_data_cached()` - Load play-by-play with caching
- `load_team_info_cached()` - Load team info with caching
- `get_cache_status()` - Check cache status
- `clear_cache()` - Clear cache files

### Feature Analytics (`feature_analytics.R`)

#### Player Analytics
- `calculate_player_stats()` - Individual player performance
- `get_top_performers()` - Top N players by metric

#### Situational
- `calculate_red_zone_stats()` - Red zone efficiency
- `calculate_third_down_stats()` - 3rd down conversions
- `calculate_fourth_down_stats()` - 4th down decisions
- `calculate_quarter_performance()` - By quarter breakdown
- `calculate_goal_line_stats()` - Goal line efficiency

#### Tendencies
- `calculate_down_distance_tendencies()` - Play calling patterns
- `calculate_field_position_tendencies()` - Field position impact
- `calculate_game_script_tendencies()` - Situation-based tendencies

#### WPA & Explosives
- `calculate_wpa_stats()` - Win probability added
- `get_top_wpa_plays()` - Most impactful plays
- `calculate_explosive_plays()` - Big play analysis
- `list_explosive_plays()` - All explosive plays

#### Drive Efficiency
- `calculate_drive_efficiency()` - Drive-level metrics

#### Game Planning
- `identify_exploits()` - Matchup advantages
- `generate_tendency_recommendations()` - Strategic recommendations

## ⚙️ Configuration

Edit `report_config.yaml` to customize:

```yaml
season: 2025

team:
  name: "Baylor"
  abbreviation: "BU"

power_conferences:
  - "SEC"
  - "Big 12"
  - "Big Ten"
  - "ACC"

data:
  cache_enabled: true
  cache_dir: "./cache"
  cache_refresh_hours: 24

output:
  format: "pdf"
  output_dir: "./reports"

analysis:
  include_player_stats: true
  include_situational: true
  include_tendency_report: true
  include_wpa_analysis: true
```

## 🎨 Customization

### Custom Team Logos
Place custom logos in the project directory and reference in the template:
```r
opp_logo <- image_read("TSU.png")
```

### Custom Color Schemes
Modify team colors in the report template:
```r
bu_color <- "#003015"       # Baylor Green
bu_alt_color <- "#FFB81C"   # Baylor Gold
```

### Add New Metrics
Extend `feature_analytics.R` with custom functions:
```r
calculate_custom_metric <- function(data) {
  # Your custom analysis
}
```

## 📈 Performance Optimization

### Cache Usage
- First run: ~30-60 seconds (downloads data)
- Cached runs: ~5-10 seconds
- Cache expires: 24 hours (configurable)

### Batch Processing
Generate multiple reports efficiently:
```r
games <- data.frame(
  week = c(1, 2, 3),
  opponent = c("SMU", "Samford", "Kansas"),
  opponent_abbr = c("SMU", "SAM", "KU"),
  next_opponent = c("Samford", "Kansas", "TCU"),
  next_opponent_abbr = c("SAM", "KU", "TCU")
)

generate_batch_reports(games)
```

### Clear Old Cache
```r
source("data_loader.R")
clear_cache()  # Clear all
clear_cache(season = 2024)  # Clear specific season
```

## 🔍 Example Analyses

### Find Top Pass Catchers
```r
player_stats <- calculate_player_stats(bu_off_data)
player_stats$receiving %>%
  arrange(desc(yards)) %>%
  head(10)
```

### Identify Red Zone Weaknesses
```r
red_zone <- calculate_red_zone_stats(next_season_def_data)
red_zone %>%
  filter(td_rate > 30) %>%
  arrange(desc(td_rate))
```

### Get Critical Plays
```r
wpa_data <- calculate_wpa_stats(current_game_data, "Baylor", home_team)
top_plays <- get_top_wpa_plays(wpa_data, n = 10)
print(top_plays$positive)  # Game-winning plays
```

### Analyze Opponent Tendencies
```r
tendencies <- calculate_down_distance_tendencies(next_season_off_data)
tendencies %>%
  filter(down == 3, tendency == "Pass Heavy") %>%
  select(distance_category, pass_rate, success_rate)
```

## 🛠️ Troubleshooting

### Common Issues

**Data Loading Fails**
```r
# Force reload from API
load_cfb_data_cached(force_reload = TRUE)
```

**Missing Logos**
```r
# Check team info
team_info %>% filter(school == "YourTeam") %>% select(school, logo)
```

**Report Generation Error**
```r
# Check template exists
file.exists("BU_Post_2024.Rmd")

# Validate data
source("helper_functions.R")
validate_data(data)
```

**Cache Issues**
```r
# Check cache status
get_cache_status()

# Clear and reload
clear_cache()
```

## 📊 Output

Reports are generated as PDF files in the `reports/` directory:
```
reports/
├── BU_vs_SMU_Week1_20250101.pdf
├── BU_vs_Samford_Week2_20250108.pdf
└── BU_vs_Kansas_Week3_20250115.pdf
```

## 🔄 Weekly Workflow

1. **Update Config**: Add new game to `report_config.yaml`
2. **Generate Report**: Run `generate_report.R`
3. **Review Analytics**: Examine advanced metrics
4. **Share Insights**: Distribute PDF to coaching staff

## 📝 Dependencies

Required R packages:
```r
install.packages(c(
  "dplyr", "tidyr", "ggplot2", "cfbfastR",
  "flextable", "pagedown", "scales", "officer",
  "cowplot", "magick", "ggimage", "tidyverse",
  "ggdark", "janitor", "grid", "yaml", "rmarkdown"
))
```

## 🤝 Contributing

To add new features:
1. Add function to `feature_analytics.R`
2. Update this README
3. Add example to `example_usage.R`
4. Test with sample data

## 📧 Support

For issues or questions:
- Check the example files
- Review function documentation
- Examine the original template

## 📄 License

For Baylor Football Analytics use.

## 🎓 Credits

- Data Source: cfbfastR
- Analytics Framework: Applied Performance Football Analytics
- Enhanced Features: Claude Code Optimization 2025
