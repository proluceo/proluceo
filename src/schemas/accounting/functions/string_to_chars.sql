CREATE FUNCTION accounting.string_to_chars(string text) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT regexp_matches[1] FROM regexp_matches(string, '.', 'g');
$$;

COMMENT ON FUNCTION accounting.string_to_chars(string text) IS 'Return a set of single characters from a string';

