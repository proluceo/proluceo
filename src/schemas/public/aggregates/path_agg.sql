-- depends_on: ["::schemas:accounting:functions:path_agg_transfn", "::schemas:accounting:functions:path_agg_finalfn"]
CREATE AGGREGATE public.path_agg(text) (
    SFUNC = accounting.path_agg_transfn,
    STYPE = text[],
    INITCOND = '{}',
    FINALFUNC = accounting.path_agg_finalfn
);
