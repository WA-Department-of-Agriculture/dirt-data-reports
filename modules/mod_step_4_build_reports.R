mod_step_4_build_reports_ui <- function(id, state) {
  ns <- NS(id)

  div(
    class = "form-content",
    h4(class = "form-step", "Step 4"),
    h2(class = "form-title", "Build Reports"),
    p(
      class = "form-text",
      "Choose the year and up to five producers to build reports for. Producer IDs listed will automatically update based on the year selected. Reports will be generated in a zip file within your Downloads folder."
    ),
    div(
      class = "col-2",
      # Render year and producer inputs dynamically
      uiOutput(ns("year_input")),
      uiOutput(ns("producer_input"))
    ),
    shinyWidgets::checkboxGroupButtons(
      inputId = ns("format"),
      label = "Select Report Formats",
      choices = c(
        "<div style='text-align:center;'><i class='fas fa-file-word fa-2x'></i><br><span>Word</span></div>" = "docx",
        "<div style='text-align:center;'><i class='fas fa-file-code fa-2x'></i><br><span>HTML</span></div>" = "html"
      ),
      selected = isolate(state$step_4_vals$format) %||% c("docx"),
      justified = TRUE
    ),
    downloadButton(ns("report"), "Build Reports", style = "margin-top:20px")
  )
}




mod_step_4_build_reports_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Render year input
    output$year_input <- renderUI({
      req(state$years)
      selectInput(
        inputId = ns("year"),
        label = "Year",
        choices = state$years,
        selected = isolate(state$step_4_vals$year) %||% state$years[1]
      )
    })

    # Render producer input
    output$producer_input <- renderUI({
      req(input$year)
      req(state$producer_ids)

      available_ids <- state$producer_ids |>
        filter(year == input$year) |>
        arrange(producer_id) |>
        pull(producer_id)

      shinyWidgets::pickerInput(
        inputId = ns("producer_id"),
        label = "Producer IDs",
        choices = available_ids,
        selected = isolate(state$step_4_vals$producer_id) %||% NULL,
        multiple = TRUE,
        options = shinyWidgets::pickerOptions(
          title = "Select producers",
          actionsBox = TRUE,
          liveSearch = TRUE,
          maxOptions = 5,
          maxOptionsText = "Maximum of 5"
        )
      )
    })
    
    #disable build report button if no producers selected
    observe({
      if (is.null(input$producer_id) || length(input$producer_id) == 0) {
        shinyjs::disable("report")
      } else {
        shinyjs::enable("report")
      }
    })

    # Store inputs in state
    observeEvent(input$year, {
      state$step_4_vals$year <- input$year
    })
    observeEvent(input$producer_id, {
      state$step_4_vals$producer_id <- input$producer_id
    })
    observeEvent(input$format, {
      state$step_4_vals$format <- input$format
    })

    # Download handler
    output$report <- downloadHandler(
      filename = function() {
        paste0("soil_reports_", format(Sys.time(), "%Y-%m-%d_%H-%M"), ".zip")
      },
      content = function(file) {
        shinybusy::show_modal_spinner(
          spin = "flower",
          color = "#023B2C",
          text = "Building Reports..."
        )
        
        formats <- input$format
        producers <- input$producer_id
        year <- input$year
        project_info <- state$project_info()
        language <- state$language()
        
        # Step 1: Create unique temp directory
        temp_dir <- tempfile("report_build_")
        dir.create(temp_dir, recursive = TRUE)
        on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)
        
        # Step 2: Build render_df
        render_df <- expand.grid(
          producer_id = producers,
          fmt = formats,
          stringsAsFactors = FALSE
        ) |>
          dplyr::mutate(
            output_file = paste0(year, "_", producer_id, ".", fmt)
          )
        
        total_steps <- nrow(render_df) + 2
        failed_reports <- character(0)      
        
        withProgress(message = "Building reports", value = 0, {
          
          # ✅ Step 1: Copy templates, styles, and inputs
          incProgress(1 / total_steps, detail = "Preparing files...")
          
          # Copy templates
          file.copy("quarto/template.qmd", file.path(temp_dir, "template.qmd"))
          file.copy("quarto/section_template.qmd", file.path(temp_dir, "section_template.qmd"))
          
          # Copy styles
          styles_dir <- file.path(temp_dir, "styles")
          dir.create(styles_dir, showWarnings = FALSE)
          file.copy("quarto/styles/styles.css", styles_dir)
          file.copy("quarto/styles/word-template.docx", styles_dir)
          
          # Copy language folder
          lang_src <- file.path("quarto", language)
          lang_dest <- file.path(temp_dir, language)
          dir.create(lang_dest, showWarnings = FALSE)
          file.copy(list.files(lang_src, full.names = TRUE, recursive = TRUE), to = lang_dest, recursive = TRUE)
          
          # Copy images
          img_src <- file.path("quarto", "images")
          img_dest <- file.path(temp_dir, "images")
          dir.create(img_dest, showWarnings = FALSE)
          file.copy(list.files(img_src, full.names = TRUE, recursive = TRUE), to = img_dest, recursive = TRUE)
          
          # Write uploaded data
          writexl::write_xlsx(
            list(
              "Data" = state$data,
              "Data Dictionary" = state$data_dictionary
            ),
            path = file.path(temp_dir, "data.xlsx")
          )
          
          # Step 2–n: Render reports
          withr::with_dir(temp_dir, {
            for (i in seq_len(nrow(render_df))) {
              row <- render_df[i, ]
              incProgress(1 / total_steps, detail = paste("Rendering", row$output_file))
              
              params <- list(
                data_file = "data.xlsx",
                year = year,
                producer_id = row$producer_id,
                language = language,
                project_name = project_info$project_name,
                project_results = project_info$project_results,
                project_summary = project_info$project_summary,
                looking_forward = project_info$looking_forward,
                measures = project_info$measurement_definitions
              )
              
              tryCatch(
                {
                  quarto::quarto_render(
                    input = "template.qmd",
                    output_format = row$fmt,
                    execute_params = params,
                    output_file = row$output_file
                  )
                },
                error = function(e) {
                  warning(glue::glue("Failed to render {row$output_file}: {e$message}"))
                  failed_reports <<- c(failed_reports, row$output_file)
                }
              )
            }
          })
          
          # Final Step: Zip Reports
          incProgress(1 / total_steps, detail = "Zipping reports...")
          
          report_files <- list.files(
            temp_dir,
            pattern = "\\.(html|docx)$",
            full.names = TRUE
          )
          
          zip::zip(zipfile = file, files = report_files, mode = "cherry-pick")
        })
        
        shinybusy::remove_modal_spinner()
        
        # Show final result
        if (length(failed_reports) > 0) {
          shinyalert::shinyalert(
            title = "Some Reports Failed to Generate",
            text = paste("The following reports failed:", paste(failed_reports, collapse = ", ")),
            type = "error",
            confirmButtonCol = "#335C67"
          )
        } else {
          shinyalert::shinyalert(
            title = "Reports Are Done Generating!",
            text = "Check your Downloads folder for the zipped reports.",
            confirmButtonCol = "#335C67",
            type = "success"
          )
        }
      }
    )
    
  })
}
