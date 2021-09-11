-- depends_on: ["::schemas:common:tables:companies", "::schemas:accounting:functions:account_number_to_path", "::schemas:public:extensions:ltree"]
CREATE TABLE accounting.accounts (
    company_id integer NOT NULL,
    number integer NOT NULL,
    label text NOT NULL,
    path public.ltree GENERATED ALWAYS AS (accounting.account_number_to_path(number)) STORED NOT NULL
);

ALTER TABLE ONLY accounting.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (company_id, number);

ALTER TABLE ONLY accounting.accounts
    ADD CONSTRAINT accounts_company_fk FOREIGN KEY (company_id) REFERENCES common.companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE;
