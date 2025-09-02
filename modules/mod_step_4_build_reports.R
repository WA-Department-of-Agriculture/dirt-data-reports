mod_step_4_build_reports_ui <- function(id, state) {
  ns <- NS(id)

  tagList(
    useShinyjs(),
    tags$style(HTML(
      "
  .progress-section {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    margin-top: 1rem;
    text-align: left;
  }

  .progress-wrapper {
    background: #eee;
    border-radius: 8px;
    overflow: hidden;
    height: 26px;
    position: relative;
  }

  .progress-bar {
    height: 100%;
    background-color: #10b981;
    width: 0%;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding-right: 10px;
    color: white;
    font-weight: 600;
    font-size: 0.9rem;
    transition: width 0.3s ease;
  }

  .progress-title {
    font-size: 12px;
    color: #333;
    font-weight: 500;
  }

  .message {
    display: none;
    margin-top: 2rem;
    text-align: center;
    animation: fadeIn 0.3s ease-in-out;
  }

  .message i {
    font-size: 45px;
    margin-bottom: 0.75rem;
  }

  .message h3 {
    margin: 0.5rem 0 0.25rem;
    color: #222;
  }

  .message p {
    color: #555;
    margin-bottom: 0.5rem;
  }

  #errorMessage i {
    color: #e74c3c;
  }

  #errorList {
    text-align: center;
    font-size:14px;
    list-style-type: none;
    margin: 20px 0px;
    max-height: 150px;
    overflow-y: auto;
    width: 100%;
    color: #c0392b;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(5px); }
    to { opacity: 1; transform: translateY(0); }
  }
"
    )),
    tags$script(HTML(
      "
  Shiny.addCustomMessageHandler('updateProgressModal', function(data) {
    document.getElementById('progressTitle').textContent = data.step;
    document.getElementById('progressBar').style.width = data.percent + '%';
    document.getElementById('progressBar').textContent = data.percent + '%';
  });

  Shiny.addCustomMessageHandler('showSuccessModal', function(message) {
    document.querySelector('.progress-section').style.display = 'none';
    document.getElementById('successText').textContent = message;
    document.getElementById('successMessage').style.display = 'block';
    document.getElementById('dynamicCloseBtn').style.display = 'inline-block';
    document.getElementById('dynamicCloseBtn').onclick = function() {
      $('#shiny-modal').modal('hide');
    };
  });

  Shiny.addCustomMessageHandler('showErrorModal', function(data) {
    document.querySelector('.progress-section').style.display = 'none';
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.style.display = 'block';
    document.getElementById('errorText').textContent = data.message;

    const list = document.getElementById('errorList');
    list.innerHTML = '';
    data.files.forEach(function(file) {
      const li = document.createElement('li');
      li.textContent = file;
      list.appendChild(li);
    });

  document.getElementById('errorCloseBtn').style.display = 'inline-block';
  document.getElementById('reportIssueBtn').style.display = 'inline-block';

  document.getElementById('errorCloseBtn').onclick = function() {
    $('#shiny-modal').modal('hide');
  };
  });
"
    )),
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
  )
}

