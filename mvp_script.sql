select *
FROM prescription
--question 1 
SELECT 
	npi,
	SUM(total_claim_count) AS total_claim_by_provider
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi
ORDER BY total_claim_by_provider DESC;
-- part b
SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name,specialty_description
ORDER BY total_claims DESC;
--question 2
SELECT
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;
-- part b
SELECT
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claims DESC;

--part c CHALLENGE
SELECT
	DISTINCT specialty_description
FROM prescriber
WHERE specialty_description NOT IN (SELECT specialty_description FROM prescription LEFT JOIN prescriber USING(npi))
--part d BONUS
WITH total_opioids_prescribed AS (
	SELECT
		specialty_description,
		SUM(total_claim_count) AS total_opioids_prescribed_num
	FROM prescription
	INNER JOIN prescriber
	USING(npi)
	INNER JOIN drug
	USING(drug_name)
	WHERE opioid_drug_flag = 'Y'
	GROUP BY specialty_description
	ORDER BY total_opioids_prescribed_num DESC
)
SELECT 
	specialty_description,
	(total_opioids_prescribed_num)/SUM(total_claim_count) AS percent
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
INNER JOIN total_opioids_prescribed
USING(specialty_description)
GROUP BY specialty_description,total_opioids_prescribed_num
ORDER BY percent DESC

-- Not what was asked but in my opinion cooler info
SELECT
	specialty_description,
	SUM(total_claim_count),
	SUM(total_claim_count)/(SELECT SUM(total_claim_count)
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE drug.opioid_drug_flag = 'Y')*100 AS percent_claims_of_all_opioid_flags
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY sum DESC
--question 3
SELECT 
	generic_name,
	SUM(total_drug_cost)::money AS sum_cost_per_gen_name
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY sum_cost_per_gen_name DESC;
--part b
SELECT 
	generic_name,
	--SUM(total_drug_cost) AS sum_cost_per_gen_name,
	SUM(total_drug_cost::MONEY)/SUM(total_day_supply) AS cost_per_day
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;
--question 4
SELECT 
	drug_name,
	CASE
		WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
			END
FROM drug;
--part b
SELECT 
	SUM(total_drug_cost::MONEY) AS cost_per_type,
	CASE
		WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
			END AS drug_type
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY drug_type
ORDER BY cost_per_type DESC;
--question 5
SELECT 
	COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';
--part b
SELECT
	cbsaname,
	SUM(population) AS population_per_cbsaname
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY population_per_cbsaname DESC
--part c
SELECT
	county,
	sum(population) AS sum_pop
FROM population
INNER JOIN fips_county
USING(fipscounty)
GROUP BY county
EXCEPT
SELECT
	county,
	SUM(population)
FROM cbsa
INNER JOIN population
USING(fipscounty)
INNER JOIN fips_county
USING(fipscounty)
GROUP BY county
ORDER BY sum_pop DESC
--question 6
SELECT 
	drug_name,
	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC
--part b
SELECT 
	drug_name,
	total_claim_count,
	CASE
		WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
			END AS drug_type
FROM prescription
INNER JOIN DRUG
USING(drug_name)
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC
--part c
SELECT 
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	drug_name,
	total_claim_count,
	CASE
		WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
			END AS drug_type
FROM prescription
INNER JOIN DRUG
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count > 3000
--question 7
SELECT 
	drug_name,
	opioid_drug_flag,
	npi,
	specialty_description
FROM drug
CROSS JOIN prescriber
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city ILIKE 'Nashville'
	AND opioid_drug_flag = 'Y'
--part b
SELECT 
	drug.drug_name,
	npi,
	COALESCE(SUM(total_claim_count),0) AS claim_per_drug
FROM drug
CROSS JOIN prescriber
FULL JOIN prescription
USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city ILIKE 'Nashville'
	AND opioid_drug_flag = 'Y'
GROUP BY drug.drug_name,npi
ORDER BY claim_per_drug DESC