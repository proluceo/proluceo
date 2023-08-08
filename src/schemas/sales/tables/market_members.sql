-- depends_on: ["::schemas:common:tables:companies"]
CREATE TABLE sales.market_members
(
    company_id integer NOT NULL REFERENCES common.companies,
    name text NOT NULL,
    PRIMARY KEY (company_id, name)
);

COMMENT ON TABLE sales.market_members
    IS 'Prospect, leads, customers, ...';