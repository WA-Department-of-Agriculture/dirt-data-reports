mod_step_3_project_info_ui <- function(id, state) {
  ns <- NS(id)
  
  #read in english mapping file
  mapping<-read.csv(paste0("quarto/english/measurement_dictionary.csv"))
  
  measurement_choices <- mapping %>%
    split(.$type) %>%
    map(~ setNames(.x$file_name, .x$aliases))
  
  measurement_content <- mapping %>%
    mutate(content = glue::glue("<div>{name}</div><div style='display:none'>{aliases}</div>"))
  
  measurement_selected <- mapping$file_name
  
  #fix values so they dont update unless changed 
  project_name_val <- isolate(state$project_info_vals$project_name %||% "")
  project_summary_val <- isolate(state$project_info_vals$project_summary %||% "")
  soil_depth_val <- isolate(state$project_info_vals$soil_depth %||% "0-12 inches")
  looking_forward_val <- isolate(state$project_info_vals$looking_forward %||% "")
  measurement_val <- isolate(state$project_info_vals$measurement_definitions %||% measurement_selected)
  
  
  div(class = "form-content",
      h4(class = "form-step", "Step 3"),
      h2(class = "form-title", "Project Info"),
      
      textInput(ns("project_name"), "Project Name", value = project_name_val),
      
      tags$label("Project Summary"),
      shinyAce::aceEditor(
        ns("project_summary"),
        value = project_summary_val,
        mode = "markdown",
        height = "150px"
      ),
      
      shinyWidgets::pickerInput(
        inputId = ns("measurement_definitions"),
        label = "Measurement Definitions",
        choices = measurement_choices,
        selected = measurement_val,
        choicesOpt = list(content = measurement_content$content),
        options = shinyWidgets::pickerOptions(
          title = "Which measurements were included in your project?",
          actionsBox = TRUE,
          liveSearch = TRUE
        ),
        multiple = TRUE
      ),      
      textInput(ns("soil_depth"), "Soil Sample Depth", value = soil_depth_val),
      
      tags$label("Looking Forward"),
      shinyAce::aceEditor(
        ns("looking_forward"),
        value = looking_forward_val,
        mode = "markdown",
        height = "150px"
      ),
      
      actionButton(ns("report_preview"), "Preview", style='margin-top:20px')
  )
}



mod_step_3_project_info_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Save all values into state
    observe({
      
      state$project_info_vals <- list(
        project_name = input$project_name,
        project_summary = input$project_summary,
        measurement_definitions = input$measurement_definitions,
        soil_depth = input$soil_depth,
        looking_forward = input$looking_forward
      )
      
      state$step_3_valid <- !is.null(input$measurement_definitions) &&
        length(input$measurement_definitions) > 0
      
    })
    
    
    # Preview modal
    observeEvent(input$report_preview, {
      req(state$language())
    
      
      lang_map <- yaml::read_yaml(paste0("quarto/",state$language(),"/mapping.yml"))
      measure_mapping<-read.csv(paste0("quarto/", state$language(), "/measurement_dictionary.csv"))
      

      tr <- function(key) {
        lang_map[[key]] %||% key
      }
      
      selected_mapping <- measure_mapping%>%
        dplyr::filter(file_name %in% input$measurement_definitions)

      grouped_measures <- split(selected_mapping$file_name, selected_mapping$section_name)
      
      # Section color mapping
      section_colors <- data.frame(
        section_name = c("biological", "physical", "chemical"),
        color = c("#335c67", "#a60f2d", "#d4820a"),
        stringsAsFactors = FALSE
      )
      
      # Create tab panels
      tabs <- lapply(names(grouped_measures), function(section_name) {
        image <- selected_mapping$type[selected_mapping$section_name == section_name][1]
        image_path <- paste0("pictures/", tolower(image), ".png")
        section_color <- section_colors$color[section_colors$section_name == section_name]
        
        tabPanel(
          title = tags$div(
            tags$img(src = image_path, style = "height:30px; padding-right:5px"),
            tags$span(tr(section_name), style = glue::glue("color:{section_color}"))
          ),
          do.call(div, lapply(grouped_measures[[section_name]], function(qmd_file) {
            htmltools::includeMarkdown(read_qmd_as_md(paste0("quarto/", state$language(),"/", qmd_file)))
          }))
        )
      })
      
      # Show modal with all sections
      showModal(modalDialog(
        title = "Preview Sections",
        div(
          tags$h3(tr("project_summary")),
          HTML(markdown::markdownToHTML(text = input$project_summary, fragment.only = TRUE)),
          
          tags$h3(tr("what_we_measured_in_your_soil")),
          tabsetPanel(id = "dynamicTabs", !!!tabs),
          
          tags$h3(tr("soil_depth")),
          p(input$soil_depth),
          
          tags$h3(tr("looking_forward")),
          HTML(markdown::markdownToHTML(text = input$looking_forward, fragment.only = TRUE))
        ),
        easyClose = TRUE,
        size = "l"
      ))
    })
    
    
    # Store project info params in state
    state$project_info <- reactive({
      state$project_info_vals
    })
  })
}