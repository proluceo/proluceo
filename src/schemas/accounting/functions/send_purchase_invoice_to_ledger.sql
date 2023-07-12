-- depends_on: ["string_to_chars", "::schemas:public:extensions:ltree", "::schemas:public:aggregates:path_agg"]
CREATE FUNCTION accounting.send_purchase_invoice_to_ledger(invoice_to_send_id uuid) RETURNS boolean
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    created_ledger_entry_id uuid;
    invoice_metadata jsonb;
BEGIN
    INSERT INTO accounting.ledger_entries SELECT * FROM accounting.ledger_entries_from_purchase_invoice(invoice_to_send_id) RETURNING ledger_entries.ledger_entry_id INTO created_ledger_entry_id;
    invoice_metadata = jsonb_build_object(    'ledger_entry_id', created_ledger_entry_id,
                                              'sent_to_ledger_at', CURRENT_TIMESTAMP(0)
                                        );
    UPDATE accounting.purchase_invoices SET meta = meta || invoice_metadata WHERE purchase_invoices.purchase_invoice_id = invoice_to_send_id;

END
$$;

COMMENT ON FUNCTION accounting.send_purchase_invoice_to_ledger(purchase_invoice_id uuid) IS 'Create ledger entries from purchase_invoice_lines';