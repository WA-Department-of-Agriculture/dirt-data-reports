library(tidyverse)
library(readxl)

validate_uniqueness <- function(data, req_fields) {
  error_list <- list()

  unique_checks <- req_fields |> filter(unique_by != "-")

  for (i in seq_len(nrow(unique_checks))) {
    var_name <- unique_checks$var[i]

    # Improved parsing to handle R syntax: c("var1", "var2") and simple comma-separated: var1, var2
    group_by_vars <- if (str_detect(unique_checks$unique_by[i], "^c\\(")) {
      # Handle R syntax: c("var1", "var2")
      str_extract_all(unique_checks$unique_by[i], '"([^"]+)"')[[1]] %>%
        str_remove_all('"')
    } else {
      # Handle simple comma-separated: var1, var2
      str_split(unique_checks$unique_by[i], ",\\s*")[[1]]
    }

    # Ensure all columns exist in the data
    if (var_name %in% colnames(data) &&
      all(group_by_vars %in% colnames(data))) {
      if (length(group_by_vars) == 1 && group_by_vars == var_name) {
        # Case where var_name itself must be unique (e.g., sample_id is globally unique)
        duplicates <- data %>%
          count(!!sym(var_name)) %>%
          filter(n > 1)

        if (nrow(duplicates) > 0) {
          error_list[[var_name]] <- paste(
            "Duplicate values found in",
            var_name,
            "which should be unique:",
            paste(duplicates[[var_name]], collapse = ", ")
          )
        }
      } else {
        # Case where var_name must be unique within a grouping of multiple columns
        # Check for actual duplicates within each group
        duplicates <- data %>%
          group_by(across(all_of(group_by_vars))) %>%
          add_count(!!sym(var_name), name = "field_count") %>%
          filter(field_count > 1) %>%
          distinct(across(all_of(c(group_by_vars, var_name)))) %>%
          ungroup()

        if (nrow(duplicates) > 0) {
          # Create a readable summary of the groups with duplicates
          dup_summary <- duplicates %>%
            group_by(across(all_of(group_by_vars))) %>%
            summarise(duplicate_values = paste(unique(!!sym(var_name)), collapse = ", "), .groups = "drop")

          error_list[[var_name]] <- paste(
            "Duplicate values found in",
            var_name,
            "within grouping of",
            paste(group_by_vars, collapse = ", "),
            ". Affected groups:",
            paste(apply(dup_summary, 1, function(row) {
              paste(
                "(",
                paste(group_by_vars, "=", row[group_by_vars], collapse = ", "),
                ") has duplicate",
                var_name,
                "values:",
                row[["duplicate_values"]]
              )
            }), collapse = "; ")
          )
        }
      }
    }
  }

  return(error_list)
}

validate_measurement_groups <- function(data_dict, language) {
  # Named list of valid measurement groups by language
  measurement_groups <- list(
    english = c(
      "Physical",
      "Biological",
      "Chemical",
      "Plant Essential Macro Nutrients",
      "Plant Essential Micro Nutrients"
    ),
    spanish = c(
      "Mediciones físicas",
      "Mediciones biológicas",
      "Mediciones químicas",
      "Macronutrientes esenciales para plantas",
      "Micronutriente es esenciales para plantas"
    )
  )

  # Normalize language key (just in case)
  language <- tolower(language)

  if (!language %in% names(measurement_groups)) {
    warning(paste("No measurement groups defined for language:", language))
    return(list())
  }

  valid_groups <- enc2native(measurement_groups[[language]])

  if (!"measurement_group" %in% colnames(data_dict)) {
    return(list(measurement_groups = "Missing 'measurement_group' column in Data Dictionary"))
  }

  actual_groups <- data_dict$measurement_group[!is.na(data_dict$measurement_group)]
  actual_groups <- enc2native(actual_groups)

  invalid_groups <- setdiff(actual_groups, valid_groups)

  if (length(invalid_groups) > 0) {
    error_msg <- paste(
      "Invalid measurement_group values found in Data Dictionary:",
      paste(invalid_groups, collapse = ", "),
      ". Valid options for",
      str_to_title(language),
      "are:",
      paste(valid_groups, collapse = ", ")
    )
    return(list(measurement_groups = error_msg))
  }

  return(list())
}

