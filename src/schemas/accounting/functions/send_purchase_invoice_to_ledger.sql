-- depends_on: ["string_to_chars", "::schemas:public:extensions:ltree", "::schemas:public:aggregates:path_agg"]
CREATE FUNCTION accounting.send_purchase_invoice_to_ledger(invoice_to_send_id uuid) RETURNS boolean
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    accounting.puchase_invoices purchase_invoice;
    purchase_invoice_line accouting.purchase_invoice_lines;
BEGIN
    -- Look for purchase invoice
    SELECT * INTO purchase_invoice FROM accounting.purchase_invoices WHERE purchase_invoices.purchase_invoice_id=invoice_to_send_id;
    IF purchase_invoice.uuid IS NULL THEN
        RAISE 'Cannot find purchase invoice %', invoice_to_send_id;
    END IF;

    -- Loop through lines
    FOR purchase_invoice_line IN SELECT * FROM accounting.purchase_invoice_lines WHERE purchase_invoice_lines.purchase_invoice_id=invoice_to_send_id LOOP
        INSERT INTO
    END LOOP;
END
$$;

COMMENT ON FUNCTION accounting.send_purchase_invoice_to_ledger(purchase_invoice_id uuid) IS 'Create ledger entries from purchase_invoice_lines';