CREATE OR REPLACE FUNCTION accounting.purchase_invoice_b64decode()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF current_setting('request.header.postgrest-encoding', TRUE) = 'base64' THEN
		NEW.attachment = decode(convert_from(new.val, 'SQL_ASCII'), 'base64');
	END IF;
	RETURN new;
END
$BODY$;
