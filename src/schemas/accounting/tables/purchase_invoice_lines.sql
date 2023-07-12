-- depends_on: ["::schemas:common:tables:companies", "accounts", "purchase_invoices"]
CREATE TABLE accounting.purchase_invoice_lines (
    company_id integer NOT NULL,
    purchase_invoice_id uuid NOT NULL,
    account_number integer NOT NULL,
    amount numeric(10,2) NOT NULL DEFAULT 0,
    tax_rate numeric(4,2) NOT NULL DEFAULT 0,
    tax_account_number integer,
    tax_amount numeric(10,2) GENERATED ALWAYS AS (tax_rate/100 * amount) STORED NOT NULL,
    amount_with_tax numeric(10,2) GENERATED ALWAYS AS (amount + (tax_rate/100 * amount)) STORED NOT NULL
);

ALTER TABLE ONLY accounting.purchase_invoice_lines
    ADD CONSTRAINT purchase_invoice_lines_pkey PRIMARY KEY (purchase_invoice_id, account_number);

ALTER TABLE ONLY accounting.purchase_invoice_lines
    ADD CONSTRAINT purchase_invoice_lines_company_id_fkey FOREIGN KEY (company_id) REFERENCES common.companies(company_id);

ALTER TABLE accounting.purchase_invoice_lines
    ADD CONSTRAINT purchase_invoice_lines_account_fkey FOREIGN KEY (account_number, company_id)
    REFERENCES accounting.accounts ("number", company_id) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE accounting.purchase_invoice_lines
    ADD CONSTRAINT purchase_invoice_lines_tax_account_fkey FOREIGN KEY (tax_account_number, company_id)
    REFERENCES accounting.accounts ("number", company_id) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE accounting.purchase_invoice_lines
    ADD CONSTRAINT purchase_invoice_lines_purchase_invoice_fkey FOREIGN KEY (purchase_invoice_id)
    REFERENCES accounting.purchase_invoices (purchase_invoice_id) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE CASCADE;
