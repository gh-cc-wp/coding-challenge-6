Feature: Redshift Validation
  Verify Liquibase migrations and data in cc_system schema

  Scenario: Verify databasechangelog exists
    Given I am connected to Redshift
    When I query the databasechangelog table
    Then it should contain migration records

  Scenario: Verify cc_system tables exist
    Given I am connected to Redshift
    When I count tables in cc_system schema
    Then I should see at least 2 tables

  Scenario: Verify cc_system tables have data
    Given I am connected to Redshift
    When I count rows in cc_system tables
    Then each table should have records
