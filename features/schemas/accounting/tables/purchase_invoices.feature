Feature: Table accounting.purchase_invoices
  Scenario: Table should exists
    Given the sql path 'schemas:accounting:tables:purchase_invoices'
    Then the table 'accounting.purchase_invoices' should exists

