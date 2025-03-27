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
    downloadButton(ns("report"), "Build Report", style = "margin-top:20px")
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
        paste0("soil_reports_", Sys.Date(), ".zip")
      },
      content = function(file) {
        shinybusy::show_modal_spinner(text = "Building reports...")

        formats <- input$format
        producers <- input$producer_id
        year <- input$year
        project_info <- state$project_info()
        language <- state$language()

        # Step 1: Set up paths
        original_template <- file.path("quarto", "template.qmd")
        if (!file.exists(original_template)) stop("Template file not found!")

        temp_dir <- tempfile("report_build_")
        dir.create(temp_dir)

        # Define temp directory
        temp_dir <- tempdir()

        # Copy template into temp dir
        template_copy <- file.path(temp_dir, "template.qmd")
        file.copy(original_template, template_copy)

        section_template_copy <- file.path(temp_dir, "section_template.qmd")
        file.copy("quarto/section_template.qmd", section_template_copy)


        # Create 'styles' subdirectory in the temp directory
        styles_dir <- file.path(temp_dir, "styles")
        dir.create(styles_dir, recursive = TRUE, showWarnings = FALSE)

        # Copy stylings into the styles subdirectory
        file.copy(
          "quarto/styles/styles.css",
          file.path(styles_dir, "styles.css")
        )
        file.copy(
          "quarto/styles/word-template.docx",
          file.path(styles_dir, "word-template.docx")
        )

        # create fig-output subdirectory
        fig_output_dir <- file.path(temp_dir, "styles")
        dir.create(fig_output_dir, recursive = TRUE, showWarnings = FALSE)


        # Copy fonts from www/fonts dir and include in temp dir under www/fonts
        original_fonts_dir <- file.path("www", "fonts")
        fonts_copy_dir <- file.path(temp_dir, "www", "fonts")

        # Create the directory if it doesn't exist
        dir.create(fonts_copy_dir, recursive = TRUE, showWarnings = FALSE)

        # Copy each font file
        file.copy(
          from = list.files(
            original_fonts_dir,
            full.names = TRUE,
            recursive = TRUE
          ),
          to = fonts_copy_dir,
          recursive = TRUE
        )


        # copy language folder and all of its contents
        original_lang_dir <- file.path("quarto", language)
        lang_dir_copy <- file.path(temp_dir, language)
        dir.create(lang_dir_copy, recursive = TRUE, showWarnings = FALSE)
        file.copy(
          from = list.files(
            original_lang_dir,
            full.names = TRUE,
            recursive = TRUE
          ),
          to = lang_dir_copy,
          recursive = TRUE
        )


        # copy images folder and all of its contents
        original_images_dir <- file.path("quarto", "images")
        image_dir_copy <- file.path(temp_dir, "images")
        dir.create(image_dir_copy, recursive = TRUE, showWarnings = FALSE)
        file.copy(
          from = list.files(
            original_images_dir,
            full.names = TRUE,
            recursive = TRUE
          ),
          to = image_dir_copy,
          recursive = TRUE
        )

        # create workbook with uploaded data & data dictionary, save to temp dir
        write_xlsx(
          list(
            "Data" = state$data,
            "Data Dictionary" = state$data_dictionary
          ),
          path = paste0(temp_dir, "/data.xlsx")
        )

        render_df <- expand.grid(
          producer_id = producers,
          fmt = formats,
          stringsAsFactors = FALSE
        ) |>
          mutate(
            output_file = paste0(year, "_", producer_id, ".", fmt)
          )

        withProgress(message = "Rendering reports", value = 0, {
          withr::with_dir(temp_dir, {
            for (i in seq_len(nrow(render_df))) {
              row <- render_df[i, ]
              incProgress(1 / nrow(render_df), detail = row$output_file)

              # quarto report parameters
              params <- list(
                data_file = "data.xlsx",
                year = input$year,
                producer_id = row$producer_id,
                language = state$language(),
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
                  warning(glue::glue(
                    "Failed to render {row$output_file}: {e$message}"
                  ))
                }
              )
            }
          })
        })

        # Step 4: Copy all output files from temp dir and zip them
        report_files <- list.files(
          temp_dir,
          pattern = "\\.(html|docx)$",
          full.names = TRUE
        )
        zip::zip(zipfile = file, files = report_files, mode = "cherry-pick")

        shinybusy::remove_modal_spinner()
      }
    )
  })
}
