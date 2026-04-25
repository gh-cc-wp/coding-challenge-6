-- ============================================================
-- Redshift DDL for schema: cc_system tables
-- Source: s3://cc5-s3-landing-bucket/input/
-- ============================================================

CREATE SCHEMA IF NOT EXISTS cc_system;

-- ============================================================
-- Table: plans (source: plans.csv)
-- ============================================================
DROP TABLE IF EXISTS cc_system.plans CASCADE;
CREATE TABLE cc_system.plans (
    plan_id        VARCHAR(10)  NOT NULL,
    plan_name      VARCHAR(100),
    pbp_id         VARCHAR(10),
    contract_id    VARCHAR(10),
    segment_id     VARCHAR(5),
    plan_type      VARCHAR(10),
    service_area   VARCHAR(100),
    state          VARCHAR(2),
    PRIMARY KEY (plan_id)
);

-- ============================================================
-- Table: beneficiaries (source: beneficiaries.csv)
-- ============================================================
DROP TABLE IF EXISTS cc_system.beneficiaries CASCADE;
CREATE TABLE cc_system.beneficiaries (
    bene_id           VARCHAR(10)  NOT NULL,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    gender            VARCHAR(1),
    dob               DATE,
    zip_code          VARCHAR(10),
    county            VARCHAR(100),
    state             VARCHAR(2),
    plan_id           VARCHAR(10),
    effective_date    DATE,
    termination_date  DATE,
    PRIMARY KEY (bene_id),
    FOREIGN KEY (plan_id) REFERENCES cc_system.plans (plan_id)
);

-- ============================================================
-- Table: pharmacies (source: pharmacies.csv)
-- ============================================================
DROP TABLE IF EXISTS cc_system.pharmacies CASCADE;
CREATE TABLE cc_system.pharmacies (
    pharmacy_id    VARCHAR(10)  NOT NULL,
    ncpdp_id       BIGINT,
    pharmacy_name  VARCHAR(100),
    zip_code       VARCHAR(10),
    county         VARCHAR(100),
    state          VARCHAR(2),
    PRIMARY KEY (pharmacy_id)
);

-- ============================================================
-- Table: providers (source: providers.csv)
-- ============================================================
DROP TABLE IF EXISTS cc_system.providers CASCADE;
CREATE TABLE cc_system.providers (
    provider_id    VARCHAR(10)  NOT NULL,
    npi            BIGINT,
    provider_name  VARCHAR(100),
    specialty      VARCHAR(50),
    zip_code       VARCHAR(10),
    county         VARCHAR(100),
    state          VARCHAR(2),
    PRIMARY KEY (provider_id)
);

-- ============================================================
-- Table: claims (source: claims.csv)
-- ============================================================
DROP TABLE IF EXISTS cc_system.claims CASCADE;
CREATE TABLE cc_system.claims (
    claim_id               VARCHAR(10)    NOT NULL,
    claim_type_code        VARCHAR(5),
    claim_status           VARCHAR(10),
    submitted_date         DATE,
    adjudicated_date       DATE,
    bene_id                VARCHAR(10),
    provider_id            VARCHAR(10),
    plan_id                VARCHAR(10),
    pharmacy_id            VARCHAR(10),
    ndc11                  VARCHAR(11),
    rx_number              VARCHAR(10),
    fill_number            INTEGER,
    days_supply            INTEGER,
    quantity_dispensed      INTEGER,
    ingredient_cost        DECIMAL(10,2),
    dispensing_fee          DECIMAL(10,2),
    patient_pay            DECIMAL(10,2),
    plan_pay               DECIMAL(10,2),
    total_submitted_amount DECIMAL(10,2),
    total_paid_amount      DECIMAL(10,2),
    PRIMARY KEY (claim_id),
    FOREIGN KEY (bene_id)     REFERENCES cc_system.beneficiaries (bene_id),
    FOREIGN KEY (provider_id) REFERENCES cc_system.providers (provider_id),
    FOREIGN KEY (plan_id)     REFERENCES cc_system.plans (plan_id),
    FOREIGN KEY (pharmacy_id) REFERENCES cc_system.pharmacies (pharmacy_id)
);

-- ============================================================
-- Table: approved_drugs (source: v1/v2/v3_approved_drugs.json)
-- ============================================================
DROP TABLE IF EXISTS cc_system.approved_drugs CASCADE;
CREATE TABLE cc_system.approved_drugs (
    version       VARCHAR(5)   NOT NULL,
    source        VARCHAR(50),
    as_of_date    DATE,
    approved_ndc  VARCHAR(11)  NOT NULL,
    PRIMARY KEY (version, approved_ndc)
);
