# ====================================================================
# SHINY APP - POST-GAME REPORT GENERATOR
# ====================================================================
# Simple web interface for generating post-game reports
# Usage: Run shiny::runApp("app.R") or click "Run App" in RStudio
# ====================================================================

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)
library(dplyr)

# Source helper files
source("generate_report.R")
source("data_loader.R")

# ====================================================================
# UI DEFINITION
# ====================================================================

ui <- fluidPage(
  theme = shinytheme("flatly"),

  # Custom CSS
  tags$head(
    tags$style(HTML("
      .main-header {
        background-color: #003015;
        color: #FFB81C;
        padding: 20px;
        margin-bottom: 30px;
        border-radius: 5px;
      }
      .status-box {
        padding: 15px;
        margin: 10px 0;
        border-radius: 5px;
        border-left: 4px solid #003015;
        background-color: #f8f9fa;
      }
      .success-box {
        border-left-color: #28a745;
        background-color: #d4edda;
      }
      .warning-box {
        border-left-color: #ffc107;
        background-color: #fff3cd;
      }
      .error-box {
        border-left-color: #dc3545;
        background-color: #f8d7da;
      }
      .btn-generate {
        background-color: #003015;
        color: #FFB81C;
        font-weight: bold;
        font-size: 16px;
        padding: 10px 30px;
      }
      .btn-generate:hover {
        background-color: #FFB81C;
        color: #003015;
      }
      .cache-info {
        font-size: 12px;
        color: #6c757d;
      }
    "))
  ),

  # Header
  div(class = "main-header",
    h1("🏈 Baylor Football Analytics", style = "margin: 0;"),
    h4("Post-Game Report Generator", style = "margin: 5px 0 0 0; color: #FFB81C;")
  ),

  # Main content
  sidebarLayout(

    # Sidebar for inputs
    sidebarPanel(
      width = 4,

      h3("Report Configuration"),
      hr(),

      # Week number
      numericInput(
        "week_number",
        "Week Number:",
        value = 1,
        min = 1,
        max = 20,
        step = 1
      ),

      # Current opponent
      selectInput(
        "opponent",
        "Current Opponent:",
        choices = NULL,  # Will be populated by server
        selected = NULL
      ),

      # Next opponent
      selectInput(
        "next_opponent",
        "Next Week's Opponent:",
        choices = NULL,  # Will be populated by server
        selected = NULL
      ),

      hr(),

      # Advanced options (collapsible)
      checkboxInput(
        "force_reload",
        "Force reload data from API (slower)",
        value = FALSE
      ),

      helpText(
        class = "cache-info",
        "Unchecked: Uses cached data (faster, up to 24hrs old)",
        br(),
        "Checked: Reloads fresh data from API (slower, most current)"
      ),

      hr(),

      # Generate button
      actionButton(
        "generate_btn",
        "Generate Report",
        icon = icon("file-alt"),
        class = "btn-generate btn-block",
        style = "margin-top: 20px;"
      ),

      # Cache management
      hr(),
      h4("Data Cache"),
      actionButton(
        "refresh_cache_status",
        "Refresh Cache Info",
        icon = icon("sync"),
        class = "btn-info btn-sm"
      ),
      actionButton(
        "clear_cache_btn",
        "Clear Cache",
        icon = icon("trash"),
        class = "btn-warning btn-sm"
      )
    ),

    # Main panel for output
    mainPanel(
      width = 8,

      # Status messages
      uiOutput("status_box"),

      # Progress indicator
      conditionalPanel(
        condition = "($('html').hasClass('shiny-busy'))",
        div(
          class = "status-box warning-box",
          h4(icon("spinner", class = "fa-spin"), " Processing..."),
          p("Generating your report. This may take 5-60 seconds depending on cache status.")
        )
      ),

      # Download button (shown after success)
      uiOutput("download_ui"),

      # Tabs for additional info
      tabsetPanel(
        type = "tabs",

        # Schedule tab (NEW!)
        tabPanel(
          "Schedule",
          br(),
          h4("Baylor 2025 Schedule"),
          p("Click on a game to auto-fill the report configuration."),
          DTOutput("schedule_table"),
          br(),
          helpText(
            class = "cache-info",
            icon("info-circle"), " Click on any row to automatically fill in the week number and opponents."
          )
        ),

        # Cache info tab
        tabPanel(
          "Cache Status",
          br(),
          h4("Data Cache Information"),
          p("The cache stores downloaded data to speed up report generation."),
          DTOutput("cache_status_table"),
          br(),
          verbatimTextOutput("cache_details")
        ),

        # Recent reports tab
        tabPanel(
          "Recent Reports",
          br(),
          h4("Generated Reports"),
          p("Reports are saved in the 'reports/' directory."),
          DTOutput("recent_reports_table"),
          br(),
          uiOutput("report_actions")
        ),

        # Help tab
        tabPanel(
          "Help",
          br(),
          h4("How to Use"),
          tags$ol(
            tags$li(
              strong("Easy Way - Use the Schedule:"),
              " Go to the 'Schedule' tab and click on any game to auto-fill all fields!"
            ),
            tags$li(
              strong("Manual Way - Select Manually:"),
              " Choose week number, current opponent, and next opponent from the dropdowns."
            ),
            tags$li(
              strong("Click 'Generate Report':"),
              " The app will create an HTML report."
            ),
            tags$li(
              strong("Download:"),
              " Once complete, click the download button to get your HTML report. You can open it in any web browser or save as PDF using your browser's print function."
            )
          ),

          hr(),
          h4("Tips"),
          tags$ul(
            tags$li(
              strong("Quick Start:"),
              " The 'Schedule' tab shows Baylor's full 2025 schedule. Click any game to auto-fill the form - it's the fastest way!"
            ),
            tags$li(
              strong("First Run:"),
              " The first report generation will take 30-60 seconds as it downloads data from the API."
            ),
            tags$li(
              strong("Subsequent Runs:"),
              " After the first run, reports generate in 5-10 seconds using cached data."
            ),
            tags$li(
              strong("Force Reload:"),
              " Check this box to get the most current data, but it will be slower."
            ),
            tags$li(
              strong("Cache:"),
              " Data is cached for 24 hours. Clear the cache if you need fresh data."
            )
          ),

          hr(),
          h4("Troubleshooting"),
          tags$ul(
            tags$li(
              strong("Report generation failed:"),
              " Check that the opponent names match teams in cfbfastR database."
            ),
            tags$li(
              strong("Slow generation:"),
              " First run is slow. Use cached data for faster subsequent runs."
            ),
            tags$li(
              strong("Missing teams:"),
              " If a team doesn't appear in the dropdown, refresh the page."
            )
          )
        ),

        # About tab
        tabPanel(
          "About",
          br(),
          h4("Baylor Football Analytics System"),
          p("Version 2.0 - Enhanced Edition"),
          hr(),
          h5("Features:"),
          tags$ul(
            tags$li("Automated HTML report generation (easily convertible to PDF)"),
            tags$li("EPA (Expected Points Added) analysis"),
            tags$li("Win probability tracking"),
            tags$li("Player-level statistics"),
            tags$li("Situational analytics (red zone, 3rd down, etc.)"),
            tags$li("Opponent tendency analysis"),
            tags$li("Game planning insights"),
            tags$li("Intelligent data caching")
          ),
          hr(),
          p(
            strong("Data Source:"), " cfbfastR",
            br(),
            strong("Analytics:"), " Applied Performance Football Analytics",
            br(),
            strong("Enhanced by:"), " Claude Code Optimization 2025"
          )
        )
      )
    )
  ),

  # Footer
  hr(),
  div(
    style = "text-align: center; color: #6c757d; padding: 20px;",
    p("Baylor Football Analytics | Post-Game Report Generator"),
    p(style = "font-size: 12px;",
      "For issues or questions, check the Help tab or review the documentation.")
  )
)

# ====================================================================
# SERVER LOGIC
# ====================================================================

server <- function(input, output, session) {

  # Reactive values for state management
  state <- reactiveValues(
    teams = NULL,
    schedule = NULL,
    report_path = NULL,
    status_message = NULL,
    status_type = "info"
  )

  # ====================================================================
  # INITIALIZATION
  # ====================================================================

  # Load team list on startup
  observe({
    tryCatch({
      # Load team info
      team_info <- load_team_info_cached()

      # Get unique team names, sorted
      teams <- sort(unique(team_info$school))

      # Update dropdowns
      updateSelectInput(session, "opponent", choices = teams, selected = "SMU")
      updateSelectInput(session, "next_opponent", choices = teams, selected = "Samford")

      state$teams <- teams

      showNotification("Teams loaded successfully!", type = "message")

    }, error = function(e) {
      showNotification(
        paste("Error loading teams:", e$message),
        type = "error",
        duration = 10
      )
    })
  })

  # Load Baylor schedule on startup
  observe({
    tryCatch({
      # Load schedule
      schedule <- load_team_schedule_cached(season = 2025, team = "Baylor")

      if (!is.null(schedule) && nrow(schedule) > 0) {
        state$schedule <- schedule
        showNotification("Schedule loaded successfully!", type = "message")
      } else {
        showNotification("No schedule data available", type = "warning")
      }

    }, error = function(e) {
      showNotification(
        paste("Error loading schedule:", e$message),
        type = "error",
        duration = 10
      )
    })
  })

  # ====================================================================
  # SCHEDULE DISPLAY
  # ====================================================================

  # Render schedule table
  output$schedule_table <- renderDT({

    if (is.null(state$schedule) || nrow(state$schedule) == 0) {
      return(data.frame(
        Message = "No schedule data available. Check API connection and try refreshing."
      ))
    }

    # Format schedule for display
    display_schedule <- state$schedule %>%
      dplyr::mutate(
        game_date = format(as.POSIXct(game_date), "%b %d, %Y"),
        status = ifelse(completed, "Completed", "Upcoming")
      ) %>%
      dplyr::select(
        Week = week,
        Date = game_date,
        Opponent = opponent,
        Location = location,
        `Next Opp` = next_opponent,
        Status = status
      )

    # Create interactive datatable
    datatable(
      display_schedule,
      selection = 'single',
      options = list(
        pageLength = 15,
        dom = 't',
        ordering = FALSE
      ),
      rownames = FALSE,
      class = 'cell-border stripe hover'
    )
  })

  # Handle schedule row click - auto-fill form
  observeEvent(input$schedule_table_rows_selected, {

    if (is.null(state$schedule) || length(input$schedule_table_rows_selected) == 0) {
      return()
    }

    # Get selected row
    selected_row <- input$schedule_table_rows_selected
    game <- state$schedule[selected_row, ]

    # Update form fields
    updateNumericInput(session, "week_number", value = game$week)
    updateSelectInput(session, "opponent", selected = game$opponent)

    # Update next opponent if available
    if (!is.na(game$next_opponent)) {
      updateSelectInput(session, "next_opponent", selected = game$next_opponent)
    }

    # Show notification
    showNotification(
      paste0("Auto-filled: Week ", game$week, " - ", game$opponent),
      type = "message",
      duration = 3
    )
  })

  # ====================================================================
  # REPORT GENERATION
  # ====================================================================

  # Generate report when button clicked
  observeEvent(input$generate_btn, {

    # Validate inputs
    if (is.null(input$opponent) || input$opponent == "") {
      showNotification("Please select a current opponent", type = "error")
      return()
    }

    if (is.null(input$next_opponent) || input$next_opponent == "") {
      showNotification("Please select a next opponent", type = "error")
      return()
    }

    if (input$opponent == input$next_opponent) {
      showNotification("Current and next opponent cannot be the same", type = "warning")
      return()
    }

    # Clear previous status
    state$status_message <- NULL
    state$report_path <- NULL

    # Show progress
    showNotification("Starting report generation...", type = "message")

    # Generate report (wrapped in tryCatch for error handling)
    tryCatch({

      # Create output directory if needed
      if (!dir.exists("./reports")) {
        dir.create("./reports", recursive = TRUE)
      }

      # Generate report
      report_path <- generate_weekly_report(
        week = input$week_number,
        opponent = input$opponent,
        next_opponent = input$next_opponent,
        output_dir = "./reports",
        force_reload = input$force_reload
      )

      # Store report path
      state$report_path <- report_path

      # Update status
      state$status_message <- paste0(
        "Report generated successfully! ",
        "Week ", input$week_number, " - ",
        input$opponent, " vs Next: ", input$next_opponent
      )
      state$status_type <- "success"

      # Show notification
      showNotification(
        "Report generated successfully! Click 'Download Report' to get your HTML report.",
        type = "message",
        duration = 10
      )

    }, error = function(e) {

      state$status_message <- paste("Error generating report:", e$message)
      state$status_type <- "error"

      showNotification(
        paste("Report generation failed:", e$message),
        type = "error",
        duration = 15
      )
    })
  })

  # ====================================================================
  # STATUS DISPLAY
  # ====================================================================

  output$status_box <- renderUI({

    if (is.null(state$status_message)) {
      return(
        div(
          class = "status-box",
          h4(icon("info-circle"), " Ready to Generate"),
          p("Select your game details and click 'Generate Report' to begin.")
        )
      )
    }

    box_class <- switch(
      state$status_type,
      "success" = "status-box success-box",
      "error" = "status-box error-box",
      "warning" = "status-box warning-box",
      "status-box"
    )

    icon_name <- switch(
      state$status_type,
      "success" = "check-circle",
      "error" = "exclamation-circle",
      "warning" = "exclamation-triangle",
      "info-circle"
    )

    div(
      class = box_class,
      h4(icon(icon_name), " ", state$status_type),
      p(state$status_message)
    )
  })

  # ====================================================================
  # DOWNLOAD BUTTON
  # ====================================================================

  output$download_ui <- renderUI({

    if (is.null(state$report_path) || !file.exists(state$report_path)) {
      return(NULL)
    }

    div(
      style = "margin: 20px 0;",
      downloadButton(
        "download_report",
        "Download Report (HTML)",
        icon = icon("download"),
        class = "btn-success btn-lg btn-block"
      ),
      p(
        style = "margin-top: 10px; color: #6c757d;",
        "File: ", basename(state$report_path)
      )
    )
  })

  # Download handler
  output$download_report <- downloadHandler(
    filename = function() {
      basename(state$report_path)
    },
    content = function(file) {
      file.copy(state$report_path, file)
    }
  )

  # ====================================================================
  # CACHE MANAGEMENT
  # ====================================================================

  # Cache status table
  output$cache_status_table <- renderDT({

    # Trigger refresh
    input$refresh_cache_status

    tryCatch({
      cache_status <- get_cache_status()

      if (nrow(cache_status) == 0) {
        return(data.frame(
          Message = "No cache files found. Generate a report to create cache."
        ))
      }

      datatable(
        cache_status,
        options = list(pageLength = 5, dom = 't'),
        rownames = FALSE
      )

    }, error = function(e) {
      data.frame(Error = paste("Could not load cache status:", e$message))
    })
  })

  # Cache details
  output$cache_details <- renderText({

    # Trigger refresh
    input$refresh_cache_status

    tryCatch({
      cache_status <- get_cache_status()

      if (nrow(cache_status) == 0) {
        return("No cache files present.")
      }

      total_size <- sum(cache_status$size_mb, na.rm = TRUE)
      oldest <- min(cache_status$modified, na.rm = TRUE)

      paste0(
        "Total cache size: ", round(total_size, 2), " MB\n",
        "Oldest file: ", format(oldest, "%Y-%m-%d %H:%M:%S"), "\n",
        "Cache directory: ./cache/"
      )

    }, error = function(e) {
      paste("Error:", e$message)
    })
  })

  # Clear cache button
  observeEvent(input$clear_cache_btn, {

    tryCatch({
      clear_cache()

      showNotification(
        "Cache cleared successfully. Next report will reload data from API.",
        type = "message",
        duration = 5
      )

    }, error = function(e) {
      showNotification(
        paste("Error clearing cache:", e$message),
        type = "error",
        duration = 10
      )
    })
  })

  # ====================================================================
  # RECENT REPORTS
  # ====================================================================

  output$recent_reports_table <- renderDT({

    # Trigger refresh when new report generated
    state$report_path

    tryCatch({

      if (!dir.exists("./reports")) {
        return(data.frame(
          Message = "No reports directory found."
        ))
      }

      # Get list of HTML files
      reports <- list.files("./reports", pattern = "\\.html$", full.names = TRUE)

      if (length(reports) == 0) {
        return(data.frame(
          Message = "No reports generated yet."
        ))
      }

      # Get file info
      report_info <- data.frame(
        Filename = basename(reports),
        Size_MB = round(file.size(reports) / 1024^2, 2),
        Created = format(file.info(reports)$mtime, "%Y-%m-%d %H:%M:%S"),
        Path = reports,
        stringsAsFactors = FALSE
      )

      # Sort by creation time (newest first)
      report_info <- report_info[order(report_info$Created, decreasing = TRUE), ]

      # Display table (hide path column)
      datatable(
        report_info[, c("Filename", "Size_MB", "Created")],
        options = list(pageLength = 10),
        rownames = FALSE
      )

    }, error = function(e) {
      data.frame(Error = paste("Could not load reports:", e$message))
    })
  })

}

# ====================================================================
# RUN APP
# ====================================================================

shinyApp(ui = ui, server = server)
