# Load packages
library(bslib)
library(downloadthis)
library(dplyr)
library(flextable)
library(ggrepel)
library(glue)
library(gt)
library(knitr)
library(maptiles)
library(purrr)
library(quarto)
library(readxl)
library(rlang)
library(rmarkdown)
library(sever)
library(shiny)
library(shinyAce)
library(shinyalert)
library(shinybusy)
library(shinyjs)
library(shinyWidgets)
library(soils)
library(stringr)
library(systemfonts)
library(tidyr)
library(tidyterra)
library(writexl)
library(zip)

#for shinyapps.io deployment, make sure soils package is included (not on CRAN)
options(
  repos = c(
    wa = "https://wa-department-of-agriculture.r-universe.dev",
    CRAN = "https://cloud.r-project.org"
  )
)

# if (!requireNamespace("soils", quietly = TRUE)) {
#   remotes::install_github("WA-Department-of-Agriculture/soils")
# }

# Source modules
module_files <- list.files("modules", full.names = TRUE)
invisible(lapply(module_files, source))

# Source helpers
helper_files <- list.files("utils", full.names = TRUE)
invisible(lapply(helper_files, source))

# Register JS/CSS paths
addResourcePath("www", "www")
