-- depends_on: ["::schemas:public:extensions:role_meta", "::schemas:public:extensions:http"]
CREATE FUNCTION public.store_user_token(access_token text, refresh_token text, expires_at int) RETURNS void
    LANGUAGE plpgsql VOLATILE SECURITY DEFINER
    AS $$
DECLARE
    res_status int;
    user_oauth_meta json;
    user_role regrole;
    user_id text;
BEGIN
     SELECT status, content::json FROM http((
          'GET',
           'https://www.googleapis.com/oauth2/v1/userinfo?alt=json',
           ARRAY[http_header('Authorization','Bearer ' || access_token)],
           NULL,
           NULL
        )::http_request)
        INTO res_status, user_oauth_meta;

    IF res_status != 200 THEN
        RAISE 'Could not authenticate with given access token. Status %', res_status;
    END IF;

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

COMMENT ON FUNCTION public.store_user_token(access_token text, refresh_token text, expires_at int)
    IS 'Store user access and refresh token. Warning: Security of definer!';