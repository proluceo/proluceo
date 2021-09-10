-- depends_on: ["::schemas:accounting:tables:purchase_invoices"]
CREATE VIEW api.purchase_invoices AS
 SELECT purchase_invoices.purchase_invoice_id,
    purchase_invoices.company_id,
    purchase_invoices.issued_on,
    purchase_invoices.supplier,
    purchase_invoices.reference,
    purchase_invoices.amount,
    purchase_invoices.payment_account,
    purchase_invoices.paid_on,
    purchase_invoices.attachment
   FROM accounting.purchase_invoices;
