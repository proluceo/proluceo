CREATE TABLE sales.market_members
(
    company_id integer NOT NULL,
    name text NOT NULL,
    interactions jsonb NOT NULL DEFAULT '[]',
    PRIMARY KEY (company_id, name)
);


COMMENT ON TABLE sales.market_members
    IS 'Prospect, leads, customers, ...';