SELECT *
FROM conflict_related_sexual_violence
;

-- Creating duplicate table
CREATE TABLE sexual_violence
LIKE conflict_related_sexual_violence
;

INSERT sexual_violence
SELECT *
FROM conflict_related_sexual_violence
;

SELECT *
FROM sexual_violence
;

-- Drop unecessary columns
ALTER TABLE sexual_violence
DROP Latitude
;

ALTER TABLE sexual_violence
DROP Longitude
;

ALTER TABLE sexual_violence
DROP Country_ISO
;

ALTER TABLE sexual_violence
DROP Geo_Precision
;

ALTER TABLE sexual_violence
DROP Event_Description
;

-- Dropping rows with null values
SELECT DISTINCT(Location_Where_Sexual_Violence_Was_Committed), COUNT(*) as Occurance_Count
FROM sexual_violence
WHERE Location_Where_Sexual_Violence_Was_Committed = ''
GROUP BY Location_Where_Sexual_Violence_Was_Committed
ORDER BY Occurance_Count
;

DELETE
FROM sexual_violence
WHERE Location_Where_Sexual_Violence_Was_Committed = ''
;

-- EDA

-- Top 10 countries with the highest number of reports
CREATE Temporary TABLE Country_Aggregate as 
WITH Country_Aggregates_cte as (
SELECT Country, SUM(Number_of_Reported_Victims) as Total_Value
FROM sexual_violence
GROUP BY Country
)
SELECT *
FROM Country_Aggregates_cte
;


SELECT * 
FROM Country_Aggregate
ORDER BY Total_Value DESC LIMIT 10
;

-- Top 10 couuntries with lowest number of reports
SELECT *
FROM Country_Aggregate
ORDER BY Total_Value ASC LIMIT 10
;

-- Location where SV is most commonly commited
SELECT *
FROM sexual_violence
;

SELECT Location_Where_Sexual_Violence_Was_Committed, COUNT(*) as Occurance_Count
FROM sexual_violence
WHERE Location_Where_Sexual_Violence_Was_Committed NOT IN ("No Information")
GROUP BY Location_Where_Sexual_Violence_Was_Committed
ORDER BY Occurance_Count DESC LIMIT 5
;

-- Most reported perpetrator
SELECT Reported_Perpetrator, COUNT(*) as Reported_Perpetrator_Count
FROM sexual_violence
WHERE Reported_Perpetrator NOT LIKE "Other"
GROUP BY Reported_Perpetrator
ORDER BY Reported_Perpetrator_Count DESC limit 5
;

-- Most reported perpetrator name
SELECT Reported_Perpetrator_Name, COUNT(*) as Reported_Perpetrator_Name_Count
FROM sexual_violence
WHERE Reported_Perpetrator_Name NOT LIKE "No information"
GROUP BY Reported_Perpetrator_Name
ORDER BY Reported_Perpetrator_Name_Count DESC LIMIT 10
;

-- Type of perpetrators percentages
SELECT *
FROM sexual_violence
;

SELECT Single_And_Group_Perpetrators, (COUNT(Single_And_Group_Perpetrators)/ (SELECT COUNT(*) FROM sexual_violence)) * 100 AS Percentage_Of_Single_Group_Perpetrators
FROM sexual_violence
GROUP BY Single_And_Group_Perpetrators
;

-- Percentage of types of survivors 
SELECT DISTINCT(Survivor_or_Victim)
FROM sexual_violence;

SELECT 
	CASE
		WHEN Survivor_or_Victim LIKE "%Health Worker%" THEN "Health Worker"
        WHEN Survivor_or_Victim LIKE "%Civilian%" THEN "Civilian"
        WHEN Survivor_or_Victim LIKE "%Educator%" THEN "Educator"
        WHEN Survivor_or_Victim LIKE "%Aid Worker%" THEN "Aid Worker"
		WHEN Survivor_or_Victim LIKE "" THEN "Other"
	END AS Category,
    (COUNT(Survivor_or_Victim) / (SELECT COUNT(*) FROM sexual_violence)) * 100 AS Percentage_Of_Survivor_Type,
    GROUP_CONCAT(Survivor_or_Victim SEPARATOR ', ') AS Combined_Classifications
FROM sexual_violence
GROUP BY Category
;

-- Percentage of the sex types of survivors
SELECT DISTINCT(Survivor_Or_Victim_Sex)
FROM sexual_violence
;

