-- ============================================================
-- Aurora PostgreSQL DDL for schema: cc_sys
-- Generated from parquet files under
-- s3://cc3-s3-landing-bucket/input/
--
-- Column types inferred from parquet schemas:
--   large_string       -> VARCHAR(n)  sized to max observed length
--   int32              -> INTEGER
--   int64              -> BIGINT
--   double             -> DOUBLE PRECISION
--   bool               -> BOOLEAN
--   timestamp[us]      -> TIMESTAMP
--
-- NOT NULL is only applied to key columns (PK, FK, UNIQUE).
-- ============================================================

CREATE SCHEMA IF NOT EXISTS cc_sys;

-- ============================================================
-- Drop tables (in FK-dependency order)
-- ============================================================
DROP TABLE IF EXISTS cc_sys.claim_line_items CASCADE;
DROP TABLE IF EXISTS cc_sys.claims CASCADE;
DROP TABLE IF EXISTS cc_sys.bene_enrollments CASCADE;
DROP TABLE IF EXISTS cc_sys.provider_specialties CASCADE;
DROP TABLE IF EXISTS cc_sys.providers CASCADE;
DROP TABLE IF EXISTS cc_sys.beneficiaries CASCADE;

-- ============================================================
-- 1. beneficiaries  (source: beneficiaries.parquet, 10,000 rows)
-- ============================================================
CREATE TABLE cc_sys.beneficiaries (
    bene_id             VARCHAR(9)   NOT NULL,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    dob                 TIMESTAMP,
    gender              VARCHAR(1),
    address_line1       VARCHAR(100),
    city                VARCHAR(50),
    state               VARCHAR(2),
    zip_code            VARCHAR(5),
    phone               VARCHAR(15),
    email               VARCHAR(100),
    enrollment_status   VARCHAR(10),
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    CONSTRAINT pk_beneficiaries PRIMARY KEY (bene_id)
);

-- ============================================================
-- 2. providers  (source: providers.parquet, 10,000 rows)
-- ============================================================
CREATE TABLE cc_sys.providers (
    provider_id   VARCHAR(9)   NOT NULL,
    npi           VARCHAR(10)  NOT NULL,
    name          VARCHAR(100),
    type          VARCHAR(15),
    specialty     VARCHAR(5),
    tax_id        VARCHAR(9),
    address_line1 VARCHAR(100),
    city          VARCHAR(50),
    state         VARCHAR(2),
    zip_code      VARCHAR(5),
    phone         VARCHAR(15),
    active_flag   BOOLEAN,
    created_at    TIMESTAMP,
    updated_at    TIMESTAMP,
    CONSTRAINT pk_providers PRIMARY KEY (provider_id),
    CONSTRAINT uq_providers_npi UNIQUE (npi)
);

-- ============================================================
-- 3. claims  (source: claims.parquet, 100,000 rows)
-- ============================================================
CREATE TABLE cc_sys.claims (
    claim_id            VARCHAR(13)      NOT NULL,
    bene_id             VARCHAR(9)       NOT NULL,
    provider_id         VARCHAR(9)       NOT NULL,
    claim_type          VARCHAR(4),
    claim_status        VARCHAR(10),
    service_start_date  TIMESTAMP,
    service_end_date    TIMESTAMP,
    submit_date         TIMESTAMP,
    received_date       TIMESTAMP,
    adjudicated_date    TIMESTAMP,
    paid_date           TIMESTAMP,
    total_charge_cents  INTEGER,
    total_paid_cents    INTEGER,
    coinsurance_cents   INTEGER,
    copay_cents         INTEGER,
    deductible_cents    INTEGER,
    pos_code            VARCHAR(2),
    drg_code            VARCHAR(3),
    bill_type           VARCHAR(3),
    currency            VARCHAR(3),
    diagnosis_code1     VARCHAR(10),
    diagnosis_code2     VARCHAR(10),
    diagnosis_code3     VARCHAR(10),
    diagnosis_code4     VARCHAR(10),
    rendering_npi       VARCHAR(10),
    billing_npi         VARCHAR(10),
    facility_npi        VARCHAR(10),
    referral_npi        VARCHAR(10),
    provider_taxonomy   VARCHAR(10),
    in_network_flag     BOOLEAN,
    claim_source        VARCHAR(10),
    claim_priority      VARCHAR(10),
    original_claim_id   VARCHAR(13),
    corrected_flag      BOOLEAN,
    version_number      INTEGER,
    create_ts           TIMESTAMP,
    update_ts           TIMESTAMP,
    CONSTRAINT pk_claims PRIMARY KEY (claim_id),
    CONSTRAINT fk_claims_bene FOREIGN KEY (bene_id)
        REFERENCES cc_sys.beneficiaries (bene_id),
    CONSTRAINT fk_claims_provider FOREIGN KEY (provider_id)
        REFERENCES cc_sys.providers (provider_id)
);

