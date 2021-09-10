CREATE TABLE common.companies (
    company_id serial NOT NULL,
    name text NOT NULL
);

ALTER TABLE ONLY common.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (company_id);
