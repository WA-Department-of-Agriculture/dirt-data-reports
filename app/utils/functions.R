library(htmltools)

create_hero <- function(title, image_url) {
  tags$div(
    style = paste0(
      "position: relative; ",
      "background-image: url('", image_url, "'); ",
      "background-size: cover; ",
      "background-position: center; ",
      "padding: 4rem 4rem; ",
      "width: 100vw; ",  # Ensure full viewport width
      "height: auto;",   # Adjust the height to auto
      "margin-bottom: 6rem; ",  # Add margin at the bottom
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


create_stepper <- function(steps) {
  steplist <- lapply(1:length(steps), function(i) {
    # Check if it's the last step and assign class accordingly
    step_class <- if (i == length(steps)) 'step-part-l' else 'step-part'
    
    tags$div(
      class = step_class,
      tags$button(
        id = paste0('step', i), 
        class = paste('step-button', if (i == 1) 'active' else ''),
        tags$span(icon(steps[[i]]$icon)), 
        onclick = paste0("activateSteps(", i, ")")
      ),
      if (i < length(steps)) tags$div(class = 'step-divider') else NULL
    )
  })
  
  tags$div(class = 'steplist', steplist)
}


create_slides <- function(slides_content) {
  slides <- lapply(1:length(slides_content), function(i) {
    slide_class <- if (i == 1) 'slide active-slide' else 'slide'
    
    tags$div(
      id = paste0('slide', i),
      class = slide_class,
      tags$div(
        class = 'slide-container',
        tags$h3(class = 'slide-title', slides_content[[i]]$title),
        tags$div(class = 'slide-content', slides_content[[i]]$content)
      ),
      tags$div(
        class = 'slider-buttons',
        if (i > 1) 
          tags$button(
            id = paste0('prev', i), 
            class = 'prev-button', 
            "Previous", 
            onclick = paste0("activateSteps(", i - 1, ")")
          ),
        if (i < length(slides_content)) 
          tags$button(
            id = paste0('next', i), 
            class = 'next-button', 
            "Next", 
            onclick = paste0("nextSlide(", i + 1, ")")
          )
      )
    )
  })
  
  tags$div(class = 'slides', slides)
}


