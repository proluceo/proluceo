-- depends_on: ["::schemas:public:extensions:role_meta", "::schemas:public:extensions:http"]
CREATE FUNCTION sales.full_email_sync(user regrole) RETURNS void
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    res_status int;
    user_id int;
    history_id int;
    params text;
    msg_id text;
    res json;
    messages json;
    watched_addresses text[];
    match_found boolean;

BEGIN
    user_id = role_meta.get_from_role(user, 'google_user_id');
    access_token = common.get_user_token(user);

    -- Cache all watched email addresses
    watched_addresses = array_agg(work_email::text) FROM sales.contacts;

    -- Fetch message list
    params = urlencode(jsonb_build_object(
        'userId',           user_id,
        'includeSpamTrash', 'false',
        'maxResults',        20
    ));

    SELECT status, content::json FROM http((
          'GET'
          format('https://gmail.googleapis.com/gmail/v1/users/%s/messages/?%s', user_id, params),
          ARRAY[http_header('Authorization','Bearer ' || access_token)],
          NULL,
          NULL
        )::http_request)
        INTO res_status, res;

    IF res_status != 200 THEN
        RAISE 'email_sync: Could not fetch email list. Status %', res_status;
    END IF;

    messages = res->'messages';
    FOR msg_id IN SELECT id FROM json_to_recordset(messages) AS msg(id text, "threadId" text) LOOP
        params = urlencode(jsonb_build_object(
            'userId',           user_id,
            'id', msg_id,
            'format',        'metadata',
            "metadataHeaders", json_build_array('From', 'To')
        ));

        -- Fetch message metadata
        SELECT status, content::json FROM http((
          'GET'
          format('https://gmail.googleapis.com/gmail/v1/users/%s/messages/%s?%s', user_id, msg_id, params),
          ARRAY[http_header('Authorization','Bearer ' || access_token)],
          NULL,
          NULL
        )::http_request)
        INTO res_status, res;

        IF res_status != 200 THEN
            RAISE 'email_sync: Could not fetch email metadata. Status %', res_status;
        END IF;

        -- Look for any match with watched addresses
        match_found = WITH raw_fields AS (#>ARRAY['payload','headers'] AS headers(name text, value text))
            SELECT count(*) > 0
	            FROM raw_fields, regexp_matches("value", '(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])', 'g')
	            WHERE regexp_matches[1] =ANY (watched_addresses);

        IF match_found THEN
            sales.process_email(msg_id);
        END IF;

    END LOOP;

    user_role = '"' || (user_oauth_meta->>'email') || '"';
    user_id = user_oauth_meta->>'id';

    PERFORM role_meta.set_to_role(user_role, 'google_user_id', user_id);
    PERFORM role_meta.set_to_role(user_role, 'access_token', access_token);
	IF refresh_token IS NOT NULL THEN
    	PERFORM role_meta.set_to_role(user_role, 'refresh_token', refresh_token);
	END IF;
    PERFORM role_meta.set_to_role(user_role, 'token_expires_at', expires_at::text);
END
$$;

COMMENT ON FUNCTION sales.sync_user_emails(user regrole)
    IS 'Sync all gmail communications for given user';