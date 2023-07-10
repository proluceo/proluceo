-- depends_on: ["::schemas:accounting:types:currency","::schemas:common:tables:companies"]

CREATE TABLE IF NOT EXISTS accounting.suppliers
(
    company_id integer NOT NULL,
    name text NOT NULL,
    invoices_in accounting.currency NOT NULL
);

ALTER TABLE ONLY accounting.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (company_id, name);

ALTER TABLE ONLY accounting.suppliers
    ADD CONSTRAINT suppliers_company_fk FOREIGN KEY (company_id) REFERENCES common.companies(company_id);


COMMENT ON TABLE accounting.suppliers
    IS 'Suppliers used in purchase invoices';