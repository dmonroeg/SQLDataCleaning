SELECT *
FROM dbo.NashvilleHousing

-- Standardize date format

 SELECT SaleDateConverted, CONVERT(Date, SaleDate)
 FROM dbo.NashvilleHousing

 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(Date, SaleDate)

 -- if not updated properly
 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted Date;

 UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)


 --------------------------------------------------------

 --populate Property Address Data

SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress is null


--------------------------------------------------------------------------------

--Normalizing Address Columns

SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing



SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM dbo.NashvilleHousing

------------------------------------------------------------------------------------------

--CHange Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

---------------------------------------------------------------------------------------------------

--Remove Duplicates 

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress, SalePrice, SaleDate,LegalReference
ORDER BY UniqueID
) row_num
FROM dbo.NashvilleHousing
--ORDER BY ParcelID
) 

--SELECT * 
--FROM RowNumCTE
--WHERE row_num > 1


DELETE
FROM RowNumCTE
WHERE row_num > 1


SELECT *
FROM dbo.NashvilleHousing

------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate







