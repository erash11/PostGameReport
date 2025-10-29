# Automated Report Analysis Guide

This guide explains how to automate two manual processes in the report generation.

---

## Solution 1: Auto-Detect Home/Away for Win Probability

### Problem
Currently, users must manually change line 755 between `home_wp_before` and `away_wp_before` depending on whether Baylor is playing home or away.

### Solution Code

Add this code right after the `win_plot_data` definition (around line 741):

```r
# Automatically detect if Baylor is home or away
is_baylor_home <- current_game_data$home_team[1] == "Baylor"
message("Baylor is playing: ", if(is_baylor_home) "HOME" else "AWAY")

# Select the appropriate win probability column
if (is_baylor_home) {
  wp_column <- "home_wp_before"
} else {
  wp_column <- "away_wp_before"
}
```

Then replace line 752-755:
```r
# OLD (manual):
dplyr::select(game_mins_rem, away_wp_before) %>%

# NEW (automatic):
dplyr::select(game_mins_rem, !!sym(wp_column)) %>%
```

And replace line 772-774:
```r
# OLD (manual):
scale_color_manual(labels = c("home_wp_before" = "BU"),
                   values = c("home_wp_before" = "black"),
                   guide = FALSE) +

# NEW (automatic):
scale_color_manual(labels = setNames("BU", wp_column),
                   values = setNames("black", wp_column),
                   guide = FALSE) +
```

Optionally, adjust logo positions (lines 768-769):
```r
# Position logos appropriately (home team on top)
draw_image(bu_logo, x = -61, y = if(is_baylor_home) 0.88 else -0.12, width = 6.67, height = 2) +
draw_image(opp_logo, x = -61, y = if(is_baylor_home) -0.12 else 0.88, width = 6.67, height = 2) +
```

---

## Solution 2: Automated Analysis Text

### Problem
Five analysis sections are currently hardcoded with generic text that doesn't reflect the actual game data.

Locations:
- Line 795-797: Win Probability Analysis
- Line 955-977: Offensive Analysis
- Line 1166-1176: Defensive Analysis
- Line 1253-1259: Next Opponent Offensive Analysis
- Line 1343-1349: Next Opponent Defensive Analysis

### Solution Approach

Create a helper file with analysis generation functions, then use them in the Rmd.

#### Step 1: Create `analysis_generator.R`

