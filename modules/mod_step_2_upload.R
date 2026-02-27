# Note: This module assumes data_validation.R has been sourced
# Make sure to source("utils/data_validation.R") before using this module

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
      downloadButton(ns("download_errors"), "Download file with errors",
                     class = "btn-outline-danger")
    )
  )
}

mod_step_2_upload_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Store values the download handler needs
    upload_path <- reactiveVal(NULL)
    upload_name <- reactiveVal(NULL)
    validation_issues <- reactiveVal(NULL)
    stored_req_fields_data <- reactiveVal(NULL)
    
    observeEvent(input$requirement_info, {
      show_modal(
        title = "Data Check",
        id = "modal-validation",
        md = "about_validation"
      )
    })
    
    observeEvent(input$upload_file, {
      req_fields <- read.csv("files/required-fields.csv")
      req_fields_data <- req_fields |> dplyr::filter(sheet == "Data")
      req_fields_dd   <- req_fields |> dplyr::filter(sheet == "Data Dictionary")
      
      # Remove previous messages and hide download button
      removeUI(
        selector = paste0("#", ns("error_message"), " > *"),
        immediate = TRUE,
        multiple = TRUE
      )
      shinyjs::hide("download_errors")
      validation_issues(NULL)
      stored_req_fields_data(NULL)
      
      # Get current language from state (default to english if not set)
      current_language <- "english"
      
      if (!is.null(state$step_1_vals) && !is.null(state$step_1_vals$language)) {
        current_language <- state$step_1_vals$language
      } else if (!is.null(state$language) && is.function(state$language)) {
        lang_val <- state$language()
        if (!is.null(lang_val)) current_language <- lang_val
      }
      
      file_path <- input$upload_file$datapath
      
      # --- Gate check ---
      gate_result <- check_file_readable(file_path, output = "ui")
      
      if (!is_gate_pass(gate_result)) {
        results <- split_issues(gate_result)
        
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-danger",
            shiny::icon("circle-exclamation", style = "margin-right:2px"),
            tags$strong("Errors (must fix before proceeding):"),
            tags$ul(lapply(results$errors, \(e) tags$li(e$message)))
          )
        )
        
        # Show download with gate errors
        upload_path(file_path)
        upload_name(input$upload_file$name)
        validation_issues(gate_result)
        stored_req_fields_data(req_fields_data)
        shinyjs::show("download_errors")
        
        state$step_2_valid <- FALSE
        return()
      }
      
      # Gate passed — data is loaded
      data <- gate_result$data
      data_dict <- gate_result$data_dict
      
      # --- Independent checks ---
      all_issues <- c(
        # Errors
        check_required_columns(data, req_fields_data, output = "ui"),
        check_required_dict_fields(data_dict, req_fields_dd, output = "ui"),
        check_uniqueness(data, req_fields_data, output = "ui"),
        check_data_types(data, req_fields_data, output = "ui"),
        check_missing_values(data, req_fields_data, output = "ui"),
        # Warnings
        check_additional_columns(data, req_fields_data, output = "ui"),
        check_percent_range(data, output = "ui"),
        check_dict_mismatch(data, data_dict, req_fields_data, output = "ui"),
        check_measurement_groups(data_dict, current_language, output = "ui")
      )
      
      results <- split_issues(all_issues)
      
      # --- Render results ---
      
      if (length(all_issues) == 0) {
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
          cards <- c(cards, list(
            div(
              class = "alert alert-danger",
              shiny::icon("circle-exclamation", style = "margin-right:2px"),
              tags$strong("Errors (must fix before proceeding):"),
              tags$ul(lapply(results$errors, \(e) tags$li(e$message)))
            )
          ))
        }
        
        if (length(results$warnings) > 0) {
          cards <- c(cards, list(
            div(
              class = "alert alert-warning",
              shiny::icon("triangle-exclamation", style = "margin-right:2px"),
              tags$strong("Warnings (review recommended):"),
              tags$ul(lapply(results$warnings, \(w) tags$li(w$message)))
            )
          ))
        }
        
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = tagList(cards)
        )
        
        # Show download button
        upload_path(file_path)
        upload_name(input$upload_file$name)
        validation_issues(all_issues)
        stored_req_fields_data(req_fields_data)
        shinyjs::show("download_errors")
      }
      
      # --- Update state ---
      
      if (length(results$errors) > 0) {
        # Errors present — block progression
        state$step_2_valid <- FALSE
      } else {
        # No errors (passed or warnings only) — allow progression
        state$step_2_valid <- TRUE
        state$step_2_vals$file_name <- input$upload_file$name
        state$step_2_vals$data <- data
        
        state$years <- sort(unique(data$year), decreasing = TRUE)
        state$producer_ids <- data |> dplyr::distinct(year, producer_id)
        state$data <- data
        state$data_dictionary <- data_dict
      }
    })
    
    # --- Download handler ---
    output$download_errors <- downloadHandler(
      filename = function() {
        paste0("errors_", upload_name())
      },
      content = function(file) {
        create_error_xlsx(upload_path(), file, validation_issues(),
                          stored_req_fields_data())
      }
    )
  })
}