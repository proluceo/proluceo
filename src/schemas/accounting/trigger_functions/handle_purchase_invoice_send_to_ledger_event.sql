CREATE FUNCTION accounting.handle_purchase_invoice_send_to_ledger_event() RETURNS trigger
    LANGUAGE plpgsql VOLATILE
    AS $$
BEGIN
    IF NEW.fsm_current_state IS DISTINCT FROM OLD.fsm_current_state AND NEW.fsm_current_state = 'sent_to_ledger' THEN
        PERFORM accounting.send_purchase_invoice_to_ledger(NEW.purchase_invoice_id);
    END IF;
    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION accounting.handle_purchase_invoice_send_to_ledger_event() IS 'Send purchase invoice to ledger on matching event';