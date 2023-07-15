CREATE FUNCTION accounting.restrict_purchase_invoice_delete() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    IF NEW.fsm_current_state = 'sent_to_ledger' THEN
        RAISE 'Cannot delete purchase invoice that has been sent to the ledger';
    END IF;
    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION accounting.restrict_purchase_invoice_delete() IS 'Prevent deleting purchase invoices that have been sent to the ledger';