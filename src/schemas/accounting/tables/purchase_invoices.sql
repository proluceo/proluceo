-- depends_on: ["::schemas:common:tables:companies", "::schemas:accounting:types:purchase_invoice_line"]
CREATE TABLE accounting.purchase_invoices (
    purchase_invoice_id integer NOT NULL,
    company_id integer NOT NULL,
    issued_on date NOT NULL,
    supplier text NOT NULL,
    reference text,
    amount numeric(10,2) DEFAULT 0.0 NOT NULL,
    payment_account integer NOT NULL,
    paid_on date,
    attachment bytea,
    body accounting.purchase_invoice_line[]
);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_pkey PRIMARY KEY (purchase_invoice_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_company_fk FOREIGN KEY (company_id) REFERENCES common.companies(company_id);
