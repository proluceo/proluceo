-- depends_on: ["string_to_chars", "::schemas:public:extensions:ltree", "::schemas:public:aggregates:path_agg"]
CREATE FUNCTION accounting.send_purchase_invoice_to_ledger(invoice_to_send_id uuid) RETURNS boolean
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    functional_currency accounting.currency;
    invoice_currency accounting.currency;
    invoice_date date;
    created_ledger_entry_id uuid;
    invoice_metadata jsonb;
    rate numeric;
BEGIN
    -- Handles eventual currency conversion
    SELECT currency, issued_on, meta  INTO STRICT invoice_currency, invoice_date, invoice_metadata FROM accounting.purchase_invoices WHERE purchase_invoice_id=invoice_to_send_id;
    functional_currency = common.get_company_setting(1, '{currencies, functional}');
    IF functional_currency != invoice_currency THEN
        rate = oxr.get_historical_rate(functional_currency, invoice_currency, invoice_date);
    ELSE
        rate = 1;
    END IF;

    INSERT INTO accounting.ledger_entries
        SELECT * FROM accounting.ledger_entries_from_purchase_invoice(invoice_to_send_id, rate)
        RETURNING ledger_entries.ledger_entry_id INTO created_ledger_entry_id;

    invoice_metadata = invoice_metadata || jsonb_build_object(
                                                'ledger_entry_id', created_ledger_entry_id,
                                                'sent_to_ledger_at', CURRENT_TIMESTAMP(0),
                                                'rate', rate
                                            );
    UPDATE accounting.purchase_invoices SET meta = invoice_metadata WHERE purchase_invoices.purchase_invoice_id = invoice_to_send_id;
END
$$;

COMMENT ON FUNCTION accounting.send_purchase_invoice_to_ledger(purchase_invoice_id uuid) IS 'Create ledger entries from purchase_invoice_lines';