CREATE TYPE common.mean_of_communication AS ENUM
    ('call', 'meeting', 'email');

COMMENT ON TYPE common.mean_of_communication
    IS 'Enum of all possible means of communication';
