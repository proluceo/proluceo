-- depends_on: ["::schemas:accounting:types:currency","::schemas:common:tables:companies","::schemas:common:tables:documents","accounts", "::schemas:common:functions:tuid6","::schemas:accounting:tables:suppliers","::schemas:common:trigger_functions:mark_document_as_processed", "::schemas:accounting:trigger_functions:restrict_purchase_invoice_delete", "::schemas:public:extensions:fsm"]
CREATE TABLE accounting.purchase_invoices (
    purchase_invoice_id uuid NOT NULL DEFAULT common.tuid6(),
    company_id integer NOT NULL,
    document_id uuid,
    issued_on date NOT NULL,
    currency accounting.currency NOT NULL,
    supplier_name text NOT NULL,
    reference text,
    payment_account_number integer NOT NULL,
    paid_on date,
    meta jsonb NOT NULL DEFAULT '{}'
);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_pkey PRIMARY KEY (purchase_invoice_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_company_fk FOREIGN KEY (company_id) REFERENCES common.companies(company_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_document_fk FOREIGN KEY (document_id) REFERENCES common.documents(document_id);

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_account_number_fk FOREIGN KEY (payment_account_number, company_id)
    REFERENCES accounting.accounts ("number", company_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;

ALTER TABLE ONLY accounting.purchase_invoices
    ADD CONSTRAINT purchase_invoices_supplier_name_fk FOREIGN KEY (supplier_name, company_id)
    REFERENCES accounting.suppliers ("name", company_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    NOT VALID;

CREATE INDEX fki_purchase_invoices_account_number_fk
    ON accounting.purchase_invoices(payment_account_number, company_id);

CREATE TRIGGER purchase_invoice_mark_document_processed
    AFTER INSERT
    ON accounting.purchase_invoices
    FOR EACH ROW
    EXECUTE FUNCTION common.mark_document_as_processed();

COMMENT ON TRIGGER purchase_invoice_mark_document_processed ON accounting.purchase_invoices
    IS 'Mark attached document as processed';

CREATE TRIGGER purchase_invoice_restrict_delete
    BEFORE DELETE
    ON accounting.purchase_invoices
    FOR EACH ROW
    EXECUTE FUNCTION accounting.restrict_purchase_invoice_delete();


-- Add finite state machine
SELECT fsm.add_to_table('accounting.purchase_invoices');
SELECT fsm.add_transition('accounting.purchase_invoices', 'start', 'send_to_ledger', 'sent_to_ledger');
