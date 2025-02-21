library(tidyverse)
library(readxl)

library(tidyverse)

validate_uniqueness <- function(data, req_fields) {
  error_list <- list()
  
  unique_checks <- req_fields |> filter(unique_by != "-")
  
  for (i in seq_len(nrow(unique_checks))) {
    var_name <- unique_checks$var[i]          #
    # Split multiple vars by comma
    group_by_vars <- str_split(unique_checks$unique_by[i], ",\\s*")[[1]]  
    
    # Ensure all columns exist in the data
    if (var_name %in% colnames(data) && all(group_by_vars %in% colnames(data))) {
      
      if (length(group_by_vars) == 1 && group_by_vars == var_name) {
        # Case where var_name itself must be unique (e.g., sample_id is lobally unique)
        duplicates <- data %>%
          count(!!sym(var_name)) %>%
          filter(n > 1)
        
        if (nrow(duplicates) > 0) {
          error_list[[var_name]] <- paste(
            "Duplicate values found in", var_name, 
            "which should be unique:", paste(duplicates[[var_name]], collapse = ", ")
          )
        }
      } else {
        # Case where var_name must be unique within a grouping of multiple columns
        duplicates <- data %>%
          group_by(across(all_of(group_by_vars))) %>%
          summarise(unique_values = n_distinct(!!sym(var_name)), .groups = "drop") %>%
          filter(unique_values > 1)
        
        if (nrow(duplicates) > 0) {
          error_list[[var_name]] <- paste(
            "Duplicate values found in", var_name, 
            "within grouping of", paste(group_by_vars, collapse = ", "), 
            "for:", paste(duplicates[[group_by_vars[1]]], collapse = ", ")
          )
        }
      }
    }
  }
  
  return(error_list)
}


validate_data_file <- function(file, req_fields) {
  
  req_fields_data <- req_fields |> filter(sheet == "Data")
  req_fields_dd <- req_fields |> filter(sheet == "Data Dictionary")
  
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
  
  ## Check 4: Are required unique columns truly unique?
  if (check2) {
    unique_check<-validate_uniqueness(data, req_fields_data)
    if(length(unique_check)>0){
      error_list$check4<-unique_check
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
      filter(var %in% names(actual_types) & map_r_type(var_type) != actual_types[var]) %>%
      mutate(actual_type = actual_types[var])
    
    if (nrow(mismatched_types) > 0) {
      error_list$check6 <- paste(
        "Error with data types:",
        paste(
          mismatched_types$var, 
          "(expected:", mismatched_types$var_type, 
          ", found:", mismatched_types$actual_type, ")",
          collapse = "; "
        )
      )
    }
  }
  
  ### Check 7: Are there any missing values in required columns?
  required_value_columns <- req_fields_data |> filter(missing_allowed == "FALSE") |> pull(var)
  
  if (check2) {
    missing_values <- data %>%
      select(all_of(required_value_columns)) %>%
      summarise(across(everything(), ~ sum(is.na(.)), .names = "missing_{.col}"))
    
    missing_cols <- names(missing_values)[colSums(missing_values) > 0]
    
    if (length(missing_cols) > 0) {
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
