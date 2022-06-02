-- depends_on: ["::schemas:common:tables:companies", "accounts", "::schemas:accounting:trigger_functions:b64decode_attachment", "::schemas:public:extensions:tuid"]
CREATE TABLE accounting.purchase_invoices (
    purchase_invoice_id uuid NOT NULL DEFAULT tuid_generate(),
    company_id integer NOT NULL,
    issued_on date NOT NULL,
    supplier text NOT NULL,
    reference text,
    amount numeric(10,2) DEFAULT 0.0 NOT NULL,
    payment_account_number integer NOT NULL,
    paid_on date,
    attachment_blob bytea,
    attachment_present boolean NOT NULL GENERATED ALWAYS AS (attachment_blob IS NOT NULL) STORED
);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_pkey PRIMARY KEY (purchase_invoice_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_company_fk FOREIGN KEY (company_id) REFERENCES common.companies(company_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_account_number_fk FOREIGN KEY (payment_account_number, company_id)
    REFERENCES accounting.accounts ("number", company_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;

CREATE INDEX fki_purchase_invoices_account_number_fk
    ON accounting.purchase_invoices(payment_account_number, company_id);

CREATE TRIGGER b64decode_attachment
    BEFORE INSERT OR UPDATE OF attachment_blob
    ON accounting.purchase_invoices
    FOR EACH ROW
    EXECUTE FUNCTION accounting.b64decode_attachment();