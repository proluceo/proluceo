CREATE FUNCTION common.enforce_recipient_unicity() RETURNS trigger
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    NEW.recipient_ids = array_agg(DISTINCT unnest) FROM unnest(NEW.recipient_id);
END;
$$;

COMMENT ON FUNCTION common.check_recipient_unicity()
    IS 'Enforce unicity of recipients in emails';