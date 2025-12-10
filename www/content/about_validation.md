### What happens when you upload your .xlsx file?

The app automatically runs a series of data validation checks to ensure your file is complete and formatted correctly.

---

### 1. File Structure Check

Your file must contain **two tabs**:

- **Data** — your main soil data  
- **Data Dictionary** — definitions and metadata for each column

❌ *If either tab is missing, the upload will fail.*

---

### 2. Required Columns Check

We verify that all required columns exist in both the **Data** tab and the **Data Dictionary** tab.

❌  *Any missing required columns will be listed in an error message.*

---

### 3. Unique Identifier Check

- **sample_id** must be **unique across the entire dataset**
- **field_id** must be **unique for each** combination of **year** and **producer_id**  
  (e.g., Producer A cannot have two “Field 01” entries in 2023)

⚠️ *Any duplicate values will be listed in an error message.*

---

### 4. Measurement Columns Check

Your **Data** tab must contain at least **one measurement column** beyond the required fields  
(columns A–J: year → texture).

✅ *This ensures there are actual lab results to visualize and report.*

---

### 5. Data Type Validation

Each column is checked against its expected data type:

- **Numeric** columns must contain only numbers  
- **Character** columns must contain text

⚠️ *Any mismatched values will be flagged and listed.*

---

### 6. Missing Required Values Check

Columns shown in **bold** in the templates must not contain blank cells.

❌ *Any missing values will be listed in an error message.*

---

### 7. Consistency with Data Dictionary

All **measurement columns** (after column J) in **Data** must match the column names listed in the **Data Dictionary**.

⚠️ *Any extra or mismatched columns will be listed.*

---

### 8. Valid Range Check (Texture Measurements)

**sand_percent**, **silt_percent**, and **clay_percent** must each be between **0 and 100**.

⚠️ *Any values outside this range will be listed as errors.*

---

### 9. Measurement Group Validation

Values in the **measurement_group** column of the **Data Dictionary** must match the valid group names:

**English reports**  
- Physical  
- Biological  
- Chemical  
- Plant Essential Macro Nutrients  
- Plant Essential Micro Nutrients  

**Spanish reports**  
- Mediciones físicas  
- Mediciones biológicas  
- Mediciones químicas  
- Macronutrientes esenciales para plantas  
- Micronutrientes esenciales para plantas  

⚠️ *Any invalid entries will be listed in an error message.*