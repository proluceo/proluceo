CREATE TYPE accounting.purchase_invoice_line AS (
	account integer,
	label text,
	amount numeric(10,2)
);
