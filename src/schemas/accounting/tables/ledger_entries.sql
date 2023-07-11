-- depends_on: ["::schemas:common:tables:companies", "::schemas:accounting:trigger_functions:validate_ledger_entry_balance", "::schemas:accounting:types:ledger_entry_direction", "::schemas:common:tables:companies", "accounts"]
CREATE TABLE accounting.ledger_entries (
    company_id integer NOT NULL,
    ledger_entry_id uuid NOT NULL,
    account_number integer NOT NULL,
    position date,
    amount numeric(10,2) NOT NULL,
    direction accounting.ledger_entry_direction NOT NULL
);

ALTER TABLE ONLY accounting.ledger_entries
    ADD CONSTRAINT ledger_entries_pkey PRIMARY KEY (ledger_entry_id, account_number);

ALTER TABLE ONLY accounting.ledger_entries
    ADD CONSTRAINT ledger_entries_company_id_fkey FOREIGN KEY (company_id) REFERENCES common.companies(company_id);

ALTER TABLE accounting.ledger_entries
    ADD CONSTRAINT ledger_entries_account_fkey FOREIGN KEY (account_number, company_id)
    REFERENCES accounting.accounts ("number", company_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

CREATE TRIGGER ledger_entry_validate_balance_after_delete AFTER DELETE ON accounting.ledger_entries REFERENCING OLD TABLE AS new_ledger_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_ledger_entry_balance();
COMMENT ON TRIGGER ledger_entry_validate_balance_after_delete ON accounting.ledger_entries IS 'Make sure that a new ledger entry is balanced, i.e. total credit = total debit.';

CREATE TRIGGER ledger_entry_validate_balance_after_insert AFTER INSERT ON accounting.ledger_entries REFERENCING NEW TABLE AS new_ledger_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_ledger_entry_balance();
COMMENT ON TRIGGER ledger_entry_validate_balance_after_insert ON accounting.ledger_entries IS 'Make sure that a new ledger entry is balanced, i.e. total credit = total debit.';

CREATE TRIGGER ledger_entry_validate_balance_after_update AFTER UPDATE ON accounting.ledger_entries REFERENCING NEW TABLE AS new_ledger_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_ledger_entry_balance();
COMMENT ON TRIGGER ledger_entry_validate_balance_after_update ON accounting.ledger_entries IS 'Make sure that a new ledger entry is balanced, i.e. total credit = total debit.';

CREATE TRIGGER ledger_entry_handle_negative_amount_before_update_insert BEFORE INSERT OR UPDATE OF amount, direction ON accounting.ledger_entries FOR EACH ROW EXECUTE FUNCTION accounting.handle_ledger_negative_amounts();
COMMENT ON TRIGGER ledger_entry_handle_negative_amount_before_update_insert ON accounting.ledger_entries IS 'Handle negative amounts by switching direction';