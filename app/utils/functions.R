library(htmltools)

create_hero <- function(title, image_url) {
  tags$div(
    style = paste0(
      "position: relative; ",
      "background-image: url('", image_url, "'); ",
      "background-size: cover; ",
      "background-position: center; ",
      "padding: 50px; ",
      "width: 100vw; ",  # Ensure full viewport width
      "height: auto;",   # Adjust the height to auto
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