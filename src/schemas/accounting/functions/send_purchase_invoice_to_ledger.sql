-- depends_on: ["::schemas:public:extensions:tuid", "::schemas:accounting:tables:purchase_invoices"]
CREATE FUNCTION accounting.send_purchase_invoice_to_ledger(invoice_to_send accounting.purchase_invoices) RETURNS void
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    functional_currency accounting.currency;
    output_ledger_entry_id uuid;
    rate numeric;
BEGIN
    -- Handles eventual currency conversion
    functional_currency = common.get_company_setting(1, '{currencies, functional}');
    IF functional_currency != invoice_to_send.currency THEN
        rate = oxr.get_historical_rate(functional_currency::text, invoice_to_send.currency::text, invoice_to_send.issued_on);
    ELSE
        rate = 1;
    END IF;

    -- Generate unique id for new ledger entries
    output_ledger_entry_id = public.tuid_generate();


    -- Generate ledger entries and insert them
    INSERT INTO accounting.ledger_entries
        SELECT * FROM accounting.ledger_entries_from_purchase_invoice(invoice_to_send.purchase_invoice_id, rate, output_ledger_entry_id);

    invoice_to_send.meta = invoice_to_send.meta || jsonb_build_object(
                                                'ledger_entry_id', output_ledger_entry_id,
                                                'sent_to_ledger_at', CURRENT_TIMESTAMP(0),
                                                'rate', rate
                                            );
    UPDATE accounting.purchase_invoices SET meta = invoice_to_send.meta WHERE purchase_invoices.purchase_invoice_id = invoice_to_send.purchase_invoice_id;
END
$$;

COMMENT ON FUNCTION accounting.send_purchase_invoice_to_ledger(invoice_to_send accounting.purchase_invoices) IS 'Create ledger entries from purchase_invoice_lines';