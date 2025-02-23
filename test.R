library(dplyr)
library(readxl)
library(tidyr)
library(purrr)

selectedYear <- 2022
selectedProducer <- 'BOA05'
selectedFormat <- c('html', 'docx')
selectedMeasures <- c("def-texture.qmd", "def-bulk-density.qmd", "def-soil-ph.qmd", "def-total-nitro.qmd")

test <- read_xlsx("app/files/template.xlsx", sheet = "Data") |>
  distinct(year, producer_id) |>
  filter(year %in% selectedYear & producer_id %in% selectedProducer) |>
  mutate(
    output_file = paste0(year, "_", producer_id),
    output_format = paste0(selectedFormat, collapse = ","),
    execute_params = pmap(
      list(year, producer_id),
      ~ list(year = ..1, producer_id = ..2, measures = selectedMeasures)
    )
  ) |>
  select(output_file, output_format, execute_params) |>
  separate_longer_delim(output_format, delim = ",") |>
  mutate(
    output_file = paste0(output_file, ".", output_format)
  )

# Checking the first execute_params
test

req_fields_data <- req_fields |> filter(sheet == "Data")


install.packages(
  "soils",
  repos = c("https://wa-department-of-agriculture.r-universe.dev")
)
