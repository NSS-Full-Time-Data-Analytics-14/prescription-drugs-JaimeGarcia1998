--question 1
SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description = 'Interventional Pain Management' OR specialty_description = 'Pain Management'
GROUP BY specialty_description
--question 2
SELECT 
	' ' AS specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description = 'Interventional Pain Management' OR specialty_description = 'Pain Management'
UNION
SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description = 'Interventional Pain Management' OR specialty_description = 'Pain Management'
GROUP BY specialty_description
ORDER BY total_claims DESC
--question 3
SELECT
	COUNT(total_claim_count)OVER(PARTITION BY specialty_description)
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description IN('Interventional Pain Management','Pain Management')

