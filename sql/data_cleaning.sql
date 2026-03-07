-- =========================================
-- Retail Sales Data Cleaning Pipeline
-- Dataset: Online Retail
-- Database: sales_db
-- Table: raw_retail
-- Goal: Create an analysis-ready dataset
-- =========================================

-- Select database
USE sales_db;


-- =========================================
-- STEP 1: Inspect the raw dataset
-- =========================================

-- View sample records from raw data
SELECT *
FROM raw_retail
LIMIT 10;


-- Check total number of records
SELECT COUNT(*) AS total_rows
FROM raw_retail;


-- =========================================
-- STEP 2: Identify cancelled transactions
-- In this dataset invoices starting with 'C'
-- represent cancelled orders
-- =========================================

SELECT *
FROM raw_retail
WHERE InvoiceNo LIKE 'C%';


-- =========================================
-- STEP 3: Identify product returns
-- Negative quantities represent returns
-- =========================================

SELECT *
FROM raw_retail
WHERE Quantity < 0;


-- =========================================
-- STEP 4: Identify missing customer IDs
-- Some transactions do not contain customer
-- identifiers which limits customer analysis
-- =========================================

SELECT *
FROM raw_retail
WHERE CustomerID IS NULL;


-- =========================================
-- STEP 5: Identify duplicate rows
-- Using GROUP BY to detect repeated invoice
-- lines in the dataset
-- =========================================

SELECT
    InvoiceNo,
    StockCode,
    Quantity,
    COUNT(*) AS duplicate_count
FROM raw_retail
GROUP BY
    InvoiceNo,
    StockCode,
    Quantity
HAVING COUNT(*) > 1;


-- =========================================
-- STEP 6: Create a cleaned dataset
-- This step removes:
-- 1. Cancelled transactions
-- 2. Product returns (negative quantity)
-- 3. Records with missing CustomerID
-- 4. Duplicate rows using ROW_NUMBER()
-- Also creates a Revenue column
-- =========================================

CREATE TABLE clean_retail AS

WITH cleaned_data AS (

    SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country,

        -- Calculate revenue per transaction
        Quantity * UnitPrice AS Revenue,

        -- Assign row numbers to detect duplicates
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceNo, StockCode, Quantity
            ORDER BY InvoiceDate
        ) AS rn

    FROM raw_retail

    -- Remove problematic records
    WHERE
        InvoiceNo NOT LIKE 'C%'   -- Remove cancelled invoices
        AND Quantity > 0          -- Remove returned items
        AND CustomerID IS NOT NULL -- Remove missing customers
)

-- Keep only first occurrence of duplicates
SELECT *
FROM cleaned_data
WHERE rn = 1;


-- =========================================
-- STEP 7: Validate cleaned dataset
-- =========================================

-- Check row count after cleaning
SELECT COUNT(*) AS cleaned_rows
FROM clean_retail;


-- Preview cleaned data
SELECT *
FROM clean_retail
LIMIT 10;