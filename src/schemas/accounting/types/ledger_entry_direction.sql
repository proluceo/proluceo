CREATE TYPE accounting.ledger_entry_direction AS ENUM (
    'credit',
    'debit'
);

COMMENT ON TYPE accounting.ledger_entry_direction IS 'Small enum to mark a ledger_entry as credit or debit';

