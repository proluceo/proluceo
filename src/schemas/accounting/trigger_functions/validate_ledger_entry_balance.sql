CREATE FUNCTION accounting.validate_ledger_entry_balance() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
	unbalanced_entries text;
BEGIN
	unbalanced_entries = string_agg(ledger_entry_id::text,',') FROM new_ledger_entries GROUP BY ledger_entry_id HAVING sum(amount) FILTER (WHERE direction='credit') IS DISTINCT FROM sum(amount) FILTER (WHERE direction='debit');
	IF unbalanced_entries IS NOT NULL THEN
		RAISE integrity_constraint_violation USING MESSAGE = format('ledger entries %s are not balanced', unbalanced_entries), SCHEMA = TG_TABLE_SCHEMA, TABLE = TG_TABLE_NAME, COLUMN = 'amount', HINT = 'Make sure the new entries are balanced, i.e. total credit = total debit';
	END IF;
	RETURN NULL;
END;
$$;

COMMENT ON FUNCTION accounting.validate_ledger_entry_balance() IS 'Validate that a ledger entry is balanced, i.e. total debit = total credit';

