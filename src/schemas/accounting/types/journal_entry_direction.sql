CREATE TYPE accounting.journal_entry_direction AS ENUM (
    'credit',
    'debit'
);

COMMENT ON TYPE accounting.journal_entry_direction IS 'Small enum to mark a journal_entry as credit or debit';

