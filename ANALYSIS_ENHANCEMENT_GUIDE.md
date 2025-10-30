# Analysis Generator Enhancement Guide

## Current Implementation

### Overview
The automated analysis system uses `analysis_generator.R`, which contains functions that generate data-driven text based on game statistics. This file is sourced in `BU_Post_2024.Rmd` (line 45) and the functions are called inline within the R Markdown document.

### How It Works

1. **File Structure:**
   ```
   analysis_generator.R  ← Contains analysis functions
   BU_Post_2024.Rmd      ← Sources the file and calls functions
   ```

2. **Integration:**
   ```r
   # In BU_Post_2024.Rmd (line 45):
   source("analysis_generator.R")

   # Later in the document (line 852):
   `r generate_wp_analysis(win_plot_data, opp_name, wp_column)`
   ```

3. **Current Functions:**
   - `generate_wp_analysis()` - Win probability trends (line 852)
   - `generate_offense_analysis()` - Offensive EPA comparison (line 1012)
   - `generate_defense_analysis()` - Defensive EPA comparison (line 1219)
   - `generate_next_opp_offense_analysis()` - Next opponent scouting (line 1290)
   - `generate_next_opp_defense_analysis()` - Next opponent defense (line 1367)

---

## Available Data for Enhanced Analysis

### Data Already Calculated (but not currently used):
- **Success Rates:** `success_rate_pass`, `success_rate_run`
- **Down-specific EPA:** By down (1st, 2nd, 3rd, 4th)
- **Time-series data:** Win probability by minute
- **Raw play-by-play:** Available in `current_game_data`

### Data Available in Raw Play-by-Play:
- `down` - Down number (1st, 2nd, 3rd, 4th)
- `distance` - Yards to first down
- `yards_gained` - Yards on the play
- `play_type` - Type of play
- `scoring_play` - Whether play resulted in score
- `turnover` - Whether play was a turnover
- `EPA` - Expected Points Added per play
- `success` - Binary success indicator
- `wpa` - Win Probability Added
- `game_mins_rem` - Time remaining

---

## Enhancement Opportunities for Coaches

### 1. **Win Probability Analysis** (Currently Basic)

**Current Output:**
> "Baylor gained significant momentum in the second half. The Bears dominated Auburn, with an average win probability of 65.3%. The win probability peaked at 89.2% and dropped to a low of 42.1%."

**Enhanced Output with Coaching Insights:**

```r
generate_wp_analysis_enhanced <- function(win_plot_data, opp_name, wp_column, current_game_data) {

  # Existing metrics
  avg_wp <- mean(win_plot_data[[wp_column]], na.rm = TRUE)
  max_wp <- max(win_plot_data[[wp_column]], na.rm = TRUE)
  min_wp <- min(win_plot_data[[wp_column]], na.rm = TRUE)

  # NEW: Identify critical momentum shifts
  wp_data <- win_plot_data %>%
    arrange(desc(game_mins_rem)) %>%
    mutate(wp_change = c(0, diff(!!sym(wp_column))))

  # Find biggest positive swing (momentum gained)
  biggest_swing_idx <- which.max(wp_data$wp_change)
  biggest_swing_time <- wp_data$game_mins_rem[biggest_swing_idx]
  biggest_swing_value <- wp_data$wp_change[biggest_swing_idx]

  # Find biggest negative swing (momentum lost)
  biggest_drop_idx <- which.min(wp_data$wp_change)
  biggest_drop_time <- wp_data$game_mins_rem[biggest_drop_idx]
  biggest_drop_value <- wp_data$wp_change[biggest_drop_idx]

  # Analyze quarter-by-quarter performance
  q1_wp <- mean(wp_data[[wp_column]][wp_data$game_mins_rem > 45], na.rm = TRUE)
  q2_wp <- mean(wp_data[[wp_column]][wp_data$game_mins_rem > 30 & wp_data$game_mins_rem <= 45], na.rm = TRUE)
  q3_wp <- mean(wp_data[[wp_column]][wp_data$game_mins_rem > 15 & wp_data$game_mins_rem <= 30], na.rm = TRUE)
  q4_wp <- mean(wp_data[[wp_column]][wp_data$game_mins_rem <= 15], na.rm = TRUE)

  best_quarter <- which.max(c(q1_wp, q2_wp, q3_wp, q4_wp))
  worst_quarter <- which.min(c(q1_wp, q2_wp, q3_wp, q4_wp))

  # Generate coaching-relevant text
  base_text <- paste0(
    "**Game Flow:** Baylor's win probability averaged ", round(avg_wp * 100, 1),
    "%, peaking at ", round(max_wp * 100, 1), "% and dropping to ",
    round(min_wp * 100, 1), "%. "
  )

  momentum_text <- paste0(
    "**Critical Momentum Shift:** The biggest win probability gain (+",
    round(biggest_swing_value * 100, 1), "%) occurred around ",
    round(biggest_swing_time, 0), " minutes remaining. ",
    if(biggest_drop_value < -0.05) {
      paste0("The team struggled most around ", round(biggest_drop_time, 0),
             " minutes, losing ", round(abs(biggest_drop_value) * 100, 1), "% win probability. ")
    } else { "" }
  )

  quarter_text <- paste0(
    "**Quarterly Performance:** Q", best_quarter, " was the strongest quarter (",
    round(c(q1_wp, q2_wp, q3_wp, q4_wp)[best_quarter] * 100, 1), "% avg WP). ",
    if(worst_quarter != best_quarter) {
      paste0("Focus on improving Q", worst_quarter, " execution (",
             round(c(q1_wp, q2_wp, q3_wp, q4_wp)[worst_quarter] * 100, 1), "% avg WP).")
    } else { "Consistent performance across all quarters." }
  )

  paste0(base_text, "\n\n", momentum_text, "\n\n", quarter_text)
}
```

