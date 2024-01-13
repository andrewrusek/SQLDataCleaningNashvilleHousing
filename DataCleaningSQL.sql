/*

Data Cleaning in SQL Queries

*/

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------

-- Problem 1: SaleDate format of dates is not a standard form
-- Solution 1: Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
FROM DataCleaningProject.dbo.NashvilleHousing

Update DataCleaningProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


-- Alternate approach is ALTER TABLE with ADD

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)





-----------------------------------------------------------------------------------------------
-- Problem 2: Property Address column has null values.
-- Solution 2: Populate Property Address
-- ParcelID are connected to PropertyAddresses, so if ParcelID has PropertyAddress we can fill all matching ParcelID's




SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

-- Need to self join to perform this IF check


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a 
JOIN DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]     --JOIN only on ParcelID and not other columns
Where a.PropertyAddress is null

--Test
SELECT *								  
FROM DataCleaningProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------
-- Problem 3: Property Address has street, city all together. Owner Address has address, city, state all together.
-- Solution 3: Seperate Property Address (address, city, state) using Substrings and Parsename

--Substring method

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

FROM DataCleaningProject.dbo.NashvilleHousing

--Create the new column
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--Update column with new information
Update DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Test 
SELECT *								 
FROM DataCleaningProject.dbo.NashvilleHousing

--Parsename method for Owner Address Seperation

SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address
,PARSENAME(Replace(OwnerAddress,',','.'),2) as City
,PARSENAME(Replace(OwnerAddress,',','.'),1) as State
FROM DataCleaningProject.dbo.NashvilleHousing

--Create the new column
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
--Update column with new information
Update DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

--Create the new column
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
--Update column with new information
Update DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

--Create the new column
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);
--Update column with new information
Update DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--Test 
SELECT *								 
FROM DataCleaningProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------
-- Problem 4: SoldAsVacant values are 0 and 1
-- Solution 4: Change 0 and 1 to Yes and No in SoldAsVacant Field


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)					 
FROM DataCleaningProject.dbo.NashvilleHousing
Group BY SoldAsVacant
Order by 2

--Values are bit type, use Alter Table to change to nvarchar for manipulation
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Alter Column SoldAsVacant nvarchar(255)

--Change values using a CASE statement
SELECT SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   Else SoldAsVacant
	   END
FROM DataCleaningProject.dbo.NashvilleHousing

--Update column
Update DataCleaningProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   Else SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------
-- Problem 5: Duplicates can skew the data
-- Solution 5:Remove Duplicates

--Surround in a CTE to order by and delete rows 
WITH RowNumCTE as (
--Window Function to determine which rows are duplicates
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM DataCleaningProject.dbo.NashvilleHousing
					)
SELECT *   --To delete duplicates simply replace this SELECT * with DELETE and re-excecute then change back to SELECT * to check.
FROM RowNumCTE
WHERE row_num > 1 
--Order By PropertyAddress





-----------------------------------------------------------------------------------------------
-- Problem 6: Unused columns may cause data reporting issues
-- Solution 6: Delete columns by using Alter Table and Drop Columns, removing non useful data.. CAREFUL ON WHAT YOU DELETE. NOT TO BE DONE IN CORPORATE ENVIRONMENT

SELECT *								 
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress




