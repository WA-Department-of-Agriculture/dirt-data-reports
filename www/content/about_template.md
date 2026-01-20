**The template contains example data that should be replaced with your project's
sample metadata and results. These instructions are also found in the first tab
of the downloaded template spreadsheet.**

#### **What data do I need?**

-   You need results from at least one soil sample for at least one soil health
    measurement, in addition to texture.

-   Texture is a required measurement and must be included in both the **Data**
    tab and the **Data Dictionary** tab.

-   The more soil samples you include, the more meaningful the project, crop,
    and/or county comparisons will be in each producer’s custom report.

-   Each **column** must contain either:

    -   Sample metadata (e.g., year, sample_id, producer_id, field_id, etc.)

    -   Measurement results (e.g., texture, om_percent, etc.)

-   Each **row** should represent a single soil sample (with a unique sample_id)
    with its corresponding metadata and measurement results.

#### **What are the unique identifiers required?**

-   **sample_id**: A unique identifier for each soil sample (can be any
    alphanumeric value or a combination of year, producer_id, and field_id).

-   **producer_id**: Reports are generated for each producer_id in a given year.
    This can be an alphanumeric value or the producer’s name. Note: The tool
    does not currently support comparisons of soil samples over time.

-   **field_id**: Used to distinguish between different fields if a producer has
    multiple samples in the same year. This should be unique within a
    producer_id and year combination and can be any alphanumeric value or a
    field name assigned by the producer.

#### **How do I fill out the Data tab?**

1.  Review the example data structure and prepare your project’s data
    accordingly.

2.  **Metadata** (columns A–I: year through latitude) should not be deleted:

    -   **Metadata columns with bold headers** must not contain blanks. Replace
        example values with your own data.

    -   **Metadata columns with non-bold headers** can have missing values.
        Replace the example values with your samples' metadata. If a column is
        not relevant, delete the example values and leave it blank (do not
        delete the entire column). Missing metadata will be handled in reports
        (e.g., if farm_name is missing, producer_id will be used instead; if
        crop is missing, crop averages will be excluded from tables and plots).

    -   **latitude** and **longitude** must be provided in decimal form.
        Latitude must be between -90 and 90. Longitude must be between -180
        and 180. Providing these coordinates is optional. If they are not
        included, a map will not appear in the report.

<!-- -->

3.  **Measurement results** (columns J–AO: texture through na_mg_kg):

    -   **texture** may be left blank. If at least two of **sand_percent**,
        **silt_percent**, and **clay_percent** are provided, texture will be
        classified according to the USDA NRCS.

    -   **sand_percent**, **silt_percent**, and **clay_percent** must be between
        0 and 100 and sum to 100 (+/- 1). For each sample, at least two texture
        fractions must be provided (the third will be calculated as 100 minus
        the other two).

    -   Delete any columns for measurements not analyzed in your project.

    -   Add any additional measurements not included in this template.

    -   **Important**: Measurement column names in the **Data** tab must match
        the values in the column_name column of the **Data Dictionary** tab.
        Update the **Data Dictionary** tab after this step.

#### **How do I fill out the Data Dictionary tab?**

Customize how the measurements appear in the Project Results section of the
reports by editing the following columns:

-   **measurement_group**: Defines how measurements are grouped into sections.

    -   Allowable values for English reports are "Physical", "Biological",
        "Chemical", "Plant Essential Macro Nutrients", and "Plant Essential
        Micro Nutrients".

    -   Allowable values for Spanish reports are "Mediciones físicas",
        "Mediciones biológicas", "Mediciones químicas", "Macronutrientes
        esenciales para plantas", and "Micronutriente es esenciales para
        plantas".

-   **column_name**: Links the **Data** tab to the **Data Dictionary** tab. Each
    measurement column header in **Data** must have a corresponding row in the
    column_name of **Data Dictionary**.

-   **abbr**: Abbreviation used for the measurement in tables and plots.

-   **unit**: Unit of measurement displayed in tables and plots.
