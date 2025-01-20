# WSDA Soil Health Report Generator App

This Shiny app, developed for the Washington State Department of Agriculture (WSDA), facilitates the generation of soil health reports. Users can interactively upload data, validate the uploaded content, configure report parameters, and generate reports in their preferred format.

The application can be accesses here: [App](https://tshapiro.shinyapps.io/soil-health/)

------------------------------------------------------------------------

## Features

-   **Interactive Navigation**: A step-based interface guides users through the process of downloading templates, uploading data, configuring parameters, and generating reports.
-   **Data Validation**: Ensures that uploaded data meets the required standards, providing detailed feedback on errors.
-   **Dynamic Inputs**: Updates available options for parameters like `year` and `producer_id` based on uploaded data.
-   **Report Generation**: Allows users to generate reports in multiple formats (e.g., HTML, Word).

------------------------------------------------------------------------

## Application Structure

### 1. **User Interface (UI)**

The app employs a `navbarPage` layout with the following tabs:

-   **Home**: Provides an introduction to the app and quick navigation buttons.

-   **Learn More**: Displays a markdown-based FAQ and additional information.

-   **Generate Reports**: The core functionality of the app with a step-by-step process.

### 2. **Server Logic**

The server script manages data processing, validation, user interactions, and report generation.

------------------------------------------------------------------------

## Step-by-Step Workflow

### **Step 1: Download Template**

-   Users select their preferred language and download a preformatted Excel template (`template.xlsx` or `template_esp.xlsx`).

### **Step 2: Upload Data**

-   Users upload their completed template.
-   **Validation**:
    -   The uploaded file is validated using the `validate_data_file` function.
    -   Errors (if any) are displayed as a bulleted list, and subsequent steps are disabled until all issues are resolved.
-   **Outputs**:
    -   On successful validation, dynamic inputs for `year` and `producer_id` are updated.

### **Step 3: Configure Report Parameters**

-   Users select the following:
    -   **Year**: Populated based on data in the uploaded file.
    -   **Producer IDs**: Users can select up to 5 IDs for batch report generation.

### **Step 4: Generate Report**

-   Users confirm their preferred output format (HTML or Word) and generate a ZIP file containing the reports.
-   Reports are processed using `quarto_render`, and a progress bar is displayed during generation.

------------------------------------------------------------------------

## **Data Validation**

### **1. Check for Required Sheets**

-   **Purpose**: Ensures the file contains two mandatory sheets: "Data" and "Data Dictionary."\
-   **Failure**: If either sheet is missing, the function stops further checks and returns an error.

### **2. Check for Required Columns in "Data"**

-   **Purpose**: Validates that all required fields in `req_fields` exist in the "Data" sheet.\
-   **Failure**: Missing columns are listed in the error message.

### **3. Check for Required Fields in "Data Dictionary"**

-   **Purpose**: Ensures the "Data Dictionary" sheet contains the fields: `measurement_group`, `measurement_group_label`, `column_name`, `abbr`, and `unit`.\
-   **Failure**: Missing fields are reported.

### **4. Check for Unique `sample_id` Values**

-   **Purpose**: Ensures the `sample_id` column (if present) contains unique values.\
-   **Failure**: Duplicate values are listed in the error message.

### **5. Check for Additional Columns in "Data"**

-   **Purpose**: Ensures that the "Data" sheet has at least one additional column beyond the required fields.\
-   **Failure**: Returns an error if no additional columns exist.

### **6. Validate Data Types of Required Columns**

-   **Purpose**: Compares the actual data types in the "Data" sheet with the expected types specified in `req_fields`.\
-   **Failure**: Columns with mismatched data types are listed.

### **7. Check for Missing Values in Required Columns**

-   **Purpose**: Identifies missing values (`NA`) in the required columns of the "Data" sheet.\
-   **Failure**: Columns with missing values are listed.

### **8. Verify Additional Columns in "Data" Match "Data Dictionary"**

-   **Purpose**: Ensures that:
    -   All additional columns in "Data" exist in the "Data Dictionary" (`column_name`).\
    -   All `column_name` values in the "Data Dictionary" are present in "Data."\
-   **Failure**: Missing or mismatched columns are reported.
