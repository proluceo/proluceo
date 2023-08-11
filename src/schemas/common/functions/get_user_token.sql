-- depends_on: ["::schemas:public:extensions:role_meta", "::schemas:public:extensions:http"]
CREATE FUNCTION common.get_user_token(user_role regrole) RETURNS text
    LANGUAGE plpgsql VOLATILE
    AS $$
DECLARE
    res_status int;
    res json;
    access_token text;
    refresh_token text;
    expires_at int;
    client_id text;
    client_secret text;
BEGIN
    access_token = role_meta.get_from_role(user_role, 'access_token');
    expires_at = role_meta.get_from_role(user_role, 'token_expires_at')::int;
	client_id = role_meta.get_from_current_user('google_client_id');
	client_secret = role_meta.get_from_current_user('google_client_secret');

    IF access_token IS NOT NULL AND to_timestamp(expires_at) > CURRENT_TIMESTAMP THEN
        RETURN access_token;
    END IF;

    -- Refresh expired token
    refresh_token = role_meta.get_from_role(user_role, 'refresh_token');
    SELECT status, content::json FROM http_post(
        'https://oauth2.googleapis.com/token',
        jsonb_build_object(
            'client_id',      client_id,
            'client_secret',  client_secret,
            'refresh_token',  refresh_token,
            'grant_type',     'refresh_token'

        )
    )
    INTO res_status, res;

    IF res_status != 200 THEN
        RAISE 'Could not refresh expired token. Status %', res_status;
    END IF;

    access_token = res->>'access_token';
    expires_at = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP + make_interval(secs => (res->>'expires_in')::int)))::int;

    PERFORM role_meta.set_to_role(user_role, 'access_token', access_token);
    PERFORM role_meta.set_to_role(user_role, 'token_expires_at', expires_at::text);
    RETURN access_token;
END
$$;