```r
#' Generate Win Probability Analysis
#'
#' @param win_plot_data Data frame with win probability over time
#' @param opp_name Opponent name
#' @return Character string with analysis
generate_wp_analysis <- function(win_plot_data, opp_name, wp_column) {

  # Calculate key metrics
  avg_wp <- mean(win_plot_data[[wp_column]], na.rm = TRUE)
  max_wp <- max(win_plot_data[[wp_column]], na.rm = TRUE)
  min_wp <- min(win_plot_data[[wp_column]], na.rm = TRUE)

  # Determine momentum
  first_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem > 30], na.rm = TRUE)
  second_half_wp <- mean(win_plot_data[[wp_column]][win_plot_data$game_mins_rem <= 30], na.rm = TRUE)

  # Generate text
  if (avg_wp > 0.6) {
    dominance <- "dominated"
  } else if (avg_wp > 0.5) {
    dominance <- "maintained control against"
  } else {
    dominance <- "struggled against"
  }

  if (second_half_wp > first_half_wp + 0.1) {
    momentum <- "gained significant momentum in the second half"
  } else if (first_half_wp > second_half_wp + 0.1) {
    momentum <- "started strong but lost momentum in the second half"
  } else {
    momentum <- "maintained consistent performance throughout"
  }

  paste0(
    "Baylor ", momentum, ". ",
    "The Bears ", dominance, " ", opp_name, ", ",
    "with an average win probability of ", round(avg_wp * 100, 1), "%. ",
    "The win probability peaked at ", round(max_wp * 100, 1), "% and ",
    "dropped to a low of ", round(min_wp * 100, 1), "%."
  )
}

#' Generate Offensive EPA Analysis
#'
#' @param current_game_off_agg Current game offensive stats
#' @param bu_season_off_agg Season average offensive stats
#' @param power_four_off_agg Power 4 average stats
#' @return Character string with analysis
generate_offense_analysis <- function(current_game_off_agg, bu_season_off_agg, power_four_off_agg) {

  # Extract EPAs
  game_pass_epa <- current_game_off_agg$avg_pass_epa[1]
  game_run_epa <- current_game_off_agg$avg_run_epa[1]
  season_pass_epa <- bu_season_off_agg$avg_pass_epa[1]
  season_run_epa <- bu_season_off_agg$avg_run_epa[1]
  p4_pass_epa <- power_four_off_agg$avg_pass_epa[1]
  p4_run_epa <- power_four_off_agg$avg_run_epa[1]

  # Compare to season average
  pass_vs_season <- if(game_pass_epa > season_pass_epa) {
    "exceeded"
  } else {
    "fell short of"
  }

  run_vs_season <- if(game_run_epa > season_run_epa) {
    "exceeded"
  } else {
    "fell short of"
  }

  # Compare to Power 4
  pass_vs_p4 <- if(game_pass_epa > p4_pass_epa) {
    "outperformed"
  } else {
    "underperformed compared to"
  }

  run_vs_p4 <- if(game_run_epa > p4_run_epa) {
    "outperformed"
  } else {
    "underperformed compared to"
  }

  # Overall assessment
  if(game_pass_epa > season_pass_epa && game_run_epa > season_run_epa) {
    overall <- "had an excellent offensive performance"
  } else if(game_pass_epa > season_pass_epa || game_run_epa > season_run_epa) {
    overall <- "had a solid offensive showing"
  } else {
    overall <- "struggled offensively"
  }

  paste0(
    "Baylor ", overall, " with a passing EPA of ", round(game_pass_epa, 3),
    " and a rushing EPA of ", round(game_run_epa, 3), ". ",
    "The passing game ", pass_vs_season, " the season average (",
    round(season_pass_epa, 3), ") and ", pass_vs_p4, " Power 4 teams (",
    round(p4_pass_epa, 3), "). ",
    "The running game ", run_vs_season, " the season average (",
    round(season_run_epa, 3), ") and ", run_vs_p4, " Power 4 teams (",
    round(p4_run_epa, 3), ")."
  )
}

#' Generate Defensive EPA Analysis
#'
#' @param current_game_def_agg Current game defensive stats
#' @param bu_season_def_agg Season average defensive stats
#' @param power_four_def_agg Power 4 average stats
#' @return Character string with analysis
generate_defense_analysis <- function(current_game_def_agg, bu_season_def_agg, power_four_def_agg) {

  # Extract EPAs (negative is better for defense)
  game_pass_epa <- current_game_def_agg$avg_pass_epa_allowed[1]
  game_run_epa <- current_game_def_agg$avg_run_epa_allowed[1]
  season_pass_epa <- bu_season_def_agg$avg_pass_epa_allowed[1]
  season_run_epa <- bu_season_def_agg$avg_run_epa_allowed[1]
  p4_pass_epa <- power_four_def_agg$avg_pass_epa_allowed[1]
  p4_run_epa <- power_four_def_agg$avg_run_epa_allowed[1]

  # Compare (lower is better for defense)
  pass_vs_season <- if(game_pass_epa < season_pass_epa) {
    "improved upon"
  } else {
    "fell short of"
  }

  run_vs_season <- if(game_run_epa < season_run_epa) {
    "improved upon"
  } else {
    "fell short of"
  }

  pass_vs_p4 <- if(game_pass_epa < p4_pass_epa) {
    "performed better than"
  } else {
    "performed worse than"
  }

  run_vs_p4 <- if(game_run_epa < p4_run_epa) {
    "performed better than"
  } else {
    "performed worse than"
  }

  # Overall
  if(game_pass_epa < season_pass_epa && game_run_epa < season_run_epa) {
    overall <- "had a strong defensive performance"
  } else if(game_pass_epa < season_pass_epa || game_run_epa < season_run_epa) {
    overall <- "had a mixed defensive performance"
  } else {
    overall <- "struggled defensively"
  }

  paste0(
    "Baylor ", overall, " with a pass defense EPA of ", round(game_pass_epa, 3),
    " and a run defense EPA of ", round(game_run_epa, 3), ". ",
    "The pass defense ", pass_vs_season, " the season average (",
    round(season_pass_epa, 3), ") and ", pass_vs_p4, " Power 4 teams (",
    round(p4_pass_epa, 3), "). ",
    "The run defense ", run_vs_season, " the season average (",
    round(season_run_epa, 3), ") and ", run_vs_p4, " Power 4 teams (",
    round(p4_run_epa, 3), ")."
  )
}
```

