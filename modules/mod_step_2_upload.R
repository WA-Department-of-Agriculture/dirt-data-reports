mod_step_2_upload_ui <- function(id, state) {
  ns <- NS(id)
  
  # Display message if file already uploaded
  uploaded_msg <- isolate({
    if (!is.null(state$step_2_vals$file_name)) {
      div(class = "alert alert-info",
          tags$strong("Previously uploaded file: "),
          state$step_2_vals$file_name
      )
    } else {
      NULL
    }
  })
  
  div(class = "form-content",
      h4(class = "form-step", "Step 2"),
      h2(class = "form-title", "Upload Data"),
      p("Upload your completed template to validate the data. Any checks that fail will be printed below in an error message."),
      actionLink(ns("requirement_info"), "Learn about the data validation checks", icon = icon("circle-info")),
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
      req_fields <- read.csv("files/required_fields.csv")
      
      # Remove previous messages
      removeUI(selector = paste0("#", ns("error_message"), " > *"), immediate = TRUE)
      
      # Validate the uploaded file
      validation_results <- tryCatch(
        validate_data_file(input$upload_file$datapath, req_fields),
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
        #read in both data and data dictionary files
        uploaded_data <- readxl::read_xlsx(input$upload_file$datapath, sheet = "Data")
        uploaded_data_dictionary <- readxl::read_xlsx(input$upload_file$datapath, sheet = "Data Dictionary")
        
        
        # Save to state
        state$step_2_valid <- TRUE
        state$step_2_vals$file_name <- input$upload_file$name
        state$step_2_vals$data <- uploaded_data
        
        # Used by Step 4
        state$years <- sort(unique(uploaded_data$year), decreasing = TRUE)
        state$producer_ids <- uploaded_data %>%
          distinct(year, producer_id)
        state$data <- uploaded_data
        state$data_dictionary<-uploaded_data_dictionary
      } else {
        # ❌ Validation failed
        insertUI(
          selector = paste0("#", ns("error_message")),
          where = "beforeEnd",
          ui = div(
            class = "alert alert-danger",
            tags$strong("Validation Errors:"),
            tags$ul(lapply(validation_results, tags$li))
          )
        )
        state$step_2_valid <- FALSE
      }
    })
  })
}
