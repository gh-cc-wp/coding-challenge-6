delete from  cc_system.claims_partd;
delete from cc_system.ndc;
delete from cc_system.pharmacies;
delete from cc_system.providers;
delete from cc_system.beneficiaries;

COPY cc_system.beneficiaries (beneficiary_id,first_name,last_name,dob,gender,address,city,state,zip,phone,flag_over_prescribed)
FROM 's3://cc-s3-landing-bucket/input/beneficiaries.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;

COPY cc_system.providers (provider_id,npi,provider_name,specialty,address,city,state,zip,phone,flag_high_prescriber)
FROM 's3://cc-s3-landing-bucket/input/providers.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;


COPY cc_system.pharmacies (pharmacy_id,pharmacy_name,address,city,state,zip,phone)
FROM 's3://cc-s3-landing-bucket/input/pharmacies.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;

COPY cc_system.ndc (ndc_code,drug_name,strength_mg_per_unit,dosage_form,opioid_flag,mme_per_unit)
FROM 's3://cc-s3-landing-bucket/input/ndc.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;

COPY cc_system.claims_partd (claim_id,beneficiary_id,provider_id,pharmacy_id,ndc_code,date_of_service,quantity_dispensed,days_supply,total_mme,claim_amount,beneficiary_paid_amount,city,state,zip)
FROM 's3://cc-s3-landing-bucket/input/claims_partd.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;