**Coaching Value:**
- Identifies when momentum shifted (e.g., "around 8 minutes remaining")
- Highlights which quarters need improvement
- Pinpoints critical sequences for film review

---

### 2. **Offensive Analysis** (Currently Missing Success Rates)

**Enhanced with Situational Analysis:**

```r
generate_offense_analysis_enhanced <- function(current_game_off_agg, bu_season_off_agg,
                                                power_four_off_agg, current_game_off_data) {

  # Existing EPA analysis (keep this)
  game_pass_epa <- current_game_off_agg$avg_pass_epa[1]
  game_run_epa <- current_game_off_agg$avg_run_epa[1]

  # NEW: Add success rate analysis
  game_pass_sr <- current_game_off_agg$success_rate_pass[1]
  game_run_sr <- current_game_off_agg$success_rate_run[1]
  season_pass_sr <- bu_season_off_agg$success_rate_pass[1]
  season_run_sr <- bu_season_off_agg$success_rate_run[1]

  # NEW: Situational analysis (3rd down, red zone, etc.)
  third_down_data <- current_game_off_data %>%
    filter(down == 3) %>%
    summarise(
      third_down_conv_rate = mean(success, na.rm = TRUE),
      third_down_epa = mean(EPA, na.rm = TRUE)
    )

  red_zone_data <- current_game_off_data %>%
    filter(yardline_100 <= 20) %>%
    summarise(
      red_zone_score_rate = mean(scoring_play, na.rm = TRUE),
      red_zone_epa = mean(EPA, na.rm = TRUE)
    )

  # NEW: Explosive play analysis
  explosive_plays <- current_game_off_data %>%
    filter((r_p == 'Pass' & yards_gained >= 20) | (r_p == 'Run' & yards_gained >= 10)) %>%
    nrow()

  total_plays <- nrow(current_game_off_data)
  explosive_rate <- explosive_plays / total_plays

  # Generate text
  epa_text <- paste0(
    "**EPA Performance:** Baylor's passing EPA (", round(game_pass_epa, 3),
    ") and rushing EPA (", round(game_run_epa, 3), ") "
  )

  efficiency_text <- paste0(
    "**Efficiency:** Pass success rate of ", round(game_pass_sr * 100, 1),
    "% (", if(game_pass_sr > season_pass_sr) "↑" else "↓", " vs season ",
    round(season_pass_sr * 100, 1), "%). Run success rate of ",
    round(game_run_sr * 100, 1), "% (",
    if(game_run_sr > season_run_sr) "↑" else "↓", " vs season ",
    round(season_run_sr * 100, 1), "%). "
  )

  situational_text <- paste0(
    "**Key Situations:** ",
    "3rd down conversion rate: ", round(third_down_data$third_down_conv_rate * 100, 1), "%. ",
    "Red zone scoring rate: ", round(red_zone_data$red_zone_score_rate * 100, 1), "%. ",
    "Explosive play rate: ", round(explosive_rate * 100, 1), "% (", explosive_plays,
    " plays of 20+ pass / 10+ rush yards)."
  )

  paste0(epa_text, "\n\n", efficiency_text, "\n\n", situational_text)
}
```

**Coaching Value:**
- Success rates show play-to-play efficiency
- 3rd down conversions = sustained drives
- Red zone scoring = finishing ability
- Explosive plays = big play capability

---

### 3. **Defensive Analysis** (Currently Missing Pressure/Turnovers)

**Enhanced with Game-Changing Plays:**

