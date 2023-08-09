CREATE ROLE authenticator WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
COMMENT ON ROLE authenticator IS 'Role used by backend to authenticate users and set tokens';