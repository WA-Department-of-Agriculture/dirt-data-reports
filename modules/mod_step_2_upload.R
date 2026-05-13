mod_step_2_upload_ui <- function(id, state) {
  ns <- NS(id)

  # Display message if file already uploaded
  uploaded_msg <- isolate({
    if (
      !is.null(state$step_2_vals) &&
        is.list(state$step_2_vals) &&
        !is.null(state$step_2_vals$file_name)
    ) {
      div(
        class = "alert alert-info",
        tags$strong("Previously uploaded file: "),
        state$step_2_vals$file_name
      )
    } else {
      NULL
    }
  })

  div(
    class = "form-content",
    h4(class = "form-step", "Step 2"),
    h2(class = "form-title", "Upload Data"),
    p(
      class = "form-text",
      "Upload your completed template to check for errors. If any issues are
      found, an error message will appear below. Please fix the errors in your
      file and upload it again."
    ),
    p(
      class = "form-text",
      "For your privacy, no data are stored or saved by this tool."
    ),
    actionLink(
      ns("requirement_info"),
      "Learn about the data validation checks.",
      icon = icon("circle-info")
    ),
    br(),
    uploaded_msg,
    fileInput(ns("upload_file"), "Upload Data (.xlsx)", accept = ".xlsx"),
    div(id = ns("error_message")),
    shinyjs::hidden(
      downloadButton(
        ns("download_errors"),
        "Download spreadsheet with issues",
        class = "btn-outline-danger"
      )
    )
  )
}

mod_step_2_upload_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Store values the download handler needs
    upload_path <- reactiveVal(NULL)
    upload_name <- reactiveVal(NULL)
    validation_result <- reactiveVal(NULL)

    observeEvent(input$requirement_info, {
      show_modal(
        title = "Data Check",
        id = "modal-validation",
        md = "about_validation"
      )
    })

    observeEvent(input$upload_file, {
      req_fields <- soils:::required_fields
      req_fields_data <- req_fields |> dplyr::filter(type == "Data")
      req_fields_dd <- req_fields |> dplyr::filter(type == "Data Dictionary")

      # Remove previous messages and hide download button
      removeUI(
        selector = paste0("#", ns("error_message"), " > *"),
        immediate = TRUE,
        multiple = TRUE
      )
      shinyjs::hide("download_errors")
      validation_result(NULL)

      # Get current language from state (default to english if not set)
      current_language <- "english"

      if (!is.null(state$step_1_vals) && !is.null(state$step_1_vals$language)) {
        current_language <- state$step_1_vals$language
      } else if (!is.null(state$language) && is.function(state$language)) {
        lang_val <- state$language()
        if (!is.null(lang_val)) current_language <- lang_val
      }

      file_path <- input$upload_file$datapath

      # --- Load data ---
      input_data <- soils::read_soils_input(file_path)

      if (isFALSE(input$passed)) {
        results <- soils::format_issues(input_data$issues, output = "ui") |>
          soils:::split_issues()

        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-danger",
            shiny::icon("circle-exclamation", style = "margin-right:2px"),
            tags$strong("Errors (must fix to continue):"),
            render_issue_list(results$errors)
          )
        )

        state$step_2_valid <- FALSE
        return()
      }

      # --- Gate check ---
      gate_result <- soils::check_input_structure(input_data)

      if (isFALSE(gate_result$passed)) {
        results <- soils::format_issues(gate_result$issues, output = "ui") |>
          soils:::split_issues()

        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-danger",
            shiny::icon("circle-exclamation", style = "margin-right:2px"),
            tags$strong("Errors (must fix to continue):"),
            render_issue_list(results$errors)
          )
        )

        state$step_2_valid <- FALSE
        return()
      }

      # --- Independent checks ---
      validation_result <- soils::run_all_checks(gate_result)

      results <- soils::format_issues(
        validation_result$issues,
        output = "ui"
      ) |>
        soils:::split_issues()

      if (length(validation_result$issues) == 0) {
        # All checks passed
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-success",
            shiny::icon("circle-check", style = "margin-right:2px"),
            "All checks passed!"
          )
        )
      } else {
        # Build cards
        cards <- list()

        if (length(results$errors) > 0) {
          cards <- c(
            cards,
            list(
              div(
                class = "alert alert-danger",
                shiny::icon("circle-exclamation", style = "margin-right:2px"),
                tags$strong("Errors (must fix to continue):"),
                render_issue_list(results$errors)
              )
            )
          )
        }

        if (length(results$warnings) > 0) {
          cards <- c(
            cards,
            list(
              div(
                class = "alert alert-warning",
                shiny::icon("triangle-exclamation", style = "margin-right:2px"),
                tags$strong("Warnings (review recommended):"),
                render_issue_list(results$warnings)
              )
            )
          )
        }

        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = tagList(cards)
        )

        # Show download button
        upload_path(file_path)
        upload_name(input$upload_file$name)
        validation_result(validation_result)
        shinyjs::show("download_errors")
      }

      # --- Update state ---

      if (isFALSE(validation_result$passed)) {
        # Errors present — block progression
        state$step_2_valid <- FALSE
      } else {
        # No errors (passed or warnings only) — allow progression
        state$step_2_valid <- TRUE
        state$step_2_vals$file_name <- input$upload_file$name

        # Run data processing
        data_processed <- soils::process_data(validation_result)

        data <- data_processed$results_wide
        data_dict <- data_processed$data_dict

        state$step_2_vals$data <- data

        state$years <- sort(unique(data$year), decreasing = TRUE)
        state$producer_ids <- data |> dplyr::distinct(year, producer_id)
        state$data_processed <- data_processed
        state$data <- data
        state$data_dictionary <- data_dict
      }
    })

    # --- Download handler ---
    output$download_errors <- downloadHandler(
      filename = function() {
        paste0("soil-data-issues_", Sys.Date(), ".xlsx")
      },
      content = function(file) {
        soils::create_issue_xlsx(validation_result(), file)
      }
    )
  })
}
