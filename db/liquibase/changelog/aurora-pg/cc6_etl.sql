drop table if exists cc_temp.claims_partd_staging;
drop table if exists cc_temp.claims_partd_rejected;

delete from  cc_system.claims_partd;
delete from  cc_system.ndc;
delete from  cc_system.pharmacies;
delete from  cc_system.providers;
delete from  cc_system.beneficiaries;


CREATE TABLE cc_temp.claims_partd_staging (
    claim_id                VARCHAR(15),
    beneficiary_id          VARCHAR(15),
    provider_id             VARCHAR(15),
    pharmacy_id             VARCHAR(15),
    ndc_code                VARCHAR(15),
    date_of_service         DATE,
    quantity_dispensed       INTEGER,
    days_supply             INTEGER,
    total_mme               DECIMAL(10,2),
    claim_amount            DECIMAL(10,2),
    beneficiary_paid_amount DECIMAL(10,2),
    city                    VARCHAR(100),
    state                   VARCHAR(2),
    zip                     VARCHAR(10)
);

CREATE TABLE cc_temp.claims_partd_rejected (
    claim_id                VARCHAR(15),
    beneficiary_id          VARCHAR(15),
    provider_id             VARCHAR(15),
    pharmacy_id             VARCHAR(15),
    ndc_code                VARCHAR(15),
    date_of_service         DATE,
    quantity_dispensed       INTEGER,
    days_supply             INTEGER,
    total_mme               DECIMAL(10,2),
    claim_amount            DECIMAL(10,2),
    beneficiary_paid_amount DECIMAL(10,2),
    city                    VARCHAR(100),
    state                   VARCHAR(2),
    zip                     VARCHAR(10),
    rejection_reason        TEXT,
    rejected_at             TIMESTAMP DEFAULT NOW()
);


SELECT aws_s3.table_import_from_s3(
    'cc_system.ndc',
    'ndc_code,drug_name,strength_mg_per_unit,dosage_form,opioid_flag,mme_per_unit',
    '(FORMAT csv, HEADER true)',
    'cc-s3-landing-bucket', 'input/ndc.csv', 'us-east-1'
);

SELECT aws_s3.table_import_from_s3(
    'cc_system.pharmacies',
    'pharmacy_id,pharmacy_name,address,city,state,zip,phone',
    '(FORMAT csv, HEADER true)',
    'cc-s3-landing-bucket', 'input/pharmacies.csv', 'us-east-1'
);

SELECT aws_s3.table_import_from_s3(
    'cc_system.providers',
    'provider_id,npi,provider_name,specialty,address,city,state,zip,phone,flag_high_prescriber',
    '(FORMAT csv, HEADER true)',
    'cc-s3-landing-bucket', 'input/providers.csv', 'us-east-1'
);

SELECT aws_s3.table_import_from_s3(
    'cc_system.beneficiaries',
    'beneficiary_id,first_name,last_name,dob,gender,address,city,state,zip,phone,flag_over_prescribed',
    '(FORMAT csv, HEADER true, NULL '''')',
    'cc-s3-landing-bucket', 'input/beneficiaries.csv', 'us-east-1'
);


SELECT aws_s3.table_import_from_s3(
    'cc_temp.claims_partd_staging',
    'claim_id,beneficiary_id,provider_id,pharmacy_id,ndc_code,date_of_service,quantity_dispensed,days_supply,total_mme,claim_amount,beneficiary_paid_amount,city,state,zip',
    '(FORMAT csv, HEADER true, NULL '''')',
    'cc-s3-landing-bucket', 'input/claims_partd.csv', 'us-east-1'
);

INSERT INTO cc_temp.claims_partd_rejected
(claim_id, beneficiary_id, provider_id, pharmacy_id, ndc_code, date_of_service,
 quantity_dispensed, days_supply, total_mme, claim_amount, beneficiary_paid_amount,
 city, state, zip, rejection_reason)
SELECT s.*,
    CONCAT_WS('; ',
        CASE WHEN b.beneficiary_id IS NULL THEN 'orphan_beneficiary_id: ' || s.beneficiary_id END,
        CASE WHEN p.provider_id IS NULL THEN 'orphan_provider_id: ' || s.provider_id END,
        CASE WHEN ph.pharmacy_id IS NULL THEN 'orphan_pharmacy_id: ' || s.pharmacy_id END,
        CASE WHEN n.ndc_code IS NULL THEN 'orphan_ndc_code: ' || s.ndc_code END
    ) AS rejection_reason
FROM cc_temp.claims_partd_staging s
LEFT JOIN cc_system.beneficiaries b ON s.beneficiary_id = b.beneficiary_id
LEFT JOIN cc_system.providers p ON s.provider_id = p.provider_id
LEFT JOIN cc_system.pharmacies ph ON s.pharmacy_id = ph.pharmacy_id
LEFT JOIN cc_system.ndc n ON s.ndc_code = n.ndc_code
WHERE b.beneficiary_id IS NULL
   OR p.provider_id IS NULL
   OR ph.pharmacy_id IS NULL
   OR n.ndc_code IS NULL;


INSERT INTO cc_system.claims_partd
(claim_id, beneficiary_id, provider_id, pharmacy_id, ndc_code, date_of_service,
 quantity_dispensed, days_supply, total_mme, claim_amount, beneficiary_paid_amount,
 city, state, zip)
SELECT s.*
FROM cc_temp.claims_partd_staging s
JOIN cc_system.beneficiaries b ON s.beneficiary_id = b.beneficiary_id
JOIN cc_system.providers p ON s.provider_id = p.provider_id
JOIN cc_system.pharmacies ph ON s.pharmacy_id = ph.pharmacy_id
JOIN cc_system.ndc n ON s.ndc_code = n.ndc_code;