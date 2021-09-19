Feature: Table accounting.accounts
  Scenario: Table should exists
    Given the sql path 'schemas:accounting:tables:accounts'
    Then the table 'accounting.accounts' should exists

