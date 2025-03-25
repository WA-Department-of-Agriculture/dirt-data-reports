mod_learn_more_ui <- function(id) {
  ns <- NS(id)
  tagList(
    create_hero("Learn More", "pictures/default-hero.png"),
    div(
      class = "content-container",
      div(class = "content",id = "content-area",
        #to modify content for Learn More please edit the markdown file
        includeMarkdown("www/content/learn_more.md")
      ),
      div(class = "toc-scroll",id = "toc-container",h5("FAQs"))
    )  
    )
}

mod_learn_more_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed
  })
}
