------------------------------------------------------------------------------
--changeset murthy:create-stage-tables context:ddl
-- Staging tables (no PK/FK/unique constraints)
CREATE TABLE IF NOT EXISTS cc_temp.beneficiaries (LIKE cc_system.beneficiaries);
CREATE TABLE IF NOT EXISTS cc_temp.providers (LIKE cc_system.providers);
CREATE TABLE IF NOT EXISTS cc_temp.claims (LIKE cc_system.claims);
CREATE TABLE IF NOT EXISTS cc_temp.claim_line_items (LIKE cc_system.claim_line_items);
CREATE TABLE IF NOT EXISTS cc_temp.bene_enrollments (LIKE cc_system.bene_enrollments);
CREATE TABLE IF NOT EXISTS cc_temp.provider_specialties (LIKE cc_system.provider_specialties);
--rollback
-- DROP TABLE IF EXISTS cc_temp.provider_specialties;
-- DROP TABLE IF EXISTS cc_temp.bene_enrollments;
-- DROP TABLE IF EXISTS cc_temp.claim_line_items;
-- DROP TABLE IF EXISTS cc_temp.claims;
-- DROP TABLE IF EXISTS cc_temp.providers;
-- DROP TABLE IF EXISTS cc_temp.beneficiaries;

------------------------------------------------------------------------------
--changeset murthy:truncate-stage context:data-load
TRUNCATE cc_temp.beneficiaries;
TRUNCATE cc_temp.providers;
TRUNCATE cc_temp.claims;
TRUNCATE cc_temp.claim_line_items;
TRUNCATE cc_temp.bene_enrollments;
TRUNCATE cc_temp.provider_specialties;
--rollback /* no-op */

------------------------------------------------------------------------------
--changeset murthy:stage-load-beneficiaries context:data-load runInTransaction:false
-- Import from your S3 path and column list
SELECT aws_s3.table_import_from_s3(
  'cc_temp.beneficiaries',
  'bene_id,first_name,last_name,dob,gender,address_line1,city,state,zip_code,phone,email,enrollment_status,created_at,updated_at',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/beneficiaries.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.beneficiaries;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:stage-load-providers context:data-load runInTransaction:false
SELECT aws_s3.table_import_from_s3(
  'cc_temp.providers',
  'provider_id,npi,name,type,specialty,tax_id,address_line1,city,state,zip_code,phone,active_flag,created_at,updated_at',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/providers.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.providers;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:stage-load-claims context:data-load runInTransaction:false
SELECT aws_s3.table_import_from_s3(
  'cc_temp.claims',
  'claim_id,bene_id,provider_id,claim_type,claim_status,service_start_date,service_end_date,submit_date,received_date,adjudicated_date,paid_date,total_charge_cents,total_paid_cents,coinsurance_cents,copay_cents,deductible_cents,pos_code,drg_code,bill_type,currency,diagnosis_code1,diagnosis_code2,diagnosis_code3,diagnosis_code4,rendering_npi,billing_npi,facility_npi,referral_npi,provider_taxonomy,in_network_flag,claim_source,claim_priority,original_claim_id,corrected_flag,version_number,create_ts,update_ts',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/claims.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.claims;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:stage-load-claim-line-items context:data-load runInTransaction:false
SELECT aws_s3.table_import_from_s3(
  'cc_temp.claim_line_items',
  'claim_id,line_number,service_date,procedure_code,modifier1,modifier2,modifier3,modifier4,diagnosis_pointer1,diagnosis_pointer2,diagnosis_pointer3,diagnosis_pointer4,revenue_code,ndc_code,units,unit_price_cents,line_charge_cents,line_paid_cents,allowed_amount_cents,rendering_npi,billing_npi,taxonomy_code,place_of_service,status,drug_quantity,drug_measure,line_note,denial_reason_code,create_ts,update_ts',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/claim_line_items.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.claim_line_items;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:stage-load-bene-enrollments context:data-load runInTransaction:false
SELECT aws_s3.table_import_from_s3(
  'cc_temp.bene_enrollments',
  'bene_id,plan_id,effective_date,termination_date,coverage_type,metal_level,payer,created_at',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/bene_enrollments.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.bene_enrollments;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:stage-load-provider-specialties context:data-load runInTransaction:false
SELECT aws_s3.table_import_from_s3(
  'cc_temp.provider_specialties',
  'provider_id,specialty_code,effective_date,termination_date',
  '(format csv, header true)',
  aws_commons.create_s3_uri('cc3-s3-landing-bucket','tmp/csv_files/provider_specialties.csv','us-east-1')
);
--rollback TRUNCATE cc_temp.provider_specialties;
-- (S3 path & columns from your script) 

------------------------------------------------------------------------------
--changeset murthy:validate-stage-counts context:validate
-- Basic sanity checks: non-zero counts and referential checks you care about
-- Fail the changeset by raising an exception if counts don't meet expectations
--changeset murthy:validate-stage-counts context:validate splitStatements:false

-- DO $$
-- DECLARE
--   v_beneficiaries BIGINT;
--   v_providers BIGINT;
-- BEGIN
--   SELECT COUNT(*) INTO v_beneficiaries FROM cc_temp.beneficiaries; -- your file uses cc_temp
--   SELECT COUNT(*) INTO v_providers FROM cc_temp.providers;

--   IF v_beneficiaries = 0 THEN
--     RAISE EXCEPTION 'Stage validation failed: beneficiaries count is 0';
--   END IF;

--   IF v_providers = 0 THEN
--     RAISE EXCEPTION 'Stage validation failed: providers count is 0';
--   END IF;
-- END
-- $$ LANGUAGE plpgsql;

--rollback /* no-op */

------------------------------------------------------------------------------

--changeset murthy:promote-full-refresh context:promote
-- Full refresh pattern: TRUNCATE final then INSERT from stage/temp

-- Group TRUNCATEs by FK relationships (no CASCADE)

TRUNCATE cc_system.claims CASCADE;
TRUNCATE cc_system.providers CASCADE;
TRUNCATE cc_system.beneficiaries CASCADE;


-- Now load from staging/temp (you are using cc_temp as staging in this file)
INSERT INTO cc_system.beneficiaries
SELECT * FROM cc_temp.beneficiaries;

INSERT INTO cc_system.providers
SELECT * FROM cc_temp.providers;

INSERT INTO cc_system.claims
SELECT * FROM cc_temp.claims;

INSERT INTO cc_system.claim_line_items
SELECT * FROM cc_temp.claim_line_items;

INSERT INTO cc_system.bene_enrollments
SELECT * FROM cc_temp.bene_enrollments;

INSERT INTO cc_system.provider_specialties
SELECT * FROM cc_temp.provider_specialties;
--rollback /* Optionally restore from a backup table if you keep snapshots */

------------------------------------------------------------------------------
--changeset murthy:analyze context:promote
-- VACUUM (ANALYZE);
DROP TABLE IF EXISTS cc_temp.provider_specialties;
DROP TABLE IF EXISTS cc_temp.bene_enrollments;
DROP TABLE IF EXISTS cc_temp.claim_line_items;
DROP TABLE IF EXISTS cc_temp.claims;
DROP TABLE IF EXISTS cc_temp.providers;
DROP TABLE IF EXISTS cc_temp.beneficiaries;
--rollback /* no-op */
