-- depends_on: ["::schemas:public:extensions:tuid", "::schemas:common:domains:email", "::schemas:public:extensions:libphonenumber"]
CREATE TABLE common.people
(
    person_id uuid NOT NULL DEFAULT public.tuid_generate(),
    first_name text NOT NULL,
    last_name text NOT NULL,
    work_email email,
    phone packed_phone_number,
    meta jsonb NOT NULL DEFAULT '{}',
    PRIMARY KEY (person_id),
    CONSTRAINT people_email_uniq UNIQUE (work_email)
        DEFERRABLE
);

COMMENT ON TABLE common.people
    IS 'Generic table inherited by all kind of people';