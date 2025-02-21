library(tidyverse)
library(readxl)

validate_data_file <- function(file, req_fields) {
  
  req_fields_data<-req_fields|>filter(sheet=="Data")
  req_fields_dd<-req_fields|>filter(sheet=="Data Dictionary")
  
  
  
  error_list <- list()
  
  ### Check 1: Does the xlsx file have 'Data' and 'Data Dictionary' tabs?
  sheets_present <- excel_sheets(file)
  required_sheets <- c("Data", "Data Dictionary")
  check1 <- all(required_sheets %in% sheets_present)
  
  if (!check1) {
    error_list$check1 <- paste("Missing sheets:", paste(setdiff(required_sheets, sheets_present), collapse = ", "))
    return(error_list) # Critical failure, stop further checks
  }
  
  # Load the sheets
  data <- tryCatch(
    read_excel(file, sheet = "Data"),
    error = function(e) {
      error_list$check1 <- paste("Error reading 'Data' sheet:", e$message)
      return(NULL)
    }
  )
  data_dict <- tryCatch(
    read_excel(file, sheet = "Data Dictionary"),
    error = function(e) {
      error_list$check1 <- paste("Error reading 'Data Dictionary' sheet:", e$message)
      return(NULL)
    }
  )
  
  if (is.null(data) || is.null(data_dict)) {
    return(error_list) # Stop further validation if sheets couldn't be loaded
  }
  
  ### Check 2: Does 'Data' have required columns?
  required_columns <- req_fields_data$var
  check2 <- all(required_columns %in% colnames(data))
  
  if (!check2) {
    error_list$check2 <- paste("Missing columns in 'Data':", paste(setdiff(required_columns, colnames(data)), collapse = ", "))
  }
  
  ### Check 3: Does 'Data Dictionary' have required fields?
  required_dict_fields <- req_fields_dd$var
  check3 <- all(required_dict_fields %in% colnames(data_dict))
  
  if (!check3) {
    error_list$check3 <- paste("Missing fields in 'Data Dictionary':", paste(setdiff(required_dict_fields, colnames(data_dict)), collapse = ", "))
  }
  
  ### Check 4: Are 'sample_id' values unique?
  if (check2) {
    if (!"sample_id" %in% required_columns) {
      error_list$check4 <- "The 'sample_id' column is missing from the required fields and must be included."
    } else {
      duplicate_sample_ids <- data %>%
        count(sample_id) %>%
        filter(n > 1)
      
      if (nrow(duplicate_sample_ids) > 0) {
        error_list$check4 <- paste("Duplicate 'sample_id' values found:", paste(duplicate_sample_ids$sample_id, collapse = ", "))
      }
    }
  }
  
  ### Check 5: Does 'Data' have at least one additional column?
  if (check2) {
    additional_columns <- setdiff(colnames(data), required_columns)
    if (length(additional_columns) < 1) {
      error_list$check5 <- "The 'Data' sheet must have at least one additional column beyond the required fields."
    }
  }
  
  ### Check 6: Are all required columns the right data type?
  if (check2) {
    map_r_type <- function(data_type) {
      case_when(
        data_type == "int" ~ "integer",
        data_type == "double" ~ "double",
        data_type == "char" ~ "character",
        data_type == "-" ~ "any",
        TRUE ~ "unknown"
      )
    }
    
    actual_types <- sapply(data, typeof)
    expected_types <- set_names(map_r_type(req_fields_data$var_type), req_fields_data$var)
    
    mismatched_types <- req_fields_data %>%
      filter(var_type != "-") %>%
      filter(var %in% names(actual_types) & map_r_type(var_type) != actual_types[var])
    
    if (nrow(mismatched_types) > 0) {
      error_list$check6 <- paste("Mismatched column types:", paste(mismatched_types$var, collapse = ", "))
    }
  }
  
  ### Check 7: Are there any missing values in any of the records?
  if (check2) {
    missing_values <- data %>%
      select(all_of(required_columns)) %>%
      summarise(across(everything(), ~ sum(is.na(.))))
    
    if (any(missing_values > 0)) {
      missing_cols <- names(missing_values)[missing_values > 0]
      error_list$check7 <- paste("Missing values found in columns:", paste(missing_cols, collapse = ", "))
    }
  }
  
  ### Check 8: Do additional columns in 'Data' match values in 'Data Dictionary'?
  if (check2 && check3) {
    additional_columns <- setdiff(colnames(data), required_columns)
    additional_columns <- c("texture", additional_columns)
    dict_column_names <- data_dict$column_name
    missing_in_dict <- setdiff(additional_columns, dict_column_names)
    missing_in_data <- setdiff(dict_column_names, additional_columns)
    
    if (length(missing_in_dict) > 0 || length(missing_in_data) > 0) {
      error_list$check8 <- paste(
        if (length(missing_in_dict) > 0) paste("Columns in 'Data' not found in 'Data Dictionary':", paste(missing_in_dict, collapse = ", ")) else NULL,
        if (length(missing_in_data) > 0) paste("Columns in 'Data Dictionary' not found in 'Data':", paste(missing_in_data, collapse = ", ")) else NULL,
        sep = " "
      )
    }
  }
  
  return(error_list)
}

#validate_data_file("soil-sample-7.xlsx", req_fields)
