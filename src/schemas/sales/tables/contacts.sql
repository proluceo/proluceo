-- depends_on: ["::schemas:sales:tables:market_members", "::schemas:common:tables:people"]
CREATE TABLE sales.contacts
(
    market_member_name text NOT NULL,
    CONSTRAINT contacts_market_member_fk FOREIGN KEY (market_member_name, company_id)
    REFERENCES sales.market_members (name, company_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID
)
    INHERITS (common.people);

COMMENT ON TABLE sales.contacts
    IS 'Market member people of contact';