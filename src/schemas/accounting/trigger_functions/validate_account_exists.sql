CREATE FUNCTION accounting.validate_account_exists() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM accounting.accounts WHERE company_id=NEW.company_id AND "number"=NEW.account_number) THEN
		RAISE integrity_constraint_violation USING MESSAGE = format('Account %s doesn''t exists for company %s, table %s.%s', NEW.account_number, NEW.company_id, TG_TABLE_SCHEMA, TG_TABLE_NAME), SCHEMA = TG_TABLE_SCHEMA, TABLE = TG_TABLE_NAME, COLUMN = 'account_number', HINT = 'Create the accounts in the accouting.accounts table first';
	END IF;
	RETURN NULL;
END;
$$;

COMMENT ON FUNCTION accounting.validate_account_exists() IS 'Check if an account actually exists in the chart.';

