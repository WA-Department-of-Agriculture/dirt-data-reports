mod_step_3_project_info_ui <- function(id, state) {
  ns <- NS(id)
  
  # read in mapping file
  mapping <- read.csv(
    paste0(
      "quarto/",
      state$language(),
      "/measurement_dictionary.csv"
    ),
    encoding = "UTF-8"
  )
  
  measurement_choices <- mapping %>%
    split(.$type) %>%
    map(~ setNames(.x$file_name, .x$aliases))
  
  measurement_content <- mapping %>%
    mutate(content = glue::glue(
      "<div>{name}</div><div style='display:none'>{aliases}</div>"
    ))
  
  # Get the abbr column from the uploaded data dictionary
  measurement_in_dictionary <- state$data_dictionary$abbr
  
  # Match the abbr column with the aliases and get the file_name to pre-select
  # the uploaded measurements in the measurement definition picker
  measurement_selected <- mapping |>
    dplyr::select(c(aliases, file_name)) |>
    tidyr::separate_longer_delim(cols = aliases, delim = "; ") |>
    dplyr::filter(aliases %in% measurement_in_dictionary) |>
    dplyr::pull(file_name)
  
  # fix values so they don't update unless changed
  project_name_val <- isolate(
    state$project_info_vals$project_name %||% "Soil Sampling Project"
  )
  project_summary_val <- isolate(
    state$project_info_vals$project_summary %||% "Thank the participating farmer. Consider including information related to how many samples you've taken, in how many crops and regions. Identify the project team and acknowledge support from your funders and collaborators."
  )
  project_results_val <- isolate(
    state$project_info_vals$project_results %||% "Below are tables and graphs describing the measurements from your soils. Each point represents a sample we collected. Take a look to see how your fields compare to others in the project. All samples were collected from **[EDIT: SOIL DEPTH (e.g. 0-6 inches, or 0-30 cm)]**."
  )
  looking_forward_val <- isolate(
    state$project_info_vals$looking_forward %||% "Consider describing how this data will be used. Are you building decision support tools? Publications? Will you be speaking at upcoming field days or conferences about this work? Soils data can be confusing… let your audience know that this is just the start of the conversation! Thank participants once again."
  )
  measurement_val <- isolate(
    state$project_info_vals$measurement_definitions %||% measurement_selected
  )
  
  div(
    class = "form-content",
    h4(class = "form-step", "Step 3"),
    h2(class = "form-title", "Project Info"),
    p(
      class = "form-text",
      "Customize reports with your project-specific information and then click",
      tags$b("Preview"),
      "to see what your text will look like in the report. See",
      actionLink(
        ns("redirect_learn_more"),
        "Learn More"
      ),
      "for full examples of the reports. "
    ),
    actionLink(
      inputId = ns("customize"),
      label = tags$span(
        tags$b("Optional"),
        ": Learn how to further customize your text and reports."
      )
    ),
    div(
      class = "alert alert-warning d-flex align-items-center",
      style = "margin:20px 0px",
      role = "alert",
      shiny::icon("triangle-exclamation", class = "me-2"),
      tags$span("Note: Your text won't be saved and will be lost if you exit this session or after 15 minutes of inactivity. Please save a copy separately.")
    ),
    br(),
    textInput(
      ns("project_name"),
      label = bslib::tooltip(
        trigger = tags$span(
          "Project Name",
          icon("circle-info")
        ),
        placement = "right",
        a11y = "sem",
        title = "Title of the report",
        show = TRUE,
        "Title of the report"
      ),
      value = project_name_val
    ),
    bslib::tooltip(
      trigger = tags$span(
        tags$label("Project Summary"),
        icon("circle-info")
      ),
      placement = "right",
      a11y = "sem",
      title = "Introduction at the top of the report below the title",
      show = TRUE,
      "Introduction at the top of the report below the title"
    ),
    shinyAce::aceEditor(
      ns("project_summary"),
      wordWrap = TRUE,
      value = project_summary_val,
      mode = "markdown",
      height = "150px"
    ),
    tags$label(
      `for` = "measurement_definitions",
      actionLink(label="Measurement Definitions", inputId = ns("definitions_modal"), 
                 class = "a"
      )
    ),
    shinyWidgets::pickerInput(
      inputId = ns("measurement_definitions"),
      choices = measurement_choices,
      selected = measurement_val,
      choicesOpt = list(content = measurement_content$content),
      options = shinyWidgets::pickerOptions(
        actionsBox = TRUE,
        liveSearch = TRUE,
        noneSelectedText = "Select at least one measurement",
        selectedTextFormat = "count > 5",
        countSelectedText = "{0} measurements selected"
      ),
      multiple = TRUE
    ),
    bslib::tooltip(
      trigger = tags$span(
        tags$label("Project Results"),
        icon("circle-info")
      ),
      placement = "right",
      a11y = "sem",
      title = "Introduction to the 'Project Results' section",
      show = TRUE,
      "Introduction to the 'Project Results' section"
    ),
    shinyAce::aceEditor(
      ns("project_results"),
      value = project_results_val,
      wordWrap = TRUE,
      mode = "markdown",
      height = "150px",
    ),
    bslib::tooltip(
      trigger = tags$span(
        tags$label("Looking Forward"),
        icon("circle-info")
      ),
      placement = "right",
      a11y = "sem",
      title = "Summary and call to action at the end of the report",
      show = TRUE,
      "Summary and call to action at the end of the report"
    ),
    shinyAce::aceEditor(
      ns("looking_forward"),
      value = looking_forward_val,
      wordWrap = TRUE,
      mode = "markdown",
      height = "150px"
    ),
    actionButton(ns("report_preview"), "Preview", style = "margin-top:20px")
  )
}



