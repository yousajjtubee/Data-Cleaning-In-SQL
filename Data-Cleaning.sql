/*
    Project: Nashville Housing Data Cleaning
    Tool: Microsoft SQL Server

    This script demonstrates data-cleaning operations on:
    PortfolioProject.dbo.NashvilleHousing

    IMPORTANT:
    - Review the database/table names before running.
    - UPDATE and ALTER TABLE statements modify the source table.
    - The final DROP COLUMN statement permanently removes columns.
    - The duplicate section currently IDENTIFIES duplicate rows; it does not delete them.
*/

USE PortfolioProject;
GO

-- =========================================================
-- 1. Inspect the source data
-- =========================================================
SELECT *
FROM dbo.NashvilleHousing;
GO


-- =========================================================
-- 2. Standardise the sale date
-- =========================================================

-- Preview the converted date.
-- If SaleDateConverted does not already exist, run the ALTER TABLE
-- and UPDATE statements below before selecting that column.
SELECT
    SaleDate,
    CONVERT(date, SaleDate) AS SaleDateAsDate
FROM dbo.NashvilleHousing;
GO

-- Convert SaleDate to the DATE data type.
UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);
GO

-- Alternative: create a separate converted-date column.
-- Run this block only if SaleDateConverted does not already exist.
ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted date;
GO

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);
GO


-- =========================================================
-- 3. Populate missing property addresses
-- =========================================================

-- Inspect records and sort by ParcelID.
SELECT *
FROM dbo.NashvilleHousing
ORDER BY ParcelID;
GO

-- Find matching records that can provide a missing PropertyAddress.
SELECT
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID AS MatchingParcelID,
    b.PropertyAddress AS MatchingPropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS PopulatedPropertyAddress
FROM dbo.NashvilleHousing AS a
INNER JOIN dbo.NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
GO

-- Populate missing PropertyAddress values from matching ParcelID records.
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing AS a
INNER JOIN dbo.NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
GO


-- =========================================================
-- 4. Split PropertyAddress into address and city columns
-- =========================================================

SELECT
    PropertyAddress,
    SUBSTRING(
        PropertyAddress,
        1,
        CHARINDEX(',', PropertyAddress) - 1
    ) AS PropertySplitAddress,
    SUBSTRING(
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) + 1,
        LEN(PropertyAddress)
    ) AS PropertySplitCity
FROM dbo.NashvilleHousing;
GO

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
GO

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(
    PropertyAddress,
    1,
    CHARINDEX(',', PropertyAddress) - 1
);
GO

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);
GO

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(
    PropertyAddress,
    CHARINDEX(',', PropertyAddress) + 1,
    LEN(PropertyAddress)
);
GO


-- =========================================================
-- 5. Split OwnerAddress into address, city and state columns
-- =========================================================

SELECT
    OwnerAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM dbo.NashvilleHousing;
GO

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
GO

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);
GO

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
GO

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);
GO

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);
GO

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
GO


-- =========================================================
-- 6. Standardise SoldAsVacant values
-- =========================================================

-- Review the distinct values and their frequency.
SELECT
    SoldAsVacant,
    COUNT(SoldAsVacant) AS RecordCount
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY RecordCount;
GO

-- Preview the standardised values.
SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS StandardisedSoldAsVacant
FROM dbo.NashvilleHousing;
GO

-- Update Y/N values to Yes/No.
UPDATE dbo.NashvilleHousing
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
GO


-- =========================================================
-- 7. Identify duplicate records
-- =========================================================

-- ROW_NUMBER assigns a sequence to records sharing the selected
-- identifying fields. Rows numbered greater than 1 are flagged
-- as potential duplicates for review.
WITH RowNumCTE AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;
GO

-- Note: this query identifies duplicate rows only.
-- No DELETE statement is included in the original project script.


-- =========================================================
-- 8. Remove unused columns
-- =========================================================

-- Review the table before removing columns.
SELECT *
FROM dbo.NashvilleHousing;
GO

-- DESTRUCTIVE: permanently removes these columns from the table.
-- Confirm that they are no longer required before running.
ALTER TABLE dbo.NashvilleHousing
DROP COLUMN
    OwnerAddress,
    TaxDistrict,
    PropertyAddress,
    SaleDate;
GO


-- =========================================================
-- 9. Optional data import examples (not executed)
-- =========================================================

-- These examples were included as optional approaches.
-- They require appropriate SQL Server configuration and valid file paths.

-- Enable advanced options and Ad Hoc Distributed Queries if required:
-- EXEC sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- GO
-- EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO

-- Example: BULK INSERT
-- BULK INSERT dbo.NashvilleHousing
-- FROM 'C:\Path\To\NashvilleHousing.csv'
-- WITH
-- (
--     FIELDTERMINATOR = ',',
--     ROWTERMINATOR = '\n'
-- );
-- GO

-- Example: OPENROWSET
-- SELECT *
-- FROM OPENROWSET
-- (
--     'Microsoft.ACE.OLEDB.12.0',
--     'Excel 12.0; Database=C:\Path\To\NashvilleHousing.xlsx',
--     'SELECT * FROM [Sheet1$]'
-- );
-- GO
