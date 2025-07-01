mod_step_1_template_ui <- function(id, state) {
  ns <- NS(id)
  
  # Get stored value or default to English
  language_val <- isolate(state$step_1_vals$language %||% "english")
  
  tags$div(
    class = "form-content",
    h4(class = "form-step", "Step 1"),
    h2(class = "form-title", "Download Template"),
    p(
      class = "form-text",
      "Choose which language the report will be in.",
      "Download the Excel template and replace the example data in the",
      tags$b("Data"),
      "and",
      tags$b("Data Dictionary"),
      "tabs with your own.",
      br(),
      br(),
      actionLink(
        ns("about_template"),
        "See instructions for using the data template.",
        icon = icon("triangle-exclamation")
      )
    ),
    div(
      class = "custom-toggle",
      style = "width:100%;display:flex;justify-content:center",
      shinyWidgets::radioGroupButtons(
        inputId = ns("language"),
        label = "Select Report Language",
        choices = c("English" = "english", "Spanish" = "spanish"),
        selected = language_val,
        justified = TRUE
      )
    ),
    div(
      style = "display:flex;justify-content:center",
      downloadButton(
        ns("download_template"),
        "Download Template",
        style = "margin-top:24px;width:436px;"
      )
    )
  )
}
mod_step_1_template_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    
    # Track previous language to detect changes
    prev_language <- reactiveVal(NULL)
    
    # Handle language changes
    observeEvent(input$language, {
      current_lang <- input$language
      
      # If this is not the first time and language actually changed
      if (!is.null(prev_language()) && prev_language() != current_lang) {
        
        # Only show modal if user has already uploaded data (step 2 completed)
        if (state$step_2_valid) {
          # Show confirmation dialog
          showModal(modalDialog(
            title = "Language Change Detected",
            div(
              p("Changing the language will require you to download the new template and re-upload your data."),
              p(strong("Do you want to continue?"))
            ),
            footer = tagList(
              actionButton(ns("confirm_reset"), "Change Language", class = "btn btn-warning"),
              modalButton("Cancel")
            ),
            easyClose = FALSE
          ))
          
          # Temporarily revert the input until confirmed
          updateRadioGroupButtons(session, "language", selected = prev_language())
          return()
        } else {
          # No data uploaded yet, allow free language change
          prev_language(current_lang)
          state$step_1_vals$language <- current_lang
        }
      } else {
        # For initial load, just update stored values
        prev_language(current_lang)
        state$step_1_vals$language <- current_lang
      }
    })
    
    # Handle confirmation of language change (only when data was uploaded)
    observeEvent(input$confirm_reset, {
      removeModal()
      
      # Get the intended new language (from what user originally selected)
      new_language <- if (prev_language() == "english") "spanish" else "english"
      
      # Show notification
      showNotification(
        "Language changed. Please download the new template and re-upload your data.",
        type = "warning",
        duration = 8
      )
      
      # Reset Steps 2-4 validation and data, but preserve Step 3 text inputs
      state$step_2_valid <- FALSE
      state$step_3_valid <- FALSE
      
      # Safely clear Step 2 and 4 state, preserve Step 3 project info text
      # Make sure we initialize with proper structure
      if (is.null(state$step_2_vals)) state$step_2_vals <- list()
      if (is.null(state$step_4_vals)) state$step_4_vals <- list()
      
      # Clear only specific keys rather than entire list
      state$step_2_vals$file_name <- NULL
      state$step_2_vals$data <- NULL
      state$step_4_vals <- list()
      # Note: Intentionally NOT clearing state$step_3_vals to preserve text inputs
      
      # Clear data-dependent state
      state$data <- NULL
      state$data_dictionary <- NULL
      state$years <- NULL
      state$producer_ids <- NULL
      
      # Update to the new language
      updateRadioGroupButtons(session, "language", selected = new_language)
      prev_language(new_language)
      state$step_1_vals$language <- new_language
    })
    
    # Modal for help
    observeEvent(input$about_template, {
      show_modal(
        title = "Data Template",
        id = "modal-template",
        md = "about_template"
      )
    })
    
    # Template download logic
    output$download_template <- downloadHandler(
      filename = function() {
        paste0("soil-data-template-", Sys.Date(), ".xlsx")
      },
      content = function(file) {
        template_file <- if (input$language == "spanish") {
          "files/template-esp.xlsx"
        } else {
          "files/template.xlsx"
        }
        file.copy(template_file, file)
      }
    )
    
    # Provide global access to the current language
    state$language <- reactive({
      input$language
    })
  })
}