mod_step_4_build_reports_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      print(glue::glue(
        "User time zone: {getDefaultReactiveDomain()$input$user_timezone}"
      ))
    })

    output$year_input <- renderUI({
      req(state$years)
      selectInput(
        inputId = ns("year"),
        label = "Year",
        choices = state$years,
        selected = isolate(state$step_4_vals$year) %||% state$years[1]
      )
    })

    output$producer_input <- renderUI({
      req(input$year)
      req(state$producer_ids)
      available_ids <- state$producer_ids |>
        filter(year == input$year) |>
        arrange(producer_id) |>
        pull(producer_id)
      shinyWidgets::pickerInput(
        inputId = ns("producer_id"),
        label = "Select Producers (5 max)",
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

    observe({
      if (
        is.null(input$producer_id) ||
          length(input$producer_id) == 0 ||
          is.null(input$format) ||
          length(input$format) == 0
      ) {
        shinyjs::disable("report")
      } else {
        shinyjs::enable("report")
      }
    })

    observeEvent(input$year, {
      state$step_4_vals$year <- input$year
    })
    observeEvent(input$producer_id, {
      state$step_4_vals$producer_id <- input$producer_id
    })
    observeEvent(input$format, {
      state$step_4_vals$format <- input$format
    })

    output$report <- downloadHandler(
      filename = function() {
        local_time <- if (is.null(state$user_timezone)) {
          format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
        } else {
          format(with_tz(Sys.time(), state$user_timezone), "%Y-%m-%d_%H-%M-%S")
        }
        paste0("soil_reports_", local_time, ".zip")
      },
      content = function(file) {
        # Show modal with no close option initially
        showModal(modalDialog(
          title = NULL,
          size = "m",
          easyClose = FALSE,
          footer = NULL,
          tags$div(
            id = "modalContent",
            tags$div(
              class = "progress-section",
              h3(style = "text-align:center", "Building Reports"),
              # spinner modal
              div(
                style = "width:100%;display:flex;justify-content:center",
                htmltools::HTML(
                  '<div class="flower-spinner">
                        <div class="dots-container">
                          <div class="bigger-dot">
                            <div class="smaller-dot"></div>
                          </div>
                        </div>
                      </div>'
                )
              ),
              div(
                class = "alert alert-warning d-flex align-items-center",
                style = "margin:20px 0px",
                role = "alert",
                shiny::icon("triangle-exclamation", class = "me-2"),
                tags$span(
                  "Note: Depending on the number of reports, this process may take several minutes. Please do not exit the session before the reports are downloaded."
                )
              ),
              tags$div(
                id = "progressTitle",
                class = "progress-title",
                "Starting..."
              ),
              tags$div(
                class = "progress-wrapper",
                tags$div(id = "progressBar", class = "progress-bar", "0%")
              )
            ),
            tags$div(
              id = "successMessage",
              class = "message",
              tags$i(class = "fas fa-check-circle", style = "color:#023B2C"),
              tags$h3("Success!"),
              tags$p(id = "successText", ""),
              tags$button(
                "Close",
                id = "dynamicCloseBtn",
                class = "btn btn-secondary",
                style = "margin-top: 1rem; display: none;"
              )
            ),
            tags$div(
              id = "errorMessage",
              class = "message",
              style = "display:none;",
              tags$i(
                class = "fas fa-exclamation-triangle",
                style = "color:#e74c3c;"
              ),
              tags$h3("Some reports failed."),
              tags$p(id = "errorText", ""),
              tags$ul(
                id = "errorList",
                style = "text-align:left; max-height:150px; overflow-y:auto; padding-left: 1.2rem;"
              ),
              div(
                style = "display:flex;justify-content:space-between;margin-top:10px",
                tags$button(
                  "Report Issue",
                  id = "reportIssueBtn",
                  class = "btn btn-danger",
                  style = "margin-top: 1rem; display: none;width:100px;",
                  onclick = "window.open('https://survey123.arcgis.com/share/abf65232818d4be0aec31e030992e217')"
                ),
                tags$button(
                  "Close",
                  id = "errorCloseBtn",
                  class = "btn btn-secondary",
                  style = "margin-top: 1rem; display: none; margin-right: 1rem;width:100px"
                )
              )
            )
          )
        ))

        runjs(
          "
      document.getElementById('progressBar').style.width = '0%';
      document.getElementById('progressBar').textContent = '0%';
      document.getElementById('progressTitle').textContent = 'Generating Report 0 of 0';
      document.getElementById('successMessage').style.display = 'none';
      document.getElementById('dynamicCloseBtn').style.display = 'none';
    "
        )

        formats <- input$format
        producers <- input$producer_id
        year <- input$year
        project_info <- state$project_info()
        language <- state$language()

        temp_dir <- tempfile("report_build_")
        dir.create(temp_dir, recursive = TRUE)
        on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

        render_df <- expand.grid(
          producer_id = producers,
          fmt = formats,
          stringsAsFactors = FALSE
        ) |>
          mutate(output_file = paste0(year, "_", producer_id, ".", fmt))

        total_steps <- nrow(render_df) + 2
        failed_reports <- character(0)

        session$sendCustomMessage(
          "updateProgressModal",
          list(step = "Copying Files", percent = 5)
        )

        file.copy("quarto/template.qmd", file.path(temp_dir, "template.qmd"))
        file.copy(
          "quarto/section_template.qmd",
          file.path(temp_dir, "section_template.qmd")
        )

        styles_dir <- file.path(temp_dir, "styles")
        dir.create(styles_dir, showWarnings = FALSE)
        file.copy("quarto/styles/styles.css", styles_dir)
        file.copy("quarto/styles/word-template.docx", styles_dir)

        lang_src <- file.path("quarto", language)
        lang_dest <- file.path(temp_dir, language)
        dir.create(lang_dest, showWarnings = FALSE)
        file.copy(
          list.files(lang_src, full.names = TRUE, recursive = TRUE),
          to = lang_dest,
          recursive = TRUE
        )

        img_src <- file.path("quarto", "images")
        img_dest <- file.path(temp_dir, "images")
        dir.create(img_dest, showWarnings = FALSE)
        file.copy(
          list.files(img_src, full.names = TRUE, recursive = TRUE),
          to = img_dest,
          recursive = TRUE
        )

        fonts_src <- "www/fonts"
        fonts_dest <- file.path(temp_dir, "www", "fonts")
        dir.create(fonts_dest, recursive = TRUE, showWarnings = FALSE)
        file.copy("www/fonts/Arial.ttf", fonts_dest)
        file.copy("www/fonts/Arial-Bold.ttf", fonts_dest)
        file.copy("www/fonts/Arial-Italic.ttf", fonts_dest)
        file.copy("www/fonts/Arial-Bold-Italic.ttf", fonts_dest)

        writexl::write_xlsx(
          list(
            "Data" = state$data,
            "Data Dictionary" = state$data_dictionary
          ),
          path = file.path(temp_dir, "data.xlsx")
        )

        Sys.sleep(5)

        withr::with_dir(temp_dir, {
          for (i in seq_len(nrow(render_df))) {
            row <- render_df[i, ]
            progress_step <- glue::glue(
              "Generating Report {i}/{nrow(render_df)}: {row$output_file}"
            )
            percent_complete <- floor((i + 1) / total_steps * 100)

            session$sendCustomMessage(
              "updateProgressModal",
              list(
                step = progress_step,
                percent = percent_complete
              )
            )

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
                warning(glue::glue(
                  "Failed to render {row$output_file}: {e$message}"
                ))
                failed_reports <<- c(failed_reports, row$output_file)
              }
            )
          }
        })

        session$sendCustomMessage(
          "updateProgressModal",
          list(step = "Zipping Files", percent = 100)
        )
        # Sys.sleep(1)  # give it a moment to render
        report_files <- list.files(
          temp_dir,
          pattern = "\\.(html|docx)$",
          full.names = TRUE
        )
        zip::zip(zipfile = file, files = report_files, mode = "cherry-pick")

        if (length(failed_reports) == 0) {
          success_msg <- glue::glue(
            "All {nrow(render_df)} reports generated successfully. Please check your Downloads folder."
          )
          session$sendCustomMessage("showSuccessModal", success_msg)
        } else {
          fail_msg <- glue::glue(
            "Successfully generated {nrow(render_df) - length(failed_reports)} of {nrow(render_df)} reports. Files with errors are listed below. Please try again or report an issue."
          )
          session$sendCustomMessage(
            "showErrorModal",
            list(
              message = fail_msg,
              files = failed_reports
            )
          )
        }
      }
    )

    observeEvent(input$close_modal, {
      removeModal()
    })
  })
}
