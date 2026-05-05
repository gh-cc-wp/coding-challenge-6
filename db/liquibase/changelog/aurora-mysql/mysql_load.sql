-- CC6: MySQL data load from S3
-- No FK constraints (removed for Zero-ETL compatibility)
-- Source: s3://cc-s3-landing-bucket/input/

LOAD DATA FROM S3 's3://cc-s3-landing-bucket/input/beneficiaries.csv'
INTO TABLE cc_system.beneficiaries
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(beneficiary_id,first_name,last_name,dob,gender,address,city,state,zip,phone,flag_over_prescribed);

LOAD DATA FROM S3 's3://cc-s3-landing-bucket/input/providers.csv'
INTO TABLE cc_system.providers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(provider_id,npi,provider_name,specialty,address,city,state,zip,phone,flag_high_prescriber);

LOAD DATA FROM S3 's3://cc-s3-landing-bucket/input/pharmacies.csv'
INTO TABLE cc_system.pharmacies
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(pharmacy_id,pharmacy_name,address,city,state,zip,phone);

LOAD DATA FROM S3 's3://cc-s3-landing-bucket/input/ndc.csv'
INTO TABLE cc_system.ndc
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ndc_code,drug_name,strength_mg_per_unit,dosage_form,opioid_flag,mme_per_unit);

LOAD DATA FROM S3 's3://cc-s3-landing-bucket/input/claims_partd.csv'
INTO TABLE cc_system.claims_partd
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(claim_id,beneficiary_id,provider_id,pharmacy_id,ndc_code,date_of_service,quantity_dispensed,days_supply,total_mme,claim_amount,beneficiary_paid_amount,city,state,zip);

