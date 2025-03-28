# Load packages
library(shiny)
library(shinyWidgets)
library(bslib)
library(shinyAce)
library(shinyjs)
library(shinyalert)
library(sever)
library(soils)
library(systemfonts)
library(readxl)
library(zip)
library(tidyverse)
library(maptiles)
library(tidyterra)
library(ggrepel)
library(gt)
library(downloadthis)
library(rmarkdown)
library(glue)
library(writexl)

#for shinyapps.io deployment, make sure soils package is included (not on CRAN)
options(repos = c(
  wa = "https://wa-department-of-agriculture.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

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
