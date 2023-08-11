-- depends_on: ["::schemas:public:extensions:role_meta", "::schemas:public:extensions:http"]
CREATE FUNCTION sales.process_email(user regrole, msg_id text) RETURNS void
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    res_status int;
    user_id int;
    params text;
    msg_id text;
    res json;
    headers json;

BEGIN
    user_id = role_meta.get_from_role(user, 'google_user_id');
    access_token = common.get_user_token(user);

    params = urlencode(jsonb_build_object(
        'userId',          user_id,
        'id',              msg_id,
        'format',          'full'
    ));

    -- Fetch message
    SELECT status, content::json FROM http((
        'GET'
        format('https://gmail.googleapis.com/gmail/v1/users/%s/messages/%s?%s', user_id, msg_id, params),
        ARRAY[http_header('Authorization','Bearer ' || access_token)],
        NULL,
        NULL
    )::http_request)
    INTO res_status, res;

    IF res_status != 200 THEN
        RAISE 'email_sync: Could not fetch email. Status %', res_status;
    END IF;

    -- Parse headers
    headers = WITH raw_fields AS (#>ARRAY['payload','headers'] AS headers(name text, value text)),
                   parsed_headers AS (SELECT "name" AS field_name, array_agg(regexp_matches[1]) AS field_content
	                                    FROM raw_fields, regexp_matches("value", '(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])', 'g')
	                                    WHERE name IN ('From', 'To', 'Subject', 'Date')
	                                    GROUP BY name)
              SELECT json_object(array_agg(ARRAY[field_name, array_to_string(field_content, ',')])) FROM parsed_headers;


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