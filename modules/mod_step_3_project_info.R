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
    state$project_info_vals$project_results_val %||% "Below are tables and graphs describing the measurements from your soils. Each point represents a sample we collected. Take a look to see how your fields compare to others in the project. All samples were collected from **[EDIT: SOIL DEPTH (e.g. 0-6 inches, or 0-30 cm)]**."
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
      "for full examples of the reports."
    ),
    actionLink(
      inputId = ns("customize"),
      label = tags$span(
        tags$b("Optional"),
        ": Learn how to further customize your text and reports."
      ),
      icon = icon("circle-info")
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
    tags$label("Measurement Definitions"),
    p(
      class = "form-text",
      "Selected definitions will be included in the 'What We Measured in Your Soil' section. Measurements are pre-selected based on the",
      tags$b("abbr"),
      "column in your uploaded",
      tags$b("Data Dictionary"),
      "tab but should be reviewed as we may call these measurements something different than your abbreviation.",
      "To remove measurements from the tables and plots in the 'Project Results' section, remove them from both the",
      tags$b("Data"),
      "and",
      tags$b("Data Dictionary"),
      "tabs of your spreadsheet and re-upload in Step 2."
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
          "Chemical",
          "Biológico",
          "Físico",
          "Químico"
        ),
        color = c(
          "#335c67",
          "#a60f2d",
          "#d4820a",
          "#335c67",
          "#a60f2d",
          "#d4820a"
        ),
        stringsAsFactors = FALSE
      )

      # Create tab panels
      tabs <- lapply(names(grouped_measures), function(section_name) {
        image <- selected_mapping$type[
          selected_mapping$section_name == section_name
        ][1]
        image_path <- paste0("pictures/", tolower(image), ".png")
        section_color <- section_colors$color[
          section_colors$section_name == section_name
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
          includeMarkdown("<span style='color:crimson'>**Note:** Tables and graphs are not shown in this preview.</span>"),
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
