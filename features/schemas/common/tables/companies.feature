Feature: Table common.companies
  Scenario: Table should exists
    Given the sql path 'schemas:common:tables:companies'
    Then the table 'common.companies' should exists

