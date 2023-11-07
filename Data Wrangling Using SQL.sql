USE portfolio_project;

SET sql_safe_updates = 0;

SELECT * FROM nashville_housing;


-- Standardize sale data
SELECT STR_TO_DATE(saledate, '%M %e, %Y') AS formatted_date FROM nashville_housing;

UPDATE nashville_housing 
SET saledate = STR_TO_DATE(saledate, '%M %e, %Y');

SELECT saledate FROM nashville_housing;

-- Populate property address data 
SELECT * from nashville_housing
WHERE propertyaddress is null;
-- no null values

-- Breaking out address into individual columns
SELECT propertyaddress FROM nashville_housing;

SELECT
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, locate(',', PropertyAddress) +1, length(propertyaddress)) AS Address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitAddress VARCHAR(255);
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) - 1);

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitCity VARCHAR(100);
UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) +1, length(propertyaddress));

SELECT PropertySplitAddress,PropertySplitCity FROM nashville_housing;


-- OwnerAddress
SELECT OwnerAddress,
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1))
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitAddress VARCHAR(255);
UPDATE nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitCity VARCHAR(100);
UPDATE nashville_housing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitState VARCHAR(15);
UPDATE nashville_housing
SET OwnerSplitState = (SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1));

-- Change Y and N to Yes and No in 'SoldAsVacant'
SELECT DISTINCT SoldAsVAcant, COUNT(SoldAsVAcant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

-- SELECT SoldAsVAcant,
-- CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
-- 	WHEN SoldAsVacant = 'N' THEN 'No'
-- 	END
-- FROM nashville_housing;

-- UPDATE nashville_housing
-- SET SoldAsVacant = 
--     CASE 
--         WHEN SoldAsVacant = 'Y' THEN 'Yes'
--         WHEN SoldAsVacant = 'N' THEN 'No'
--         ELSE SoldAsVacant
--     END
-- WHERE SoldAsVacant IN ('Y', 'N');

-- Remove duplicates
WITH RowNumCTE AS(
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelId, 
                        PropertyAddress, 
                        SalePrice, 
                        SaleDate, 
                        LegalReference
           ORDER BY Uniqueid) AS row_num
FROM nashville_housing
-- ORDER BY ParcelId 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;
-- no duplicates

-- Delete Unused Columns
SELECT * 
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict;

