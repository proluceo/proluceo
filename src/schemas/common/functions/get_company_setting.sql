-- depends_on: ["::schemas:common:tables:companies"]
CREATE FUNCTION common.get_company_setting(target_company_id int, param_path text[]) RETURNS text
    LANGUAGE sql STABLE
    AS $$
SELECT settings#>>param_path FROM common.companies WHERE company_id=target_company_id LIMIT 1;
$$;

COMMENT ON FUNCTION common.get_company_setting(target_company_id int, param_path text[]) IS 'Returns company setting at given path';

