-- depends_on: ["::schemas:public:extensions:crypto"]
-- from github.com/tanglebones/pg_tuid
create function common.tuid6()
  returns uuid as
$$
declare
  r bytea;
  ts bigint;
  ret varchar;
begin
  r := gen_random_bytes(10);
  ts := extract(epoch from clock_timestamp() at time zone 'utc') * 1000;

  ret := lpad(to_hex(ts), 12, '0') ||
    lpad(encode(r, 'hex'), 20, '0');

  return ret :: uuid;
end;
$$ language plpgsql;
