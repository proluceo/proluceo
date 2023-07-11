-- depends_on: [::schemas:accounting:types:ledger_entry_direction"]
CREATE FUNCTION accounting.handle_ledger_negative_amounts() RETURNS trigger
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    IF NEW.amount < 0 THEN
        CASE NEW.direction
        WHEN 'credit' THEN
            NEW.direction = 'debit';
        WHEN 'debit' THEN
            NEW.direction = 'credit';
        END CASE;
        NEW.amount = abs(NEW.amount);
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION accounting.handle_ledger_negative_amounts() IS 'Turn a negative amount positive and switch direction in a ledger entry';