delete from cc_system.plans ;
delete from cc_system.pharmacies ;
delete from cc_system.providers ;
delete from cc_system.beneficiaries ;
delete from cc_system.claims ;
delete from cc_system.approved_drugs ;

drop TABLE if exists cc_temp.stg_ndc_approvals1;

CREATE TABLE cc_temp.stg_ndc_approvals1 (
    version       VARCHAR(10),
    source        VARCHAR(50),
    as_of_date    DATE,
    ndc11         VARCHAR(11)
);

COPY cc_system.plans (plan_id, plan_name, pbp_id, contract_id, segment_id, plan_type, service_area, state)
FROM 's3://cc5-s3-landing-bucket/input/plans.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;


COPY cc_system.pharmacies (pharmacy_id, ncpdp_id, pharmacy_name, zip_code, county, state)
FROM 's3://cc5-s3-landing-bucket/input/pharmacies.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;


COPY cc_system.providers (provider_id, npi, provider_name, specialty, zip_code, county, state)
FROM 's3://cc5-s3-landing-bucket/input/providers.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;


COPY cc_system.beneficiaries (bene_id, first_name, last_name, gender, dob, zip_code, county, state, plan_id, effective_date, termination_date)
FROM 's3://cc5-s3-landing-bucket/input/beneficiaries.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;


COPY cc_system.claims (claim_id, claim_type_code, claim_status, submitted_date, adjudicated_date, bene_id, provider_id, plan_id, pharmacy_id, ndc11, rx_number, fill_number, days_supply, quantity_dispensed, ingredient_cost, dispensing_fee, patient_pay, plan_pay, total_submitted_amount, total_paid_amount)
FROM 's3://cc5-s3-landing-bucket/input/claims.csv'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
CSV IGNOREHEADER 1
EMPTYASNULL;

COPY cc_temp.stg_ndc_approvals1 (version, source, as_of_date, ndc11)
FROM 's3://cc5-s3-landing-bucket/tmp/ndc_approvals_flat.json'
IAM_ROLE 'arn:aws:iam::338394180895:role/dev-ec2-role'
JSON 'auto'
DATEFORMAT 'YYYY-MM-DD';

insert into cc_system.approved_drugs
select * from cc_temp.stg_ndc_approvals1;


