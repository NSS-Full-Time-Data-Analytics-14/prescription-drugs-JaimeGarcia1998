SELECT *
FROM fips_county
SELECT *
FROM prescription
SELECT *
FROM drug
--question 1
SELECT
	DISTINCT npi
FROM prescriber
EXCEPT
SELECT 
	DISTINCT npi
FROM prescription
--total count
WITH npi_exclusive AS (
	SELECT
		DISTINCT npi
	FROM prescriber
	EXCEPT
	SELECT 
		DISTINCT npi
	FROM prescription
)
SELECT count(npi)
FROM npi_exclusive
--question 2
SELECT
	generic_name,
	COUNT(generic_name) AS drug_count
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY drug_count DESC
LIMIT 5;
--part b
SELECT
	generic_name,
	COUNT(generic_name) AS drug_count
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY drug_count DESC
LIMIT 5;
--part c
SELECT
	generic_name,
	COUNT(generic_name) AS drug_count
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Family Practice' OR specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY drug_count DESC
LIMIT 5
--question 3
SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_city,
	SUM(total_claim_count) AS total_claim_per_npi
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi,nppes_provider_last_org_name,nppes_provider_city
ORDER BY total_claim_per_npi DESC
LIMIT 5
--part b
SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_city,
	SUM(total_claim_count) AS total_claim_per_npi
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi,nppes_provider_last_org_name,nppes_provider_city
ORDER BY total_claim_per_npi DESC
LIMIT 5
--knoxville
SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_city,
	SUM(total_claim_count) AS total_claim_per_npi
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP BY npi,nppes_provider_last_org_name,nppes_provider_city
ORDER BY total_claim_per_npi DESC
LIMIT 5
--Chattanooga
SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_city,
	SUM(total_claim_count) AS total_claim_per_npi
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi,nppes_provider_last_org_name,nppes_provider_city
ORDER BY total_claim_per_npi DESC
LIMIT 5
--part C
SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_city,
	SUM(total_claim_count) AS total_claim_per_npi
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city IN ('NASHVILLE','MEMPHIS','KNOXVILLE','CHATTANOOGA')
GROUP BY npi,nppes_provider_last_org_name,nppes_provider_city
ORDER BY total_claim_per_npi DESC
LIMIT 20
--question 4
SELECT 
	f.county,
	overdose_deaths
FROM fips_county AS f
INNER JOIN overdose_deaths AS o
ON f.fipscounty::numeric = o.fipscounty::numeric
WHERE overdose_deaths > (
	SELECT 
		AVG(overdose_deaths)
	FROM overdose_deaths
)
--question 5
SELECT
	county,
	population,
	ROUND((population/ (SELECT 
		SUM(population) AS tn_total_pop
	FROM population AS p
	INNER JOIN fips_county AS f
	ON p.fipscounty::numeric = f.fipscounty::numeric
	WHERE state = 'TN'))*100,2) AS perc_tn_pop
FROM population AS p
INNER JOIN fips_county AS f
ON p.fipscounty::numeric = f.fipscounty::numeric
WHERE state = 'TN'