check_raw_duplicate_headers <- function(file) {
  duplicate_info <- list(
    data_duplicates = character(0),
    dict_duplicates = character(0),
    has_duplicates = FALSE
  )

  # Check Data sheet headers
  tryCatch(
    {
      data_headers <- read_xlsx(file, sheet = "Data", col_names = FALSE, n_max = 1)
      data_headers <- as.character(data_headers[1, ])
      data_headers <- data_headers[!is.na(data_headers)] # Remove NA headers

      data_dups <- data_headers[duplicated(data_headers)]
      if (length(data_dups) > 0) {
        duplicate_info$data_duplicates <- unique(data_dups)
        duplicate_info$has_duplicates <- TRUE
      }
    },
    error = function(e) {
      # If can't read, we'll catch this later in main validation
    }
  )

  # Check Data Dictionary sheet headers
  tryCatch(
    {
      dict_headers <- read_xlsx(file, sheet = "Data Dictionary", col_names = FALSE, n_max = 1)
      dict_headers <- as.character(dict_headers[1, ])
      dict_headers <- dict_headers[!is.na(dict_headers)] # Remove NA headers

      dict_dups <- dict_headers[duplicated(dict_headers)]
      if (length(dict_dups) > 0) {
        duplicate_info$dict_duplicates <- unique(dict_dups)
        duplicate_info$has_duplicates <- TRUE
      }
    },
    error = function(e) {
      # If can't read, we'll catch this later in main validation
    }
  )

  return(duplicate_info)
}

