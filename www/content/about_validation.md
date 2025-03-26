When you upload your file, the system performs the following checks:

------------------------------------------------------------------------

### 1. File Structure Check

Your file must contain two tabs:

-   **Data**: Where your main data is stored.

-   **Data Dictionary**: A reference tab explaining the data.

⚠️ *If these tabs are missing, the upload will fail.*

------------------------------------------------------------------------

### 2. Required Columns Check

The system verifies that all **mandatory columns** are present in the **Data** tab.

❌ *If any required columns are missing, you will receive an error message.*

------------------------------------------------------------------------

### 3. Data Dictionary Check

The **Data Dictionary** must contain all expected columns.

⚠️ *Missing columns in the dictionary may cause integration issues.*

------------------------------------------------------------------------

### 4. Unique Values Check

-   sample_id must be **unique** across the entire dataset.

-   field_id must be **unique** within each year and producer_id combination. (i.e., Producer A cannot have two fields called Field 01 sampled in 2023.)

🚨 *If duplicates are found, they will be flagged.*

------------------------------------------------------------------------

### 5. Measurement Column Check

**Data** must contain at least one measurement column after the required columns (columns A–J: year through texture).

✅*This ensures the reports contain lab results for the tables and plots.*

------------------------------------------------------------------------

### 6. Data Type Validation

Each column is checked to confirm it follows the expected data type:

-   **Numeric columns** should contain only numbers.

-   **Character columns** should contain text.

❌ *If a mismatch is found (e.g., text in a numeric column), you will receive an error.*

------------------------------------------------------------------------

### 7. Missing Values Check

Columns with bold headers **must not have any blanks**.

⚠️ *If missing values are found, they will be flagged.*

------------------------------------------------------------------------

### 8. Consistency with Data Dictionary

The system ensures that all **measurement columns** (after column J) in the **Data** tab match the values in column_name in the **Data Dictionary**.

❗ *If there are extra columns in one but not the other, you will be notified.*

------------------------------------------------------------------------