-- depends_on: ["string_to_chars"]
CREATE FUNCTION accounting.account_number_to_path(account_number integer) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $$
        SELECT path_agg(string_to_chars)::ltree FROM accounting.string_to_chars(account_number::text);
$$;

COMMENT ON FUNCTION accounting.account_number_to_path(account_number integer) IS 'Return the path from an account number. Used in generated column accounts.path';