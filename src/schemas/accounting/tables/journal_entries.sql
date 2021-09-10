-- depends_on: ["::schemas:common:tables:companies","::schemas:accounting:trigger_functions:validate_account_exists", "::schemas:accounting:trigger_functions:validate_journal_entry_balance", "::schemas:accounting:types:journal_entry_direction"]
CREATE TABLE accounting.journal_entries (
    company_id integer NOT NULL,
    journal_entry_id integer NOT NULL,
    account_number integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    direction accounting.journal_entry_direction NOT NULL
);

ALTER TABLE ONLY accounting.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (company_id, journal_entry_id, account_number);

ALTER TABLE ONLY accounting.journal_entries
    ADD CONSTRAINT journal_entries_company_id_fkey FOREIGN KEY (company_id) REFERENCES common.companies(company_id);

CREATE CONSTRAINT TRIGGER journal_entry_validate_account AFTER INSERT OR UPDATE OF company_id, account_number ON accounting.journal_entries NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE FUNCTION accounting.validate_account_exists();
COMMENT ON TRIGGER journal_entry_validate_account ON accounting.journal_entries IS 'Validate that the account number exists in the chart.';

CREATE TRIGGER journal_entry_validate_balance_after_delete AFTER DELETE ON accounting.journal_entries REFERENCING OLD TABLE AS new_journal_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_journal_entry_balance();
COMMENT ON TRIGGER journal_entry_validate_balance_after_delete ON accounting.journal_entries IS 'Make sure that a new journal entry is balanced, i.e. total credit = total debit.';

CREATE TRIGGER journal_entry_validate_balance_after_insert AFTER INSERT ON accounting.journal_entries REFERENCING NEW TABLE AS new_journal_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_journal_entry_balance();
COMMENT ON TRIGGER journal_entry_validate_balance_after_insert ON accounting.journal_entries IS 'Make sure that a new journal entry is balanced, i.e. total credit = total debit.';


CREATE TRIGGER journal_entry_validate_balance_after_update AFTER UPDATE ON accounting.journal_entries REFERENCING NEW TABLE AS new_journal_entries FOR EACH STATEMENT EXECUTE FUNCTION accounting.validate_journal_entry_balance();
COMMENT ON TRIGGER journal_entry_validate_balance_after_update ON accounting.journal_entries IS 'Make sure that a new journal entry is balanced, i.e. total credit = total debit.';