SELECT 
	CASE
		WHEN Survivor_Or_Victim_Sex = "Male" THEN "Male"
        WHEN Survivor_Or_Victim_Sex = "Female" THEN "Female"
        WHEN Survivor_Or_Victim_Sex = "Unclear" THEN "Unclear"
        ELSE "Other"
	END AS Category,
    (COUNT(Survivor_Or_Victim_Sex) / (SELECT COUNT(*) FROM sexual_violence)) * 100 AS Percentage_Of_Survivor_Type_Sex,
     GROUP_CONCAT(Survivor_or_Victim_Sex SEPARATOR ', ') AS Combined_Classifications
FROM sexual_violence
GROUP BY Category
;
    

-- Percentage of adult and minor victims
SELECT DISTINCT(Adult_or_Minor)
FROM sexual_violence;

SELECT 
    REPLACE(Adult_or_Minor, ',', '') AS Adult_or_Minor_Cleaned,
    (COUNT(Adult_or_Minor) / (SELECT COUNT(*) FROM sexual_violence)) * 100 AS Percentage_Of_Adult_Minor_Victims
FROM sexual_violence
WHERE Adult_or_Minor IN ('Adult, ', 'Minor, ')
GROUP BY Adult_or_Minor_Cleaned;


-- Most common type of sexual violencE
SELECT DISTINCT(Type_of_SV)
FROM sexual_violence
;

SELECT 
	CASE
		WHEN Type_of_SV LIKE "%Rape%" THEN "Rape"
        WHEN Type_of_SV LIKE "%SexualAssault%" OR Type_of_SV LIKE "%AttemptedSexualAssualt%" THEN "Sexual Assault"
        WHEN Type_of_SV LIKE "%SexualHarassment%" THEN "Harassment"
        WHEN Type_of_SV LIKE "%Marriage%" THEN "Forced Marriage" 
        WHEN Type_of_SV LIKE "%ThreatOfSexualViolence%" OR Type_of_SV LIKE "%ForcedToWitness%" THEN "Threat/Forced Witness"
        WHEN Type_of_SV LIKE "%TransactionalSex%" THEN "Transactional Sex"
        WHEN Type_of_SV LIKE "%UnwantedSexualTouching%" THEN "Unwanted Sexual Touching"
        ELSE "Other/Unspecified"
	END AS Category,
    COUNT(*) AS Count,
    GROUP_CONCAT(Classification SEPARATOR ', ') AS Combined_Classifications
FROM sexual_violence
GROUP BY Category
ORDER BY Count DESC
;

--  Most common type of SV classifications
SELECT DISTINCT(Classification)
FROM sexual_violence
;

SELECT 
	CASE 
		WHEN Classification LIKE "%Intimation" THEN "Intimation"
        WHEN Classification LIKE "%Assault%" THEN "Assault"
        WHEN Classification LIKE "Rape" THEN "Rape"
        WHEN Classification LIKE "Unspecified%" THEN "Sexual Violence"
        ELSE "Unspecified"
	END AS Category,
    COUNT(*) AS Count,
    GROUP_CONCAT(classification SEPARATOR ', ') AS Combined_Classifications
FROM sexual_violence
GROUP BY Category
;

-- Weapons carried during incident
SELECT 
	CASE
		WHEN `Weapon_Carried/Used` LIKE "%Firearms%" OR "%fire arm%" THEN "Firearms"
        WHEN `Weapon_Carried/Used` LIKE "%Knife%" THEN "Knife"
        WHEN `Weapon_Carried/Used` LIKE "%Arson%" THEN "Arson"
        WHEN `Weapon_Carried/Used` LIKE "%Stones%" THEN "Stones, Sticks, Gravel"
        WHEN `Weapon_Carried/Used` LIKE "%Unarmed%" THEN "Unarmed"
        WHEN `Weapon_Carried/Used` LIKE "%Chemical%" THEN "Chemical/Hot liquid"
        WHEN `Weapon_Carried/Used` LIKE "%Fist%" THEN "Fist and Foot"
        WHEN `Weapon_Carried/Used` LIKE "%Hand Grenade%" THEN "Hand Grenade"
        ELSE "Other"
	END AS Category,
    COUNT(*) AS Count,
    GROUP_CONCAT(`Weapon_Carried/Used` SEPARATOR ', ') AS Combined_Classifications
FROM sexual_violence
GROUP BY Category
ORDER BY Count DESC
;

-- Total reported deaths from sexual violence
SELECT SUM(Reported_Deaths_Following_the_Sexual_Violence) AS Total_Deaths
FROM sexual_violence
;




