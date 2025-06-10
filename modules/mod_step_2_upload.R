# Note: This module assumes data_validation.R has been sourced
# Make sure to source("data_validation.R") before using this module

mod_step_2_upload_ui <- function(id, state) {
  ns <- NS(id)
  
  # Display message if file already uploaded
  uploaded_msg <- isolate({
    if (!is.null(state$step_2_vals) && 
        is.list(state$step_2_vals) && 
        !is.null(state$step_2_vals$file_name)) {
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
    p(class="form-text",
      "Upload your completed template to check for errors. If any issues are found, an error message will appear below. Please fix the errors in your file and upload it again. For your privacy, no data is stored or saved by this tool."
    ),
    actionLink(
      ns("requirement_info"),
      "Learn about the data validation checks.",
      icon = icon("circle-info")
    ),
    br(),
    uploaded_msg,
    fileInput(ns("upload_file"), "Upload Data (.xlsx)", accept = ".xlsx"),
    div(id = ns("error_message"))
  )
}

mod_step_2_upload_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    observeEvent(input$requirement_info, {
      show_modal(
        title = "Data Check",
        id = "modal-validation",
        md = "about_validation"
      )
    })
    
    observeEvent(input$upload_file, {
      req_fields <- read.csv("files/required-fields.csv")
      
      # Remove previous messages
      removeUI(
        selector = paste0("#", ns("error_message"), " > *"),
        immediate = TRUE
      )
      
      # Get current language from state (default to english if not set)
      current_language <- "english"
      
      if (!is.null(state$step_1_vals) && !is.null(state$step_1_vals$language)) {
        current_language <- state$step_1_vals$language
      } else if (!is.null(state$language) && is.function(state$language)) {
        lang_val <- state$language()
        if (!is.null(lang_val)) current_language <- lang_val
      }
      
      # Validate the uploaded file with language parameter
      # This calls validate_data_file() from data_validation.R
      validation_results <- tryCatch(
        validate_data_file(input$upload_file$datapath, req_fields, current_language),
        error = function(e) {
          insertUI(
            selector = paste0("#", ns("error_message")),
            where = "beforeEnd",
            ui = div(class = "alert alert-danger", paste("Error:", e$message))
          )
          return(NULL)
        }
      )
      
      if (is.null(validation_results)) {
        state$step_2_valid <- FALSE
        return()
      }
      
      if (length(validation_results) == 0) {
        # ✅ All checks passed
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(class = "alert alert-success", "All checks passed!")
        )
        
        # read in both data and data dictionary files
        uploaded_data <- readxl::read_xlsx(
          input$upload_file$datapath,
          sheet = "Data"
        )
        uploaded_data_dictionary <- readxl::read_xlsx(
          input$upload_file$datapath,
          sheet = "Data Dictionary"
        )
        
        # Save to state
        state$step_2_valid <- TRUE
        state$step_2_vals$file_name <- input$upload_file$name
        state$step_2_vals$data <- uploaded_data
        
        # Used by Step 4
        state$years <- sort(unique(uploaded_data$year), decreasing = TRUE)
        state$producer_ids <- uploaded_data %>%
          distinct(year, producer_id)
        state$data <- uploaded_data
        state$data_dictionary <- uploaded_data_dictionary
      } else {
        # ❌ Validation failed
        # Flatten nested error lists for display
        all_errors <- unlist(validation_results, recursive = TRUE)
        
        # Convert to native encoding to handle Spanish characters safely
        all_errors <- sapply(all_errors, enc2native)
        
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-danger",
            tags$strong("Please review the following errors, correct them in your data spreadsheet, and re-upload."),
            tags$br(),
            tags$br(),
            tags$strong("Validation Errors:"),
            tags$ul(lapply(all_errors, tags$li))
          )
        )
        state$step_2_valid <- FALSE
      }
    })
  })
}