CREATE FUNCTION common.mark_document_as_processed() RETURNS trigger
    LANGUAGE plpgsql VOLATILE
    AS $$
BEGIN
    IF NEW.document_id IS NOT NULL THEN
	    UPDATE common.documents SET processed=true WHERE document_id=NEW.document_id;
    END IF;
    RETURN NULL;
END;
$$;

