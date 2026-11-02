Nashville Housing Data Cleaning in SQL
Project overview
This project uses Microsoft SQL Server to demonstrate data-cleaning techniques on the Nashville Housing dataset. The work focuses on improving consistency and preparing fields for further analysis.
Tools
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
Data-cleaning work demonstrated
1. Date standardisation — converts the sale date to the DATE data type and includes an option to populate a separate converted-date column.
2. Missing property addresses — uses a self-join on ParcelID to find matching records and populate missing PropertyAddress values.
3. Property address splitting — separates PropertyAddress into street/address and city fields.
4. Owner address splitting — uses PARSENAME and REPLACE to split OwnerAddress into address, city and state fields.
5. Categorical value standardisation — converts Y and N values in SoldAsVacant to Yes and No.
6. Duplicate identification — uses ROW_NUMBER() to flag rows sharing selected identifying fields.
7. Column removal — includes an ALTER TABLE ... DROP COLUMN statement for fields treated as unused in the original project script.
8. Optional import examples — includes commented examples for BULK INSERT and OPENROWSET.
Repository contents
- Data-Cleaning.sql — formatted SQL script containing the project queries.
- README.md — project overview and explanation.
How to use
1. Open SQL Server Management Studio.
2. Connect to a SQL Server instance that contains the Nashville Housing dataset.
3. Check that the database and table names match PortfolioProject.dbo.NashvilleHousing.
4. Review the script and run the sections in order, checking the results as you go.
Important execution notes
- The script modifies the table with UPDATE and ALTER TABLE statements. Work on a backup or copy of the dataset.
- The final DROP COLUMN operation permanently removes OwnerAddress, TaxDistrict, PropertyAddress and SaleDate. Review this step carefully before executing it.
- The duplicate section identifies rows with row_num > 1; it does not delete them.
- The original script refers to SaleDateConverted in an early preview query before the column is added. The reorganised script instead previews SaleDate and its converted value. The separate SaleDateConverted column is added later as an optional step; run that ALTER TABLE only if the column does not already exist.
- The address-splitting expressions assume the source fields contain the expected comma-separated format. Review unusual or null values before relying on the results.
- The dataset itself is not included. Add it only if its licence or source terms permit redistribution.
Author
Syed Naqvi

Data Analytics Portfolio
