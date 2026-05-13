### What happens when you upload your Excel file?

When you upload your file, the app automatically runs a series of validation
checks to ensure your data is complete, consistent, and ready for generating
soil health reports.

Validation happens in two stages:

1.   The **Valid File Structure Check** confirms the Excel file can be read and
    contains the required sheets and headers

2.   The remaining checks validate the contents of your data and data dictionary
    for errors and warnings

**❌ Errors must be resolved before continuing.\
⚠️ Warnings should be reviewed carefully.**

If your file passes the **Valid File Structure** check, an Excel issues file
will be generated whenever errors or warnings are found. This downloadable file
includes:

-    An **Issues** sheet summarizing all problems

-    Conditional formatting that highlights affected rows and values directly in
    your data

If your file fails the **Valid File Structure** check, the app cannot generate
the issues Excel file.

--------------------------------------------------------------------------------

#### **Valid File Structure Check (❌Error)**

Before running detailed validation, the app checks the basic file structure.

Your file must:

-   Contain both a **Data** sheet and a **Data Dictionary** sheet

-   Have no duplicate column headers

-   Contain at least one row under the headers in each sheet

--------------------------------------------------------------------------------

#### **Duplicate Identifiers (❌Error)**

Identifiers must be unique and consistent:

-   **sample_id** must be unique across the entire dataset

-   **field_id** must be unique for each combination of *year* and
    *producer_id*\
    (e.g., Producer A cannot have two “Field 01” entries in 2023)

--------------------------------------------------------------------------------

#### **No Measurement Columns (❌Error)**

Your **Data** sheet must include at least one measurement column beyond the
required metadata columns.

--------------------------------------------------------------------------------

#### **Unexpected Data Types (❌Error)**

Each column is checked against its expected data type:

-   **Numeric** columns must contain only numbers

-   **Character** columns must contain text

--------------------------------------------------------------------------------

#### **Missing Required Values (❌Error)**

Required columns must not contain blank values.

-   **Data** sheet required columns:

    -   *year*

    -   *sample_id*

    -   *producer_id*

    -   *field_id*

-   **Data Dictionary** sheet required columns:

    -   *measurement_group*

    -   *column_name*

    -   *abbr*

--------------------------------------------------------------------------------

#### **Invalid Coordinates (❌Error)**

Latitude and longitude must be valid decimal degrees:

-   *latitude*: -90 to 90

-    *longitude*: -180 to 180

Incomplete coordinate pairs (e.g., missing latitude but present longitude) will
also trigger errors.

--------------------------------------------------------------------------------

#### **Invalid Texture Fractions (❌ Error)**

*sand_percent*, *silt_percent*, or *clay_percent* must be between **0 and 100.**

The sum of the three fractions must equal **100 ± 1.**

--------------------------------------------------------------------------------

#### **Texture Fraction Computation (⚠️Warning)**

At least two texture fractions (*sand_percent*, *silt_percent*, or
*clay_percent)* must be provided to enable texture classification.

If one texture fraction is missing, it will be computed as 100 minus the sum of
the other two fractions.

--------------------------------------------------------------------------------

#### **Data / Data Dictionary Inconsistency (⚠️ Warning)**

Measurement columns in the **Data** sheet should match the **Data Dictionary**:

-    Every *column_name* in the **Data Dictionary** should exist in **Data**

-    Extra or missing columns will be flagged

--------------------------------------------------------------------------------

#### **Non-Numeric Values in Measurement Columns (⚠️Warning)**

All measurement columns (except *texture*) must be numeric.

Values like “ND” or “\<1” will be converted to NA and may be excluded from
summaries, tables, and plots.

Clean or recode non-numeric values before uploading for best results.

--------------------------------------------------------------------------------

#### **Large Measurement Group Size (⚠️Warning)**

Each measurement group (e.g., Physical, Biological, Chemical) should contain no
more than 8 measurements.

This helps ensure reports remain readable and figures are not overcrowded.
