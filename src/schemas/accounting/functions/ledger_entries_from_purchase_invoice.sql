-- depends_on: ["::schemas:public:extensions:tuid", "::schemas:accounting:tables:purchase_invoices", "::schemas:accounting:tables:purchase_invoice_lines", "::schemas:accounting:tables:ledger_entries"]
CREATE OR REPLACE FUNCTION accounting.ledger_entries_from_purchase_invoice(source_invoice_id uuid) RETURNS SETOF accounting.ledger_entries
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    purchase_invoice accounting.purchase_invoices;
    purchase_invoice_line accounting.purchase_invoice_lines;
	purchase_invoice_amount numeric(10,2);
    output_ledger_entry accounting.ledger_entries;
    output_ledger_entry_id uuid;
BEGIN
    -- Look for purchase invoice
    SELECT * INTO purchase_invoice FROM accounting.purchase_invoices WHERE purchase_invoices.purchase_invoice_id=source_invoice_id;
    IF purchase_invoice.purchase_invoice_id IS NULL THEN
        RAISE 'Cannot find purchase invoice %', source_invoice_id;
    END IF;

    -- Generate unique id for new ledger entries
    output_ledger_entry_id = public.tuid_generate();

    -- Loop through lines and output ledger entries
    FOR purchase_invoice_line IN SELECT * FROM accounting.purchase_invoice_lines WHERE purchase_invoice_lines.purchase_invoice_id=source_invoice_id LOOP
        SELECT  purchase_invoice.company_id,
                output_ledger_entry_id AS ledger_entry_id,
                purchase_invoice_line.account_number,
                purchase_invoice.issued_on AS position,
                purchase_invoice_line.amount,
                'debit' AS direction
            INTO output_ledger_entry;

        RETURN NEXT output_ledger_entry;
    END LOOP;

    -- Output payment ledger entry
	purchase_invoice_amount = sum(purchase_invoice_lines.amount) FROM accounting.purchase_invoice_lines WHERE purchase_invoice_lines.purchase_invoice_id=source_invoice_id;
    SELECT  purchase_invoice.company_id,
            output_ledger_entry_id AS ledger_entry_id,
            purchase_invoice.payment_account_number AS account_number,
            purchase_invoice.issued_on AS position,
            purchase_invoice_amount AS amount,
            'credit' AS direction
        INTO output_ledger_entry;
	RETURN NEXT output_ledger_entry;

END
$$;

COMMENT ON FUNCTION accounting.ledger_entries_from_purchase_invoice(purchase_invoice_id uuid) IS 'Generate ledger entries from purchase_invoice_lines';
