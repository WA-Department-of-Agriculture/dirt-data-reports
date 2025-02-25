When you upload your file, the system performs the following checks:

---

### 1. File Structure Check

Your file must contain two sheets:

- **`Data`** – Where your main data is stored.
- **`Data Dictionary`** – A reference sheet explaining the data.

⚠️ *If these sheets are missing, the upload will fail.*

---

### 2. Required Columns Check

The system verifies that all **mandatory columns** are present in the **`Data`** sheet.

❌ *If any required columns are missing, you will receive an error message.*

---

### 3. Data Dictionary Check

The **`Data Dictionary`** must contain all expected reference fields.

⚠️ *Missing fields in the dictionary may cause integration issues.*

---

### 4. Unique Values Check

- Certain columns (like ``sample_id`` or ``producer_id``) must be **unique** based on defined rules.
- Some fields must be **unique within specific groups**  (e.g., ``field_id`` must be unique within each ``producer_id``).

🚨 *If duplicates are found, they will be flagged.*

---

### 5. Additional Column Check

Your file must have at least **one additional column** beyond the required fields.

✅ *This ensures the file contains useful data for analysis.*

---

### 6. Data Type Validation

Each column is checked to confirm it follows the expected data type:

- **Numbers** should be numeric (e.g., `` `int` ``, `` `double` ``).
- **Text fields** should contain characters.

❌ *If a mismatch is found (e.g., text in a numeric field), you will receive an error.*

---

### 7. Missing Values Check

Certain required fields **must not be empty**.

⚠️ *If missing values are found, they will be flagged.*

---

### 8. Consistency with Data Dictionary

The system ensures that all **additional columns** in the **`Data`** sheet match the expected values in the **`Data Dictionary`**.

❗ *If there are extra columns in one but not the other, you will be notified.*

---
