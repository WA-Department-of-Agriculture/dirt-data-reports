library(cli)
library(dplyr)
library(stringr)
library(rlang)
library(readxl)

source("utils/data_validation.R")

#file_path <- "files/template.xlsx"
file_path<-"files/test_missing_dict.xlsx"
req_fields <- read.csv("files/required-fields.csv")
req_fields_data <- req_fields |> filter(sheet == "Data")
req_fields_dd   <- req_fields |> filter(sheet == "Data Dictionary")

# Test Gate Function

cli_h1("Test 1: Gate check")

check_file_readable(file_path, output = "cli")
check_file_readable(file_path, output = "ui")

# ============================================================================
# Test 2: All independent checks
# ============================================================================

cli_h1("Test 2: All checks")

data <- gate_result$data
data_dict <- gate_result$data_dict

all_issues <- c(
  check_required_columns(data, req_fields_data, output = "ui"),
  check_required_dict_fields(data_dict, req_fields_dd, output = "ui"),
  check_uniqueness(data, req_fields_data, output = "ui"),
  check_data_types(data, req_fields_data, output = "ui"),
  check_missing_values(data, req_fields_data, output = "ui"),
  check_additional_columns(data, req_fields_data, output = "ui"),
  check_percent_range(data, output = "ui"),
  check_dict_mismatch(data, data_dict, req_fields_data, output = "ui"),
  check_measurement_groups(data_dict, output = "ui")
)

results <- split_issues(all_issues)

if (length(all_issues) == 0) {
  cli_alert_success("All checks passed!")
} else {
  if (length(results$errors) > 0) {
    cli_h2("Errors ({length(results$errors)})")
    for (e in results$errors) cat("  \u2022", e$message, "\n")
  }
  if (length(results$warnings) > 0) {
    cli_h2("Warnings ({length(results$warnings)})")
    for (w in results$warnings) cat("  \u2022", w$message, "\n")
  }
}

cat("\nSummary:", length(results$errors), "errors,",
    length(results$warnings), "warnings\n")
cat("Would block progression:", length(results$errors) > 0, "\n")


cli_h1("CLI Output")


cli_h2("Error checks")

tryCatch(
  check_required_columns(data, req_fields_data),
  error = function(e) message(e$message)
)

tryCatch(
  check_uniqueness(data, req_fields_data),
  error = function(e) message(e$message)
)

tryCatch(
  check_missing_values(data, req_fields_data),
  error = function(e) message(e$message)
)

cli_h2("Warning checks")

tryCatch(
  check_percent_range(data),
  warning = function(w) message(w$message)
)

tryCatch(
  check_dict_mismatch(data, data_dict, req_fields_data),
  warning = function(w) message(w$message)
)

tryCatch(
  check_measurement_groups(data_dict),
  warning = function(w) message(w$message)
)



cli_h1("UI Output")

# Collect all issues from all checks
all_issues <- c(
  check_required_columns(data, req_fields_data, output = "ui"),
  check_uniqueness(data, req_fields_data, output = "ui"),
  check_missing_values(data, req_fields_data, output = "ui"),
  check_additional_columns(data, req_fields_data, output = "ui"),
  check_percent_range(data, output = "ui"),
  check_dict_mismatch(data, data_dict, req_fields_data, output = "ui"),
  check_measurement_groups(data_dict, output = "ui")
)

# Split into two lists
results <- split_issues(all_issues)

cli_h2("Errors card (red in UI)")
if (length(results$errors) > 0) {
  for (e in results$errors) cat("  \u2022", e$message, "\n")
} else {
  cat("  No errors.\n")
}

cli_h2("Warnings card (yellow in UI)")
if (length(results$warnings) > 0) {
  for (w in results$warnings) cat("  \u2022", w$message, "\n")
} else {
  cat("  No warnings.\n")
}



cli_h1("Summary")
cat("Total issues:", length(all_issues), "\n")
cat("Errors:", length(results$errors), "\n")
cat("Warnings:", length(results$warnings), "\n")
cat("Would block progression:", length(results$errors) > 0, "\n")
