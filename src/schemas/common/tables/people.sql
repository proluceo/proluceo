-- depends_on: ["::schemas:common:tables:companies", "::schemas:common:functions:tuid6", "::schemas:common:domains:email_address", "::schemas:public:extensions:libphonenumber"]
CREATE TABLE common.people
(
    company_id int NOT NULL REFERENCES common.companies,
    person_id uuid NOT NULL DEFAULT common.tuid6(),
    first_name text NOT NULL,
    last_name text NOT NULL,
    work_email common.email_address,
    phone packed_phone_number,
    meta jsonb NOT NULL DEFAULT '{}',
    PRIMARY KEY (person_id),
    CONSTRAINT people_email_uniq UNIQUE (work_email)
        DEFERRABLE
);

COMMENT ON TABLE common.people
    IS 'Generic table inherited by all kind of people';