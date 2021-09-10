CREATE FUNCTION accounting.path_agg_transfn(internal_state text[], next_data_values text) RETURNS text[]
    LANGUAGE sql
    AS $$
SELECT array_append(
	internal_state,
	COALESCE(internal_state[array_upper(internal_state,1)], '')
		|| next_data_values);
$$;


COMMENT ON FUNCTION accounting.path_agg_transfn(internal_state text[], next_data_values text) IS 'state transition function for aggregate function path_agg';