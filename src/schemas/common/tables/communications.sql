-- depends_on: ["::schemas:common:tables:companies", "::schemas:common:tables:people", "::schemas:common:types:mean_of_communication", "::schemas:common:functions:enforce_recipient_unicity", "::schemas:common:functions:check_recipient_reference"]
DROP TABLE common.communications CASCADE;
CREATE TABLE common.communications
(
    company_id int NOT NULL REFERENCES common.companies,
    sender_id uuid NOT NULL REFERENCES common.people,
    recipients_id uuid[] NOT NULL,
    happened_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mean common.mean_of_communication NOT NULL,
    meta jsonb NOT NULL DEFAULT '{}',
    PRIMARY KEY (company_id, sender_id, recipients_id, happened_at)
);

COMMENT ON TABLE common.people
    IS 'Generic table for interactions between people';

CREATE TRIGGER people_unique_recipients
    BEFORE INSERT OR UPDATE OF recipients_id
    ON common.communications
    FOR EACH ROW
    EXECUTE FUNCTION common.enforce_recipient_unicity();

CREATE CONSTRAINT TRIGGER b64decode_attachment
    AFTER INSERT OR UPDATE OF recipients_id
    ON common.communications
    DEFERRABLE
    FOR EACH ROW
    EXECUTE FUNCTION common.check_recipient_reference();