mod_step_3_project_info_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Update measurement definitions picker when language changes
    observeEvent(state$language(), {
      req(state$language())
      
      # Read in mapping file for new language
      mapping <- read.csv(
        paste0(
          "quarto/",
          state$language(),
          "/measurement_dictionary.csv"
        ),
        encoding = "UTF-8"
      )
      
      # Recreate measurement choices
      measurement_choices <- mapping %>%
        split(.$type) %>%
        map(~ setNames(.x$file_name, .x$aliases))
      
      # Recreate measurement content
      measurement_content <- mapping %>%
        mutate(content = glue::glue(
          "<div>{name}</div><div style='display:none'>{aliases}</div>"
        ))
      
      # Get the abbr column from the uploaded data dictionary
      measurement_in_dictionary <- state$data_dictionary$abbr
      
      # Match the abbr column with the aliases and get the file_name to pre-select
      # the uploaded measurements in the measurement definition picker
      measurement_selected <- mapping |>
        dplyr::select(c(aliases, file_name)) |>
        tidyr::separate_longer_delim(cols = aliases, delim = "; ") |>
        dplyr::filter(aliases %in% measurement_in_dictionary) |>
        dplyr::pull(file_name)
      
      # Clear the stored measurement definitions from state to ensure reset
      if (!is.null(state$project_info_vals)) {
        state$project_info_vals$measurement_definitions <- NULL
      }
      
      # Update the picker input with new choices and selection
      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "measurement_definitions",
        choices = measurement_choices,
        selected = measurement_selected,
        choicesOpt = list(content = measurement_content$content)
      )
    }, ignoreInit = TRUE) # ignoreInit = TRUE prevents this from running on module initialization
    
    # redirect to Learn More Page - use rootScope to use parent level ids
    observeEvent(input$redirect_learn_more, {
      updateNavbarPage(
        session$rootScope(),
        "main_page",
        selected = "page_learn_more"
      )
    })
    
    observeEvent(input$customize, {
      show_modal(
        title = "More Customization",
        id = "modal-customize",
        md = "about_customization"
      )
    })
    
    observeEvent(input$definitions_modal, {
      
      # Normalize selected abbreviations from user-uploaded data
      selected_abbrs <- trimws(state$data_dictionary$abbr)
      
      # Load and rename the measurement dictionary
      raw_measure_mapping <- read.csv(
        paste0("quarto/", state$language(), "/measurement_dictionary.csv"),
        encoding = "UTF-8"
      ) |>
        dplyr::select(name, aliases) |>
        dplyr::rename(
          Measurement = name,
          Abbreviations = aliases
        )
      
      # Process the mapping: split aliases, match against selected, style pills
      processed_mapping <- raw_measure_mapping |>
        dplyr::mutate(
          # Split alias string into a list of terms
          alias_terms = purrr::map(Abbreviations, ~ strsplit(.x, ";\\s*")[[1]] |> trimws()),
          
          # Flag if any alias matches selected_abbrs
          has_match = purrr::map_lgl(alias_terms, ~ any(.x %in% selected_abbrs)),
          
          # Bold the Measurement name if there is a match
          Measurement = ifelse(
            has_match,
            paste0("**", Measurement, "**"),
            Measurement
          ),
          
          # Convert aliases to styled pill HTML
          Abbreviations = purrr::map_chr(alias_terms, function(terms) {
            paste0(
              purrr::map_chr(terms, function(term) {
                matched <- term %in% selected_abbrs
                style <- if (matched) {
                  "background-color:#d4edda; border:1px solid #28a745; color:#155724;"
                } else {
                  "background-color:#f0f0f0; border:1px solid #ccc; color:#333;"
                }
                glue::glue("<span style='{style} border-radius:12px; padding:2px 8px; margin:4px 2px; display:inline-block; font-size:0.85em;'>{term}</span>")
              }),
              collapse = " "
            )
          })
        )
      
      # Count how many measurements had at least one matched alias
      num_matched <- sum(processed_mapping$has_match)
      
      # Create GT table
      measure_table <- processed_mapping |>
        dplyr::select(Measurement, Abbreviations) |>
        gt::gt() |>
        gt::fmt_markdown(columns = everything()) |>
        gt::cols_label(
          Measurement = gt::md("**Measurement**"),
          Abbreviations = gt::md("**Abbreviations**")
        )
      
      # Show modal
      showModal(modalDialog(
        title = "Understanding Measurement Definitions",
        size = "l",
        div(
          tags$p("Selected definitions will appear in the ", tags$b("What We Measured in Your Soil"), " section."),
          tags$p("These are pre-selected based on the ", tags$b("abbr"), " column in your uploaded Data Dictionary, but please review them — we may use different names than your abbreviations."),
          tags$p("To exclude a measurement from the ", tags$b("Project Results"), " section, remove it from both the Data and Data Dictionary tabs in your spreadsheet before re-uploading in Step 2."),
          tags$hr(),
          HTML(glue::glue("<p>Your uploaded abbreviations (highlighted in green) matched <strong>{num_matched}</strong> measurement definition{if (num_matched != 1) 's' else ''} (bolded).</p>")),
          htmltools::HTML(gt::as_raw_html(measure_table))
        ),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })
    
    
    
    # Save all values into state
    observe({
      state$project_info_vals <- list(
        project_name = input$project_name,
        project_summary = input$project_summary,
        measurement_definitions = input$measurement_definitions,
        project_results = input$project_results,
        looking_forward = input$looking_forward
      )
      
      state$step_3_valid <- !is.null(input$measurement_definitions) &&
        length(input$measurement_definitions) > 0
    })
    
    
    # Preview modal
    observeEvent(input$report_preview, {
      req(state$language())
      
      
      lang_map <- yaml::read_yaml(
        paste0("quarto/", state$language(), "/mapping.yml")
      )
      measure_mapping <- read.csv(
        paste0("quarto/", state$language(), "/measurement_dictionary.csv"),
        encoding = "UTF-8"
      )
      
      tr <- function(key) {
        lang_map[[key]] %||% key
      }
      
      selected_mapping <- measure_mapping %>%
        dplyr::filter(file_name %in% input$measurement_definitions)
      
      grouped_measures <- split(
        selected_mapping$file_name,
        selected_mapping$section_name
      )
      
      # Section color mapping
      section_colors <- data.frame(
        section_name = c(
          "Biological",
          "Physical",
          "Chemical"
        ),
        color = c(
          "#335c67",
          "#a60f2d",
          "#d4820a"
        ),
        stringsAsFactors = FALSE
      )
      
      # Create tab panels
      tabs <- lapply(names(grouped_measures), function(section_name) {
        #neutral translation to english
        type <- selected_mapping$type[
          selected_mapping$section_name == section_name
        ][1]
        image_path <- paste0("pictures/", tolower(type), ".png")
        section_color <- section_colors$color[
          section_colors$section_name == type
        ]
        
        tabPanel(
          title = tags$div(
            tags$img(
              src = image_path,
              style = "height:30px; padding-right:5px"
            ),
            tags$span(
              tags$b(tr(section_name)),
              style = glue::glue("color:{section_color}")
            )
          ),
          do.call(
            div,
            lapply(
              grouped_measures[[section_name]],
              function(qmd_file) {
                htmltools::includeMarkdown(
                  read_qmd_as_md(
                    paste0("quarto/", state$language(), "/", qmd_file)
                  )
                )
              }
            )
          )
        )
      })
      
      # Show modal with all sections
      showModal(modalDialog(
        title = "Preview Sections",
        div(
          id = "modal-preview",
          tags$h2(input$project_name),
          tags$h3(tr("project_summary")),
          HTML(markdown::markdownToHTML(
            text = input$project_summary,
            fragment.only = TRUE
          )),
          tags$h3(tr("what_we_measured_in_your_soil")),
          tabsetPanel(id = "dynamicTabs", !!!tabs),
          tags$h3(tr("project_results")),
          HTML(markdown::markdownToHTML(
            text = input$project_results,
            fragment.only = TRUE
          )),
          div(
            class = "alert alert-warning d-flex align-items-center",
            style = "margin:20px 0px",
            role = "alert",
            shiny::icon("triangle-exclamation", class = "me-2"),
            tags$span("Note: Tables and graphs are not shown in this preview.")
          ),
          tags$h3(tr("looking_forward")),
          HTML(markdown::markdownToHTML(
            text = input$looking_forward,
            fragment.only = TRUE
          ))
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