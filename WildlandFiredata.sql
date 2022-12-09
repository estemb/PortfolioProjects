--WFIGS_-_Wildland_Fire_Perimeters_Full_History.csv -> This is my Wildland Fire data reference
--SPI-utah.csv -> This is my drought data reference.
--Wildland Fire Data taken from https://data-nifc.opendata.arcgis.com/
--Drought Data taken from https://www.drought.gov/

-- SELECT * FROM Wildland_Fire

-- Checking for nulls in the Wildland Fire table
SELECT IncidentName, POOState
FROM PortfolioProject..Wildland_Fire
WHERE IncidentName IS NULL AND POOState LIKE 'US-UT'
	
SELECT InitialLatitude, POOState
FROM PortfolioProject..Wildland_Fire
WHERE InitialLatitude IS NULL AND POOState LIKE 'US-UT'

SELECT InitialLongitude, POOState
FROM PortfolioProject..Wildland_Fire
WHERE InitialLongitude IS NULL AND POOState LIKE 'US-UT'
--We have 2 results with NULLs. I dug through the table and was unable to identify it further via data or online search. I'm choosing to exclude the 2 nulls.

---This table has A LOT of data, so I'm going to trim it down to what I'm focusing on.
SELECT IncidentName, DailyAcres, POOState, FireCause, FireDiscoveryDateTime, InitialLatitude, InitialLongitude 
FROM PortfolioProject..Wildland_Fire
WHERE POOState LIKE 'US-UT' AND InitialLatitude IS NOT NULL
ORDER BY 5


-- Clean up the data for the Drought ratings. 
SELECT DATE, D0, D1, D2, D3, D4
FROM PortfolioProject..SPI_utah
WHERE DATE BETWEEN 20000101 AND 20221101