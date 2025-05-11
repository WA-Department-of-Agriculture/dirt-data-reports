library(htmltools)


read_qmd_as_md <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  
  # Convert to a single string with proper line breaks
  content <- paste(lines, collapse = "\n")
  
  # ✅ Remove Quarto-specific div markers
  content <- str_remove_all(content, "(?s)::: \\{\\.content-visible unless-format=\"html\"\\}.*?:::")
  
  # Remove attributes inside `{}` (like `{width="5.8in" fig-alt="..."}`)
  content <- str_replace_all(content, "\\{[^}]+\\}", "")
  
  # Remove Quarto's ::: markers
  content <- str_replace_all(content, ":::", "")
  
  # Remove HTML comments
  content <- str_replace_all(content, "<!--.*?-->", "")
  
  # Convert superscripts (e.g., `NH^~4~+^` → `NH<sup>4+</sup>`)
  content <- str_replace_all(content, "\\^([0-9+-]+)\\^", "<sup>\\1</sup>")
  
  # Ensure image links remain properly formatted with a new line before them
  content <- str_replace_all(content, "!\\[(.*?)\\]\\((.*?)\\)", "\n![](\\2)\n")
  
  # Remove extra spaces introduced during cleaning
  content <- str_replace_all(content, "\\s+\n", "\n")  # Trim spaces before new lines
  content <- str_replace_all(content, "\n{2,}", "\n\n")  # Ensure at most one blank line
  
  return(content)
}




create_hero <- function(title, image_url) {
  tags$div(
    style = paste0(
      "position: relative; ",
      "background-image: url('",
      image_url,
      "'); ",
      "background-size: cover; ",
      "background-position: center; ",
      "padding: 50px; ",
      "width: 100%; ",
      # Ensure full viewport width
      "height: auto;",
      # Adjust the height to auto
      "box-sizing: border-box;"  # Ensure padding doesn't affect width
    ),
    # Gradient Overlay
    tags$div(
      style = paste0(
        "position: absolute; ",
        "top: 0; left: 0; right: 0; bottom: 0; ",
        "background-color: rgba(0, 0, 0, 0.6); ",
        "mix-blend-mode: multiply;"
      )
    ),
    # Title
    tags$h1(
      title,
      style = paste0(
        "position: relative; ",
        "z-index: 10; ",
        "font-size: 4rem; ",
        "font-weight: bold; ",
        "color: white; ",
        "text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.7);"
      )
    )
  )
}
customButtonInput <-
  function(inputId,
           choices,
           multi = FALSE,
           selected = NULL,
           icons = NULL) {
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
        active_class <- if (value %in% selected)
          "active"
        else
          ""
        icon_tag <- if (!is.null(icons) && label %in% names(icons)) {
          tags$i(style = 'font-size:32px; margin-bottom:10px;', class = icons[[label]])
        } else {
          NULL
        }
        tags$button(
          type = "button",
          class = paste("custom-button", active_class),
          `data-value` = value,
          icon_tag,
          tags$span(label)
        )
      })
    )
  }

show_modal <- function(title, id, md) {
  showModal(
    modalDialog(
      title = title,
      tags$div(
        id = id,
        includeMarkdown(normalizePath(paste0("www/content/", md, ".md"))),
      ),
      easyClose = TRUE,
      footer = NULL
    )
  )
}


#Taken from Tan Ho to get user timezone: https://github.com/tanho63/tantastic/blob/main/R/shiny_timezone.R
use_client_tz <- function(inputId = "_client_tz"){
  shiny::tagList(
    shiny::tags$input(type = "text", id = inputId, style = "display: none;"),
    shiny::tags$script(
      paste0('
      $(function() {
        var time_now = new Intl.DateTimeFormat().resolvedOptions().timeZone
        $("input#', inputId, '").val(time_now)
      });
    ')
    )
  )
}

#Taken from Tan Ho to get user timezone: https://github.com/tanho63/tantastic/blob/main/R/shiny_timezone.R
get_client_tz <- function(inputId = "_client_tz", session = shiny::getDefaultReactiveDomain()) {
  tz <- shiny::isolate(session$input[[inputId]])
  return(tz)
}