**The template includes example data. Replace these values with your project’s
sample metadata and measurement results.**

These same instructions are also included in the first tab of the downloaded
spreadsheet.

#### **What data do I need?**

-   You need results from **at least one soil sample** and **at least one soil
    health measurement**.

-   Including more soil samples improves the quality and usefulness of crop-,
    county-, and project-level comparisons in each producer’s report.

-   Each column must contain **one of the following**:

    -   Sample metadata (*year*, *sample_id*, *farm_name*, *producer_id*,
        *field_id*, *county*, *crop*, *latitude*, *longitude*)

    -   Measurement results (e.g., *texture*, *om_percent*, etc.). All
        measurement results (except *texture*) must be numeric. **Non-numeric
        values will be converted to NA**. Clean your data of common character
        values (e.g., ND, \<1) before uploading.

-   Each row should represent **one unique soil sample**, identified by a unique
    *sample_id*, along with its associated metadata and measurements.

#### **What unique identifiers are required?**

-   **sample_id**: A unique identifier for each soil sample. Can be any
    alphanumeric value or a combination of *year*, *producer_id*, and
    *field_id*.

-   **producer_id**: Reports are generated for each *producer_id* within a given
    year. This can be an alphanumeric value or the producer’s name.

-   **field_id**: Used to distinguish fields when a producer has multiple
    samples in the same year. Must be unique within a *producer_id* and *year*
    combination. Can be any alphanumeric value or a producer-assigned field
    name.

#### **How do I fill out the Data tab?**

Review the example structure and format your project data to match.

**Metadata** (columns A–I: *year* through *longitude*):

-   Do not delete metadata columns.

-   Columns with **bold headers** are required and must not contain blanks.

-   Columns with non-bold headers may contain blanks.

-   Replace example values with your own metadata.

-   If a column is not relevant, clear the example values but **do not delete
    the column**.

    -   If *farm_name* is missing, *producer_id* is used instead.

    -   If *crop* or *county* are missing, crop and/or county summaries are
        excluded from tables and plots.

-   *latitude* and *longitude*

    -   Optional. If missing, the report will not include a map.

    -   Must be provided in decimal degrees.

    -   *latitude*: -90 to 90; *longitude*: -180 to 180.

**Measurement results** (columns J–AO: *texture* through *na_mg_kg*):

-   All measurement columns **except *texture*** must be numeric. Non-numeric
    values (e.g., ND, \<1) will be converted to NA and may be omitted from
    summaries, tables, and plots. Clean or recode censored values before
    uploading.

<!-- -->

-   *texture* may be left blank. If at least two of *sand_percent*,
    *silt_percent*, and *clay_percent* are provided, *texture* will be
    classified using [USDA NRCS
    rules](https://www.nrcs.usda.gov/resources/education-and-teaching-materials/soil-texture-calculator).

    -   *sand_percent*, *silt_percent*, and *clay_percent* must:

        -   Be between 0 and 100

        -   Sum to 100 (± 1)

        -   Include at least two values per sample (the third will be calculated
            as 100 minus the sum of the other two)

-   Delete any columns for measurements not analyzed in your project.

-   Add columns for any additional measurements you wish to include.

    **Important:** Measurement column names in the Data tab must match exactly
    match the *column_name* values in the Data Dictionary tab. Update the Data
    Dictionary tab after adding or removing measurements.

#### **How do I fill out the Data Dictionary tab?**

Use the Data Dictionary to control how measurements appear in the Project
Results section of the report.

-   **measurement_group**: Defines how measurements are grouped. Groups appear
    in the report in the order listed in the data dictionary.

    -   **Only the following values are currently supported. Custom groups are
        not allowed and will fail validation.**

        -   **English:** Physical, Biological, Chemical, Plant Essential Macro
            Nutrients, Plant Essential Micro Nutrients

        -   **Spanish:** Mediciones físicas, Mediciones biológicas, Mediciones
            químicas, Macronutrientes esenciales para plantas, Micronutrientes
            esenciales para plantas

-   **column_name**: Links the Data tab to the Data Dictionary tab. Must exactly
    match the column names of the soil measurements in your data. Within each
    measurement group, measurements appear in the order listed in the data
    dictionary.

-   **abbr**: Abbreviation used in tables and plots. Shorter abbreviations
    improve readability.

-   **unit**: Unit of measurement displayed in tables and plots.

-   **abbr** + **unit**: Combination of abbreviation and unit must be unique for
    each measurement.
