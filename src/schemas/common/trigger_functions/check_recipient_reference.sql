CREATE FUNCTION common.check_recipient_reference() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    IF count(*) != array_length(NEW.recipient_id,1) FROM common.people WHERE company_id=NEW.company_id AND person_id =ANY (NEW.recipient_id) THEN
        RAISE 'Reference error: recipients not found in people table.';
    END IF;
END;
$$;

COMMENT ON FUNCTION common.check_recipient_reference()
    IS 'Implement array reference, until supported by postgres';