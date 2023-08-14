SELECT * FROM n_house.`nashville housing data for data cleaning` ;

#Standardize Date Fromat

select SaleDate, Date(SaleDate) as Sale_date from n_house.`nashville housing data for data cleaning`;

set SQL_SAFE_UPDATES = 0;

update n_house.`nashville housing data for data cleaning` set SaleDate = Date(SaleDate);

#Populate Property Address data 

update n_house.`nashville housing data for data cleaning` set PropertyAddress = nullif(PropertyAddress, "");
Select * from   n_house.`nashville housing data for data cleaning` where PropertyAddress is null order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress) from n_house.`nashville housing data for data cleaning` a
JOIN n_house.`nashville housing data for data cleaning` b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
;

update n_house.`nashville housing data for data cleaning` as a 
join n_house.`nashville housing data for data cleaning` as b 
on a.ParcelID = b.ParcelID And a.UniqueID <> b.UniqueID
set a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress) 
where a.PropertyAddress is null
;

#break out address into individual columns (address, city, state)

#1 on PropertyAddress 
SELECT PropertyAddress FROM n_house.`nashville housing data for data cleaning` 
order by ParcelID;

select substring(PropertyAddress,1,instr(PropertyAddress,",")-1) as address,
substring(PropertyAddress, instr(PropertyAddress,",")+1, char_length(PropertyAddress) ) as city
FROM n_house.`nashville housing data for data cleaning` ;

alter table n_house.`nashville housing data for data cleaning` 
add PropertySplitAddress varchar(255) ;

update n_house.`nashville housing data for data cleaning` 
set PropertySplitAddress = substring(PropertyAddress,1,instr(PropertyAddress,",")-1);

alter table n_house.`nashville housing data for data cleaning` 
add PropertySplitCity varchar(255) ;

update n_house.`nashville housing data for data cleaning` 
set PropertySplitCity = substring(PropertyAddress, instr(PropertyAddress,",")+1, char_length(PropertyAddress) );

Select * from n_house.`nashville housing data for data cleaning` ;

#2 on OwnerAddress

Select 
substring_index(OwnerAddress,",",1) as Address, 
substring_index(substring_index(OwnerAddress,",",-2),",",1) as City,
substring_index(substring_index(OwnerAddress,",",3),",",-1) as State
 from n_house.`nashville housing data for data cleaning` ;
 
 Alter table n_house.`nashville housing data for data cleaning` 
 add OwnerSplitAddress varchar(255);
 
 update  n_house.`nashville housing data for data cleaning`  
 set OwnerSplitAddress = substring_index(OwnerAddress,",",1);
 
Alter table n_house.`nashville housing data for data cleaning` 
 add OwnerSplitCity varchar(255);
 
 update  n_house.`nashville housing data for data cleaning`  
 set OwnerSplitCity = substring_index(substring_index(OwnerAddress,",",-2),",",1) ;
 
Alter table n_house.`nashville housing data for data cleaning` 
 add OwnerSplitState varchar(255);
 
  update  n_house.`nashville housing data for data cleaning`  
 set OwnerSplitState = substring_index(substring_index(OwnerAddress,",",3),",",-1) ; 
 
 Select * from n_house.`nashville housing data for data cleaning` ;
 
 # change Y and N to Yes and No in "Sold as Vacant"
 
 Select distinct(SoldAsVacant), count(SoldAsVacant)
 from n_house.`nashville housing data for data cleaning`
Group by SoldAsVacant
Order by SoldAsVacant
 ;
 
 Select SoldAsVacant,
 case 	when SoldAsVacant = "Y" then "Yes"
		when SoldAsVacant = "N" then "No"
else SoldAsVacant
END
 from n_house.`nashville housing data for data cleaning`;
 
 Update n_house.`nashville housing data for data cleaning`  
 Set SoldAsVacant = 
 case when SoldAsVacant = "Y" then "Yes"
	when SoldAsVacant = "N" then "No"
else SoldAsVacant
END;
 
 Select * from n_house.`nashville housing data for data cleaning` ;
 
 # remove duplicates 
 
 Alter table  n_house.`nashville housing data for data cleaning`  
 add id INT auto_increment Primary key First
 ;
 
 With RowNumCTE as (
 Select id, 
 row_number() over (
 partition by ParcelID, 
 PropertyAddress, 
 SaleDate, 
 SalePrice, 
 LegalReference 
 Order by id) as Row_Num
 from n_house.`nashville housing data for data cleaning`
 )
delete n
from RowNumCTE
join n_house.`nashville housing data for data cleaning`  as n on n.id = RowNumCTE.id
 where Row_Num > 1;
 
 # delete unnamed columns 
 
 Select * from n_house.`nashville housing data for data cleaning` ;
 
 create view nash_h as 
 select UniqueID,
ParcelID,
LandUse,
SaleDate ,
SalePrice,
LegalReference,
SoldAsVacant ,
OwnerName ,
Acreage ,
LandValue ,
BuildingValue ,
TotalValue ,
YearBuilt ,
Bedrooms ,
FullBath ,
HalfBath ,
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState
 from n_house.`nashville housing data for data cleaning`;
 
 Select * from nash_h;

 
 