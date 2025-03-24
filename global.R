# Load packages
library(shiny)
library(shinyWidgets)
library(shinyAce)
library(shinyjs)
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

# Source modules
module_files <- list.files("modules", full.names = TRUE)
invisible(lapply(module_files, source))

# Source helpers
helper_files <- list.files("utils", full.names = TRUE)
invisible(lapply(helper_files, source))

# Register JS/CSS paths
addResourcePath("www", "www")
