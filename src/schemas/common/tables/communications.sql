-- depends_on: ["::schemas:common:tables:companies", "::schemas:common:tables:people", "::schemas:common:types:mean_of_communication"]
CREATE TABLE common.communications
(
    company_id int NOT NULL REFERENCES common.companies,
    sender_id uuid NOT NULL REFERENCES common.people,
    recipient_id uuid NOT NULL REFERENCES common.people,
    happened_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mean common.mean_of_communication NOT NULL,
    meta jsonb NOT NULL DEFAULT '{}',
    PRIMARY KEY (company_id, sender_id, recipient_id, happened_at)
);

COMMENT ON TABLE common.people
    IS 'Generic table for interactions between people';