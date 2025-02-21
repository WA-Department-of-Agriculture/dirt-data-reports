library(shiny)

# Custom input function
customButtonInput <- function(inputId, choices, multi = FALSE, selected = NULL) {
  choices_json <- jsonlite::toJSON(choices, auto_unbox = TRUE)
  selected_json <- jsonlite::toJSON(selected, auto_unbox = TRUE)
  multi_attr <- ifelse(multi, "true", "false")
  
  tags$div(
    id = inputId,
    class = "custom-button-group",
    `data-multi` = multi_attr,
    `data-choices` = choices_json,
    `data-selected` = selected_json,
    lapply(names(choices), function(label) {
      value <- choices[[label]]
      active_class <- if (value %in% selected) "active" else ""
      tags$button(
        type = "button",
        class = paste("custom-button", active_class),
        `data-value` = value,
        label
      )
    })
  )
}

# JavaScript binding (inline script) - Fix for JSON encoding issue


# CSS to style the active buttons
css <- "
.custom-button {
  padding: 10px 15px;
  margin: 5px;
  border: 1px solid #007bff;
  background-color: white;
  cursor: pointer;
  border-radius: 5px;
}

.custom-button.active {
  background-color: #007bff;
  color: white;
}
"

# UI Example
ui <- fluidPage(
  tags$head(
    tags$script(HTML(js)), 
    tags$style(HTML(css))
  ),
  
  customButtonInput("language", 
                    choices = c("English" = "template.qmd", "Spanish" = "template_esp.qmd"),
                    multi = FALSE, 
                    selected = "template.qmd"),
  
  verbatimTextOutput("selected_value")
)

# Server logic
server <- function(input, output, session) {
  output$selected_value <- renderPrint({ input$language })
}

shinyApp(ui, server)