```r
generate_defense_analysis_enhanced <- function(current_game_def_agg, bu_season_def_agg,
                                                power_four_def_agg, current_game_def_data) {

  # Existing EPA analysis
  game_pass_epa <- current_game_def_agg$avg_pass_epa_allowed[1]
  game_run_epa <- current_game_def_agg$avg_run_epa_allowed[1]

  # NEW: Turnovers and game-changers
  turnovers <- current_game_def_data %>%
    filter(turnover == TRUE) %>%
    summarise(
      total_turnovers = n(),
      interceptions = sum(play_type == "Interception", na.rm = TRUE),
      fumbles = sum(play_type %in% c("Fumble Recovery (Own)", "Fumble Recovery (Opponent)"), na.rm = TRUE)
    )

  # NEW: Opponent 3rd down defense
  third_down_def <- current_game_def_data %>%
    filter(down == 3) %>%
    summarise(
      third_down_stops = mean(!success, na.rm = TRUE),
      third_down_epa = mean(EPA, na.rm = TRUE)
    )

  # NEW: Big plays allowed
  big_plays_allowed <- current_game_def_data %>%
    filter((r_p == 'Pass' & yards_gained >= 20) | (r_p == 'Run' & yards_gained >= 10)) %>%
    nrow()

  # Generate text
  epa_text <- paste0(
    "**EPA Allowed:** Pass defense EPA: ", round(game_pass_epa, 3),
    ". Run defense EPA: ", round(game_run_epa, 3), ". "
  )

  impact_text <- paste0(
    "**Game-Changing Plays:** ", turnovers$total_turnovers, " turnovers forced (",
    turnovers$interceptions, " INT, ", turnovers$fumbles, " fumbles). "
  )

  situational_text <- paste0(
    "**Situational Defense:** ",
    "3rd down stop rate: ", round(third_down_def$third_down_stops * 100, 1), "%. ",
    "Big plays allowed: ", big_plays_allowed, ". "
  )

  recommendation <- if(big_plays_allowed > 5) {
    "**Focus Area:** Limit explosive plays - ", big_plays_allowed,
    " plays of 20+ yards allowed is above target."
  } else {
    "**Strength:** Limited big plays effectively."
  }

  paste0(epa_text, "\n\n", impact_text, "\n\n", situational_text, "\n\n", recommendation)
}
```

**Coaching Value:**
- Turnovers = game-changing impact
- 3rd down stops = getting off the field
- Big plays allowed = defensive breakdowns to address

---

## Implementation Steps

### Step 1: Add Enhanced Functions to `analysis_generator.R`

Simply add the enhanced functions alongside the existing ones. The existing functions will continue to work.

### Step 2: Pass Additional Data to Functions

Update the function calls in `BU_Post_2024.Rmd`:

```r
# OLD:
`r generate_offense_analysis(current_game_off_agg, bu_season_off_agg, power_four_off_agg)`

# NEW:
`r generate_offense_analysis_enhanced(current_game_off_agg, bu_season_off_agg, power_four_off_agg, current_game_off_data)`
```

### Step 3: Test Incrementally

1. Start with one function (e.g., offense)
2. Test report generation
3. Review output with coaches
4. Refine based on feedback
5. Move to next section

---

## Example: Quick Win - Add Success Rates

**Easiest enhancement to implement right now:**

```r
# In analysis_generator.R, update generate_offense_analysis():

generate_offense_analysis <- function(current_game_off_agg, bu_season_off_agg, power_four_off_agg) {

  # Existing EPA code stays the same...

  # ADD THIS:
  game_pass_sr <- current_game_off_agg$success_rate_pass[1]
  game_run_sr <- current_game_off_agg$success_rate_run[1]

  success_text <- paste0(
    " Success rates: ", round(game_pass_sr * 100, 1), "% passing, ",
    round(game_run_sr * 100, 1), "% rushing."
  )

  # Append to existing output
  paste0(existing_text, success_text)
}
```

**This adds value immediately** because success rate is already calculated but not displayed!

---

## Benefits for Coaches

### Current Analysis Provides:
- ✅ EPA comparisons (offensive efficiency)
- ✅ Season vs game performance
- ✅ Power 4 benchmarking

### Enhanced Analysis Adds:
- ✅ **Critical moments** - When did momentum shift?
- ✅ **Situational performance** - 3rd downs, red zone
- ✅ **Game-changing plays** - Turnovers, explosive plays
- ✅ **Specific recommendations** - What to focus on in film
- ✅ **Success rates** - Play-to-play efficiency
- ✅ **Quarter-by-quarter** - Identify patterns

### Coaching Questions Answered:
1. "When did we lose/gain momentum?" → **Win probability swings**
2. "How did we do in the red zone?" → **Red zone scoring rate**
3. "Did we convert 3rd downs?" → **3rd down efficiency**
4. "Did we create turnovers?" → **Turnover analysis**
5. "Did we give up big plays?" → **Explosive plays allowed**

---

## Next Steps

1. **Review with coaches:** Which insights are most valuable?
2. **Prioritize enhancements:** Start with highest-value additions
3. **Implement incrementally:** Test one section at a time
4. **Iterate based on feedback:** Refine the language and metrics
5. **Consider visualization:** Could add small indicator charts for key metrics

---

## Technical Notes

- **Data availability:** All raw play-by-play data is accessible via `current_game_data`
- **Performance:** Additional calculations are minimal and won't slow report generation
- **Modularity:** Each function is independent - can enhance one without affecting others
- **Fallbacks:** Include defensive checks for missing data (games without turnovers, etc.)
- **Formatting:** Use markdown (**, ##) for better readability in HTML output