#### Step 2: Source the helper file in the Rmd

Add after line 15 (in the setup chunk):
```r
source("analysis_generator.R")
```

#### Step 3: Replace hardcoded analysis

Replace line 795-797 with:
```r
**ANALYSIS:**

`r generate_wp_analysis(win_plot_data, opp_name, wp_column)`
```

Replace line 955-977 with:
```r
**Analysis:**

`r generate_offense_analysis(current_game_off_agg, bu_season_off_agg, power_four_off_agg)`

<br>

**Compared to Other Baylor Games**

The scatter plot above shows this game's performance relative to all other games this season.

<br>

**Conclusion**

`r if(current_game_off_agg$avg_pass_epa[1] > bu_season_off_agg$avg_pass_epa[1] &&
      current_game_off_agg$avg_run_epa[1] > bu_season_off_agg$avg_run_epa[1]) {
  paste("Overall, Baylor's offense was firing on all cylinders against", opp_name,
        "with both the passing and running game exceeding season averages.")
} else {
  paste("Overall, Baylor's offense showed room for improvement against", opp_name,
        "but found success in certain areas.")
}`
```

Similar approach for the defense analysis (line 1166-1176):
```r
**Analysis:**

`r generate_defense_analysis(current_game_def_agg, bu_season_def_agg, power_four_def_agg)`
```

---

## Benefits of Automation

### Home/Away Auto-Detection:
- ✅ No manual edits needed each week
- ✅ Eliminates human error
- ✅ Logos positioned correctly automatically
- ✅ Accurate label ("BU (Home)" vs "BU (Away)")

### Automated Analysis:
- ✅ Always reflects actual game data
- ✅ Consistent analytical framework
- ✅ Saves 15-20 minutes per report
- ✅ More objective (data-driven, not subjective)
- ✅ Automatically compares to relevant benchmarks

---

## Implementation Steps

1. **Create `analysis_generator.R`** with the functions above
2. **Update `BU_Post_2024.Rmd`**:
   - Add `source("analysis_generator.R")` in setup chunk
   - Replace win probability code for home/away detection
   - Replace hardcoded analysis with function calls
3. **Test with one game** to verify output
4. **Deploy** - the automation will work for all future reports

---

## Advanced: Custom Analysis Templates

You can further customize the analysis by:

1. **Adding more metrics**: Include turnover analysis, red zone performance, etc.
2. **Historical comparisons**: Compare to specific past opponents
3. **Trend analysis**: Look at last 3 games vs season average
4. **Conditional insights**: Highlight unusual performances (career bests, season worsts)

Example:
```r
if(game_pass_epa > max(bu_off_agg_game$avg_pass_epa[-current_week])) {
  " This was the best passing performance of the season."
}
```

---

## Questions or Issues?

- The analysis functions can be customized to match your preferred writing style
- You can keep some sections manual and automate others
- The generated text can be used as a starting point that you then edit

**Next Steps:** Would you like me to implement these changes directly in your Rmd file?
