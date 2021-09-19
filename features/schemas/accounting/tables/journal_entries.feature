Feature: Table accounting.journal_entries
  Scenario: Table should exists
    Given the sql path 'schemas:accounting:tables:journal_entries'
    Then the table 'accounting.journal_entries' should exists

