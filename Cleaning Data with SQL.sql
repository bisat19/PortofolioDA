/*

Cleaning Data in SQL Queries

*/

Select *
From [Portofolio Project]..NasvilleHousing
-----------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(date,SaleDate)
From [Portofolio Project]..NasvilleHousing

Update NasvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

alter table NasvilleHousing
add SaleDateConverted date;

Update NasvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

----------------------------------------------

-- Populate Property Address Data

Select *
From [Portofolio Project]..NasvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portofolio Project]..NasvilleHousing a
JOIN [Portofolio Project]..NasvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portofolio Project]..NasvilleHousing a
JOIN [Portofolio Project]..NasvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]

-----------------------------------------------------------------
--Breaking out Address into individual column (Address, City, State)

Select PropertyAddress
From [Portofolio Project]..NasvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From [Portofolio Project]..NasvilleHousing

alter table NasvilleHousing
add PropertySplitAddress nvarchar(255);

Update NasvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table NasvilleHousing
add PropertySplitCity nvarchar(255);

Update NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from [Portofolio Project]..NasvilleHousing

select OwnerAddress
from [Portofolio Project]..NasvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
from [Portofolio Project]..NasvilleHousing

alter table NasvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NasvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NasvilleHousing
add OwnerSplitCity nvarchar(255);

Update NasvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NasvilleHousing
add OwnerSplitState nvarchar(255);

Update NasvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from [Portofolio Project]..NasvilleHousing

-------------------------------------------------------
--Change Y and N to Yes and No In "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)
from [Portofolio Project]..NasvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from [Portofolio Project]..NasvilleHousing

Update NasvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

------------------------------------------------------------
--Remove Duplicates
with RowNumCTE AS(
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from [Portofolio Project]..NasvilleHousing
)--where row_num > 1
--order by ParcelID

--DELETE
Select *
From RowNumCTE
where row_num > 1

--------------------------------------------
--Delete Unused Columns

Select *
From [Portofolio Project]..NasvilleHousing

alter table [Portofolio Project]..NasvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Portofolio Project]..NasvilleHousing
drop column SaleDate