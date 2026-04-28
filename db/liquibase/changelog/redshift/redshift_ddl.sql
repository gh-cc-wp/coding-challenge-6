-- ============================================================
-- Redshift DDL for cc_system schema
-- Source: s3://cc-s3-landing-bucket/input/
-- ============================================================

CREATE SCHEMA IF NOT EXISTS cc_system;

-- ----------------------------------------------------------
-- beneficiaries
-- ----------------------------------------------------------
DROP TABLE IF EXISTS cc_system.beneficiaries CASCADE;
CREATE TABLE cc_system.beneficiaries (
    beneficiary_id         VARCHAR(20)  NOT NULL,
    first_name             VARCHAR(50),
    last_name              VARCHAR(50),
    dob                    DATE,
    gender                 VARCHAR(1),
    address                VARCHAR(100),
    city                   VARCHAR(50),
    state                  VARCHAR(2),
    zip                    VARCHAR(10),
    phone                  VARCHAR(20),
    flag_over_prescribed   VARCHAR(1),
    PRIMARY KEY (beneficiary_id)
);

-- ----------------------------------------------------------
-- providers
-- ----------------------------------------------------------
DROP TABLE IF EXISTS cc_system.providers CASCADE;
CREATE TABLE cc_system.providers (
    provider_id            VARCHAR(20)  NOT NULL,
    npi                    VARCHAR(20),
    provider_name          VARCHAR(100),
    specialty              VARCHAR(50),
    address                VARCHAR(100),
    city                   VARCHAR(50),
    state                  VARCHAR(2),
    zip                    VARCHAR(10),
    phone                  VARCHAR(20),
    flag_high_prescriber   VARCHAR(1),
    PRIMARY KEY (provider_id)
);

-- ----------------------------------------------------------
-- pharmacies
-- ----------------------------------------------------------
DROP TABLE IF EXISTS cc_system.pharmacies CASCADE;
CREATE TABLE cc_system.pharmacies (
    pharmacy_id    VARCHAR(20)  NOT NULL,
    pharmacy_name  VARCHAR(100),
    address        VARCHAR(100),
    city           VARCHAR(50),
    state          VARCHAR(2),
    zip            VARCHAR(10),
    phone          VARCHAR(20),
    PRIMARY KEY (pharmacy_id)
);

-- ----------------------------------------------------------
-- ndc (National Drug Code)
-- ----------------------------------------------------------
DROP TABLE IF EXISTS cc_system.ndc CASCADE;
CREATE TABLE cc_system.ndc (
    ndc_code              VARCHAR(20)  NOT NULL,
    drug_name             VARCHAR(100),
    strength_mg_per_unit  DECIMAL(10,2),
    dosage_form           VARCHAR(20),
    opioid_flag           VARCHAR(1),
    mme_per_unit          DECIMAL(10,2),
    PRIMARY KEY (ndc_code)
);

-- ----------------------------------------------------------
-- claims_partd
-- ----------------------------------------------------------
DROP TABLE IF EXISTS cc_system.claims_partd CASCADE;
CREATE TABLE cc_system.claims_partd (
    claim_id               VARCHAR(20)  NOT NULL,
    beneficiary_id         VARCHAR(20)  NOT NULL,
    provider_id            VARCHAR(20)  NOT NULL,
    pharmacy_id            VARCHAR(20)  NOT NULL,
    ndc_code               VARCHAR(20)  NOT NULL,
    date_of_service        DATE,
    quantity_dispensed      INTEGER,
    days_supply            INTEGER,
    total_mme              DECIMAL(10,2),
    claim_amount           DECIMAL(10,2),
    beneficiary_paid_amount DECIMAL(10,2),
    city                   VARCHAR(50),
    state                  VARCHAR(2),
    zip                    VARCHAR(10),
    PRIMARY KEY (claim_id),
    FOREIGN KEY (beneficiary_id) REFERENCES cc_system.beneficiaries(beneficiary_id),
    FOREIGN KEY (provider_id)    REFERENCES cc_system.providers(provider_id),
    FOREIGN KEY (pharmacy_id)    REFERENCES cc_system.pharmacies(pharmacy_id),
    FOREIGN KEY (ndc_code)       REFERENCES cc_system.ndc(ndc_code)
);
