Feature: Table accounting.purchase_invoice_lines
  Scenario: Table should exists
    Given the sql path 'schemas:accounting:tables:purchase_invoice_lines'
    Then the table 'accounting.purchase_invoice_lines' should exists

