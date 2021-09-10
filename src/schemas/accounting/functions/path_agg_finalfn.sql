CREATE FUNCTION accounting.path_agg_finalfn(internal_state text[]) RETURNS text
    LANGUAGE sql
    AS $$
SELECT array_to_string(internal_state, '.');
$$;

COMMENT ON FUNCTION accounting.path_agg_finalfn(internal_state text[]) IS 'final function for path_agg aggregate function';

