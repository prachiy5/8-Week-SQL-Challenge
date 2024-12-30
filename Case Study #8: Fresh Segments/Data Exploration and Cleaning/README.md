# 🔧 Data Exploration and Cleansing

## 📈 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

**Steps:**
- Verified the data type of `month_year`.
- Updated `month_year` values to start of the month in `YYYY-MM-DD` format.
- Removed invalid or null `month_year` entries.
- Changed the column data type to `DATE`.

**Sample Records:**
| _month | _year | month_year  | interest_id | composition | index_value | ranking | percentile_ranking |
|--------|-------|-------------|-------------|-------------|-------------|---------|--------------------|
| 7      | 2018  | 2018-07-01 | 32486       | 11.89       | 6.19        | 1       | 99.86             |
| 7      | 2018  | 2018-07-01 | 6106        | 9.93        | 5.31        | 2       | 99.73             |

---

## 📈 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
**Query:**
```sql
SELECT month_year, COUNT(*) AS record_count
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;
```
**Insight:**
- Records are distributed across 14 months, with `2019-08-01` having the highest count of 1149.

---

## 📈 3. What do you think we should do with these null values in the fresh_segments.interest_metrics?
**Action:**
- Deleted null values from the `month_year` column in the `interest_metrics` table as they represented incomplete or invalid data.

**Reason:**
- Removing these ensures the dataset remains clean and accurate for meaningful analysis.

**Query:**
```sql
DELETE FROM interest_metrics
WHERE month_year IS NULL;
```
**Insight:**
- The dataset is now clean and ready for further processing.
- Ensures a clean dataset for accurate analysis.

---

## 📈 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
**Queries:**
```sql
-- interest_ids in interest_metrics but not in interest_map
SELECT COUNT(interest_id) AS total_ids_not_in_map 
FROM interest_metrics 
WHERE interest_id NOT IN (SELECT id FROM interest_map);

-- ids in interest_map but not in interest_metrics
SELECT COUNT(id) AS total_ids_not_in_metrics
FROM interest_map 
WHERE id NOT IN (SELECT interest_id FROM interest_metrics);
```
**Insight:**
- All `interest_id` values in `interest_metrics` have mappings in `interest_map`.
- 7 `id` values in `interest_map` are not present in `interest_metrics`.

---

## 📈 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
**Query:**
```sql
SELECT COUNT(*) AS map_id_count
FROM interest_map;
```
**Insight:**
- The `interest_map` table contains 1209 records.

---

## 📈 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

**Answer:**
We should use a **LEFT JOIN** from `interest_metrics` to `interest_map` because:

- **Purpose:** The goal is to analyze the data in `interest_metrics` while enriching it with details from `interest_map` (e.g., `interest_name` and `interest_summary`).
- **Inclusion:** A LEFT JOIN ensures all rows from `interest_metrics` are included, even if there is no corresponding record in `interest_map`. This is crucial if some `interest_id` values in `interest_metrics` are not present in `interest_map`.

**Query:**
```sql
SELECT 
    im.*, 
    imap.interest_name, 
    imap.interest_summary,
    imap.created_at,
    imap.last_modified
FROM interest_metrics im
LEFT JOIN interest_map imap
ON CAST(im.interest_id AS INT) = imap.id
WHERE im.interest_id = 21246;
```
**Sample Record:**
| _month | _year | month_year  | interest_id | composition | ... | interest_name               | interest_summary                            |
|--------|-------|-------------|-------------|-------------|-----|-----------------------------|--------------------------------------------|
| 7      | 2018  | 2018-07-01 | 21246       | 2.26        | ... | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. |

**Join Logic:**
- Use a **LEFT JOIN** from `interest_metrics` to `interest_map`.

**Reason:**
- Ensures all rows in `interest_metrics` are included, even if they don’t have a corresponding `interest_id` in `interest_map`.

**Query:**
```sql
SELECT 
    im.*, 
    imap.interest_name, 
    imap.interest_summary,
    imap.created_at,
    imap.last_modified
FROM interest_metrics im
LEFT JOIN interest_map imap
ON CAST(im.interest_id AS INT) = imap.id
WHERE im.interest_id = 21246;
```
**Sample Record:**
| _month | _year | month_year  | interest_id | composition | ... | interest_name               | interest_summary                            |
|--------|-------|-------------|-------------|-------------|-----|-----------------------------|--------------------------------------------|
| 7      | 2018  | 2018-07-01 | 21246       | 2.26        | ... | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. |

---

## 📈 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
**Query:**
```sql
SELECT 
    COUNT(*) AS num_records
FROM interest_metrics im
LEFT JOIN interest_map imap
ON CAST(im.interest_id AS INT) = imap.id
WHERE im.month_year < imap.created_at;
```
**Output:**
- 188 records where `month_year` is earlier than `created_at`.

**Interpretation of Results:**
- **Why Might These Records Exist?**
  - **Data Entry Errors:** Incorrect `month_year` values in `interest_metrics` could result in dates preceding `created_at` in `interest_map`.
  - **Backdated Data:** Historical interactions might have been logged before the corresponding `interest_map` entries were created.
  - **Late Record Additions:** `interest_map` might have been updated after the actual interactions took place.

**Are These Records Valid?**
- **Likely Valid:** If backdating is intended, these records are valid and need no correction.
- **Likely Invalid:** If `month_year` must not precede `created_at`, these records indicate data entry or processing errors that need correction.

**Conclusion:**
The presence of 188 records could reflect valid backdated interactions or data inconsistencies. Next steps should include:
- Reviewing business rules to confirm if backdating is allowed.
- Investigating affected records to identify potential errors.
- Correcting or cleaning the data if deemed invalid.


---

