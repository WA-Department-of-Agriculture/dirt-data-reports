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
        style = "margin-top:20px;width:320px;"
      )
    )
  )
}


mod_step_1_template_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    
    
   
    
    # Save value into state
    observe({
      state$step_1_vals$language <- input$language
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