validate_data_file <- function(file, req_fields, language = "english") {
  req_fields_data <- req_fields |> filter(sheet == "Data")
  req_fields_dd <- req_fields |> filter(sheet == "Data Dictionary")

  error_list <- list()

  ### Check 1: Does the xlsx file have 'Data' and 'Data Dictionary' tabs?
  sheets_present <- excel_sheets(file)
  required_sheets <- c("Data", "Data Dictionary")
  check1 <- all(required_sheets %in% sheets_present)

  if (!check1) {
    error_list$check1 <-
      paste("Missing sheets:", paste(setdiff(required_sheets, sheets_present), collapse = ", "))
    return(error_list) # Critical failure, stop further checks
  }

  ### Check 2: Check for duplicate column headers in raw Excel file
  duplicate_info <- check_raw_duplicate_headers(file)
  duplicated_columns <- character(0) # Track which columns have duplicates for later checks

  if (duplicate_info$has_duplicates) {
    dup_errors <- list()

    if (length(duplicate_info$data_duplicates) > 0) {
      dup_errors$duplicate_data_headers <- paste(
        "Duplicate column headers found in Data sheet:",
        paste(duplicate_info$data_duplicates, collapse = ", ")
      )
      duplicated_columns <- c(duplicated_columns, duplicate_info$data_duplicates)
    }

    if (length(duplicate_info$dict_duplicates) > 0) {
      dup_errors$duplicate_dict_headers <- paste(
        "Duplicate column headers found in Data Dictionary sheet:",
        paste(duplicate_info$dict_duplicates, collapse = ", ")
      )
    }

    error_list$check2 <- dup_errors
    return(error_list) # Critical failure, stop further checks
  }

  # Load the sheets (readxl will auto-fix duplicate names)
  data <- tryCatch(
    read_excel(file, sheet = "Data"),
    error = function(e) {
      error_list$check1 <- paste("Error reading Data sheet:", e$message)
      return(NULL)
    }
  )
  data_dict <- tryCatch(
    read_excel(file, sheet = "Data Dictionary"),
    error = function(e) {
      error_list$check1 <-
        paste("Error reading Data Dictionary sheet:", e$message)
      return(NULL)
    }
  )

  if (is.null(data) || is.null(data_dict)) {
    return(error_list) # Stop further validation if sheets couldn't be loaded
  }

  ### Check 2.5: Does Data sheet have actual data rows?
  if (nrow(data) == 0) {
    error_list$check2_5 <- "The Data sheet contains headers but no data rows. Please add your measurement data."
    return(error_list) # Stop validation if no data to validate
  }

  ### Check 3: Does 'Data' have required columns?
  required_columns <- req_fields_data$var
  # Only check for required columns that don't have duplicates
  required_columns_to_check <- setdiff(required_columns, duplicated_columns)

  check3 <- all(required_columns_to_check %in% colnames(data))

  if (!check3) {
    missing_cols <- setdiff(required_columns_to_check, colnames(data))
    error_list$check3 <-
      paste("Missing columns in Data:", paste(missing_cols, collapse = ", "))
  }

  # Check if any required columns were duplicated (separate error)
  duplicated_required <- intersect(required_columns, duplicated_columns)
  if (length(duplicated_required) > 0) {
    if (is.null(error_list$check3)) error_list$check3 <- list()
    error_list$check3$duplicated_required <- paste(
      "Required columns have duplicate headers (fix duplicates before proceeding):",
      paste(duplicated_required, collapse = ", ")
    )
  }

  ### Check 4: Does 'Data Dictionary' have required fields?
  required_dict_fields <- req_fields_dd$var
  check4 <- all(required_dict_fields %in% colnames(data_dict))

  if (!check4) {
    error_list$check4 <-
      paste(
        "Missing fields in Data Dictionary:",
        paste(
          setdiff(
            required_dict_fields,
            colnames(data_dict)
          ),
          collapse = ", "
        )
      )
  }

  ## Check 5: Are required unique columns truly unique?
  # Only check uniqueness for columns that exist and don't have header duplicates
  available_req_fields <- req_fields_data %>%
    filter(var %in% colnames(data)) %>% # Only check columns that exist
    filter(!var %in% duplicated_columns)

  if (nrow(available_req_fields) > 0) {
    unique_check <- validate_uniqueness(data, available_req_fields)
    if (length(unique_check) > 0) {
      error_list$check5 <- unique_check
    }
  }

  ### Check 6: Does 'Data' have at least one additional column? (Moved before Check 9)
  if (length(colnames(data)) > 0) { # If we have any columns
    additional_columns <- setdiff(colnames(data), required_columns)
    if (length(additional_columns) < 1) {
      error_list$check6 <-
        "The Data sheet must have at least one additional column beyond the required fields."
    }
  }

  ### Check 7: Are all required columns the right data type?
  # Only check data types for columns that exist and don't have header duplicates
  available_req_fields_for_types <- req_fields_data %>%
    filter(var %in% colnames(data)) %>% # Only check columns that exist
    filter(!var %in% duplicated_columns)

  if (nrow(available_req_fields_for_types) > 0) {
    map_r_type <- function(data_type) {
      case_when(
        data_type == "int" ~ "integer",
        data_type == "double" ~ "double",
        data_type == "char" ~ "character",
        data_type == "-" ~ "any",
        TRUE ~ "unknown"
      )
    }

    # skip check of data type if ALL records are blank for column, gets interpreted as logical type (default)
    non_blank_vars <- sapply(data[available_req_fields_for_types$var], function(col) !all(is.na(col)))

    if (any(non_blank_vars)) {
      actual_types <- sapply(data[, names(non_blank_vars)[non_blank_vars], drop = FALSE], typeof)

      mismatched_types <- available_req_fields_for_types %>%
        filter(var_type != "-") %>%
        filter(var %in% names(actual_types)) %>%
        filter(map_r_type(var_type) != actual_types[var]) %>%
        mutate(actual_type = actual_types[var])

      if (nrow(mismatched_types) > 0) {
        error_list$check7 <- paste(
          "Error with data types:",
          paste(
            mismatched_types$var,
            "(expected:",
            mismatched_types$var_type,
            ", found:",
            mismatched_types$actual_type,
            ")",
            collapse = "; "
          )
        )
      }
    }
  }

  ### Check 8: Are there any missing values in required columns?
  # Only check missing values for columns that exist and don't have header duplicates
  required_value_columns <-
    req_fields_data |>
    filter(missing_allowed == "FALSE") |>
    filter(var %in% colnames(data)) |> # Only check columns that exist
    filter(!var %in% duplicated_columns) |> # Skip duplicated columns
    pull(var)

  if (length(required_value_columns) > 0) {
    missing_values <- data %>%
      select(all_of(required_value_columns)) %>%
      summarise(across(everything(), ~ sum(is.na(.)), .names = "{.col}"))

    missing_cols <-
      names(missing_values)[colSums(missing_values) > 0]

    if (length(missing_cols) > 0) {
      error_list$check8 <-
        paste(
          "Missing values found in columns:",
          paste(missing_cols, collapse = ", ")
        )
    }
  }

  ### Check 9: Do additional columns in 'Data' match values in 'Data Dictionary'? (Moved after Check 6)
  if (check4 && length(colnames(data)) > 0) { # If dictionary is valid and we have data columns
    additional_columns <- setdiff(colnames(data), required_columns)
    all_data_columns <- colnames(data)
    dict_column_names <- data_dict$column_name

    # Check 1: Additional columns should be documented in Data Dictionary
    missing_in_dict <- setdiff(additional_columns, dict_column_names)

    # Check 2: Data Dictionary entries should correspond to actual columns (required or additional)
    missing_in_data <- setdiff(dict_column_names, all_data_columns)

    if (length(missing_in_dict) > 0 ||
      length(missing_in_data) > 0) {
      error_messages <- c()

      if (length(missing_in_dict) > 0) {
        error_messages <- c(
          error_messages,
          paste(
            "Additional columns in Data not documented in Data Dictionary:",
            paste(missing_in_dict, collapse = ", ")
          )
        )
      }

      if (length(missing_in_data) > 0) {
        error_messages <- c(
          error_messages,
          paste(
            "Columns in Data Dictionary not found in Data:",
            paste(missing_in_data, collapse = ", ")
          )
        )
      }

      error_list$check9 <- paste(error_messages, collapse = " ")
    }
  }

  ### Check 10: Validate measurement groups for the selected language
  if (check4) {
    measurement_group_check <- validate_measurement_groups(data_dict, language)
    if (length(measurement_group_check) > 0) {
      error_list$check10 <- measurement_group_check
    }
  }

  return(error_list)
}
