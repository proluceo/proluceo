-- depends_on: ["::schemas:common:tables:companies", "::schemas:common:trigger_functions:b64decode_attachment", "::schemas:public:extensions:tuid"]
CREATE TABLE IF NOT EXISTS common.documents
(
    company_id integer NOT NULL,
    document_id uuid NOT NULL DEFAULT public.tuid_generate(),
    meta jsonb NOT NULL DEFAULT '{}'::jsonb,
    attachment_blob bytea,
    attachment_present boolean NOT NULL GENERATED ALWAYS AS ((attachment_blob IS NOT NULL)) STORED,
    attachment_hash bytea NOT NULL GENERATED ALWAYS AS (sha256(attachment_blob)) STORED,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    processed boolean NOT NULL DEFAULT false,
    CONSTRAINT documents_pkey PRIMARY KEY (document_id),
    CONSTRAINT documents_unique_hash UNIQUE (attachment_hash),
    CONSTRAINT documents_company_id_fkey FOREIGN KEY (company_id)
        REFERENCES common.companies (company_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TRIGGER b64decode_attachment
    BEFORE INSERT OR UPDATE OF attachment_blob
    ON common.documents
    FOR EACH ROW
    EXECUTE FUNCTION common.b64decode_attachment();


COMMENT ON TABLE common.documents
    IS 'Inbox for various documents to be processed';

COMMENT ON COLUMN common.documents.attachment_hash
    IS 'SHA256 hash of attachment blob';