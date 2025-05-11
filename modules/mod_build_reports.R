mod_build_reports_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    #add timezone to a hidden input
    tags$script(HTML("
      Shiny.addCustomMessageHandler('getTimeZone', function(message) {
        var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
        Shiny.setInputValue('build-user_timezone', tz);
      });
    ")),
    tags$div(class = "container-reports",
        tags$div(style='display:flex',
            # Vertical Side Stepper (clickable vertical steps)
            tags$div(
              class = "stepper",
              uiOutput(ns("stepper_ui"))
            ),
            # Main Content Panel for Form
            tags$div(class = "form-section",
                tags$a(
                  style = "width:100%;display:flex;margin-bottom:10px;justify-content:end;",
                  href = "https://arcg.is/1zPbbL1",
                  target = "_blank",
                  "Report Issue"
                ),
                # progress bar for smaller screens
                tags$div(
                  class = "progress-bar-container",
                  tags$div(
                    class = "progress-bar-header",
                    tags$span(class = "progress-title", "Step Progress"),
                    tags$span(id = "progress-step-text", class = "progress-step-text", "1/4")
                  ),
                  
                  tags$div(
                    class = "progress-bar-wrapper",
                    tags$div(id = "progress-bar", class = "progress-bar", style = "width: 25%;")
                  )
                ),
                #Form Content 
                tags$div(id = ns("dynamic_content"), uiOutput(ns("step_ui"))),
                #Form Buttons
                tags$div(class = "buttons", uiOutput(ns("step_nav_buttons")))
            )
        )
    )
  )
}


mod_build_reports_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    #trigger to get user timezone
    observe({
      session$sendCustomMessage("getTimeZone", list())
    })
    
    
    # This holds the current step (shared across submodules)
    state <- reactiveValues(
      current_step = 1,
      step_2_valid = FALSE,
      step_3_valid = FALSE,
      user_timezone = NULL)

    observe({
      state$user_timezone<-input$user_timezone
    })
    
    
    output$stepper_ui <- renderUI({
      tagList(
        tags$div(
          id = ns("step_1"),
          class = paste("step", if (state$current_step == 1) "active"),
          `data-step` = 1,
          title = "Start here",
          onclick = paste0("setStep(this, '", ns("step_click"), "')"),
          tags$div(class = "step-circle", icon("download")),
          tags$div(div(class = "step-num", "Step 1"), div(class = "step-text", "Download Template"))
        ),
        
        tags$div(
          id = ns("step_2"),
          class = paste("step", if (state$current_step == 2) "active"),
          `data-step` = 2,
          title = "Upload your completed data template",
          onclick = paste0("setStep(this, '", ns("step_click"), "')"),
          tags$div(class = "step-circle", icon("table")),
          tags$div(div(class = "step-num", "Step 2"), div(class = "step-text", "Upload Data"))
        ),
        
        tags$div(
          id = ns("step_3"),
          class = paste(
            "step",
            if (!state$step_2_valid) "disabled",
            if (state$current_step == 3) "active"
          ),
          `data-step` = 3,
          title = if (!state$step_2_valid) "Please upload valid data in Step 2 first",
          onclick = if (state$step_2_valid) paste0("setStep(this, '", ns("step_click"), "')") else NULL,
          div(class = "step-circle", icon("gear")),
          div(div(class = "step-num", "Step 3"), div(class = "step-text", "Project Info"))
        ),
        
        div(
          id = ns("step_4"),
          class = paste(
            "step",
            if (!state$step_2_valid || !state$step_3_valid) "disabled",
            if (state$current_step == 4) "active"
          ),
          `data-step` = 4,
          title = if (!state$step_2_valid || !state$step_3_valid) "Please complete prior steps",
          onclick = if (state$step_2_valid && state$step_3_valid) paste0("setStep(this, '", ns("step_click"), "')") else NULL,
          div(class = "step-circle", icon("file-alt")),
          div(div(class = "step-num", "Step 4"), div(class = "step-text", "Build Reports"))
        )
      )
    })
    
    
    # Step UI loader based on current step
    output$step_ui <- renderUI({
      switch(state$current_step,
             mod_step_1_template_ui(ns("step1"), state),
             mod_step_2_upload_ui(ns("step2"), state),
             mod_step_3_project_info_ui(ns("step3"), state),
             mod_step_4_build_reports_ui(ns("step4"), state)
      )
    })
    
    # Nav buttons at the bottom
    output$step_nav_buttons <- renderUI({
      next_disabled <- FALSE
      tooltip <- NULL
      
      if (state$current_step == 2 && !state$step_2_valid) {
        next_disabled <- TRUE
        tooltip <- "Please upload valid data before continuing."
      }
      
      if (state$current_step == 3 && !state$step_3_valid) {
        next_disabled <- TRUE
        tooltip <- "Please select at least one measurement definition."
      }
      
      # Adjust alignment based on step
      align_style <- if (state$current_step == 1) {
        "width:100%; display: flex; justify-content: flex-end; gap: 10px;"
      } else {
        "width: 100%; display: flex; justify-content: space-between; gap: 10px;"
      }
      
      tags$div(style = align_style,
               if (state$current_step > 1)
                 actionButton(ns("prev_step"), "Previous", class = "prev"),
               
               if (state$current_step < 4)
                 tags$div(
                   style = "position: relative;",
                   title = tooltip,
                   actionButton(
                     ns("next_step"),
                     "Next",
                     class = "next",
                     disabled = next_disabled
                   )
                 )
      )
    })
    
    
    
    # Handle Next/Previous button clicks
    observeEvent(input$next_step, {
      if (state$current_step < 4) {
        state$current_step <- state$current_step + 1
        shinyjs::runjs(glue::glue("setStep(document.querySelector('[data-step=\"{state$current_step}\"]'))"))
      }
    })
    
    observeEvent(input$prev_step, {
      if (state$current_step > 1) {
        state$current_step <- state$current_step - 1
        shinyjs::runjs(glue::glue("setStep(document.querySelector('[data-step=\"{state$current_step}\"]'))"))
      }
    })
    
    observeEvent(input$step_click, {
      req(input$step_click %in% 1:4)
      state$current_step <- input$step_click
    })
    
    # Load in submodules
    mod_step_1_template_server("step1", state)
    mod_step_2_upload_server("step2", state)
    mod_step_3_project_info_server("step3", state)
    mod_step_4_build_reports_server("step4", state)
  })
}