-- ============================================================
-- 4. claim_line_items  (source: claim_line_items.parquet, 300,000 rows)
--    Composite PK: (claim_id, line_number, service_date)
-- ============================================================
CREATE TABLE cc_sys.claim_line_items (
    claim_id             VARCHAR(13)      NOT NULL,
    line_number          BIGINT           NOT NULL,
    service_date         TIMESTAMP        NOT NULL,
    procedure_code       VARCHAR(5),
    modifier1            VARCHAR(2),
    modifier2            VARCHAR(2),
    modifier3            VARCHAR(2),
    modifier4            VARCHAR(2),
    diagnosis_pointer1   INTEGER,
    diagnosis_pointer2   INTEGER,
    diagnosis_pointer3   INTEGER,
    diagnosis_pointer4   INTEGER,
    revenue_code         VARCHAR(4),
    ndc_code             VARCHAR(13),
    units                INTEGER,
    unit_price_cents     INTEGER,
    line_charge_cents    INTEGER,
    line_paid_cents      INTEGER,
    allowed_amount_cents INTEGER,
    rendering_npi        VARCHAR(10),
    billing_npi          VARCHAR(10),
    taxonomy_code        VARCHAR(10),
    place_of_service     VARCHAR(2),
    status               VARCHAR(10),
    drug_quantity        DOUBLE PRECISION,
    drug_measure         VARCHAR(5),
    line_note            VARCHAR(50),
    denial_reason_code   VARCHAR(10),
    create_ts            TIMESTAMP,
    update_ts            TIMESTAMP,
    CONSTRAINT pk_claim_line_items PRIMARY KEY (claim_id, line_number, service_date),
    CONSTRAINT fk_claim_lines_claim FOREIGN KEY (claim_id)
        REFERENCES cc_sys.claims (claim_id)
);

-- ============================================================
-- 5. bene_enrollments  (source: bene_enrollments.parquet, 20,000 rows)
--    Composite PK: (bene_id, plan_id, effective_date, termination_date)
-- ============================================================
CREATE TABLE cc_sys.bene_enrollments (
    bene_id          VARCHAR(9)   NOT NULL,
    plan_id          VARCHAR(5)   NOT NULL,
    effective_date   TIMESTAMP    NOT NULL,
    termination_date TIMESTAMP    NOT NULL,
    coverage_type    VARCHAR(10),
    metal_level      VARCHAR(10),
    payer            VARCHAR(10),
    created_at       TIMESTAMP,
    CONSTRAINT pk_bene_enrollments PRIMARY KEY (bene_id, plan_id, effective_date, termination_date),
    CONSTRAINT fk_enrollments_bene FOREIGN KEY (bene_id)
        REFERENCES cc_sys.beneficiaries (bene_id)
);

-- ============================================================
-- 6. provider_specialties  (source: provider_specialties.parquet, 8,000 rows)
--    Composite PK: (provider_id, specialty_code, effective_date)
-- ============================================================
CREATE TABLE cc_sys.provider_specialties (
    provider_id      VARCHAR(9)   NOT NULL,
    specialty_code   VARCHAR(5)   NOT NULL,
    effective_date   TIMESTAMP    NOT NULL,
    termination_date TIMESTAMP,
    CONSTRAINT pk_provider_specialties PRIMARY KEY (provider_id, specialty_code, effective_date),
    CONSTRAINT fk_prov_spec_provider FOREIGN KEY (provider_id)
        REFERENCES cc_sys.providers (provider_id)
);
