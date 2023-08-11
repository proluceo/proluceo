-- depends_on: ["::schemas:public:extensions:role_meta"]
CREATE FUNCTION sales.sync_user_emails(user regrole) RETURNS void
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    res_status int;
    last_history_id int;

BEGIN
    last_history_id = role_meta.get_from_user(user, 'gmail_history_id')::int;
    IF last_history_id IS NULL THEN
        sales.full_email_sync(user);
    ELSE
        sales.incremental_email_sync(user);
    END;
END;
$$;

COMMENT ON FUNCTION sales.sync_user_emails(user regrole)
    IS 'Sync gmail communications for given user';