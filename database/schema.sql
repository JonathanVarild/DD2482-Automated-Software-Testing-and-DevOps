BEGIN;

CREATE TABLE IF NOT EXISTS role (
  role_id integer PRIMARY KEY,
  name varchar(32) NOT NULL UNIQUE
);

INSERT INTO role (role_id, name)
VALUES (1, 'recruiter'),
  (2, 'applicant') ON CONFLICT (role_id) DO
UPDATE

SET name = EXCLUDED.name;

CREATE TABLE IF NOT EXISTS person (
  person_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar(255) NOT NULL,
  surname varchar(255) NOT NULL,
  pnr varchar(13) NOT NULL UNIQUE,
  email varchar(320) NOT NULL UNIQUE,
  password_hash varchar(255) NOT NULL,
  role_id integer NOT NULL DEFAULT 2 REFERENCES role (role_id),
  username varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS session (
  session_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  person_id integer NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
  token_hash varchar(64) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS password_reset_token (
  token_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  person_id integer NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
  token_hash varchar(64) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS competence (
  competence_id integer PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS competence_translation (
  competence_id integer NOT NULL REFERENCES competence (competence_id) ON DELETE CASCADE,
  locale varchar(2) NOT NULL,
  translation varchar(255) NOT NULL,
  PRIMARY KEY (competence_id, locale)
);

CREATE TABLE IF NOT EXISTS competence_profile (
  competence_profile_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  person_id integer NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
  competence_id integer NOT NULL REFERENCES competence (competence_id),
  years_of_experience numeric(4, 2) NOT NULL CHECK (years_of_experience >= 0),
  UNIQUE (person_id, competence_id)
);

CREATE TABLE IF NOT EXISTS availability (
  availability_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  person_id integer NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
  from_date date NOT NULL,
  to_date date NOT NULL,
  CONSTRAINT availability_from_before_to_chk CHECK (from_date <= to_date)
);

CREATE TABLE IF NOT EXISTS applications (
  application_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  person_id integer NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
  status varchar(16) NOT NULL DEFAULT 'unhandled' CHECK (status IN ('unhandled', 'accepted', 'rejected')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz
);

CREATE UNIQUE INDEX IF NOT EXISTS applications_one_unhandled_per_person_idx ON applications (person_id)
WHERE status = 'unhandled';
CREATE INDEX IF NOT EXISTS applications_status_created_at_idx ON applications (status, created_at DESC);

CREATE TABLE IF NOT EXISTS log (
  log_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  level varchar(16) NOT NULL CHECK (level IN ('INFO', 'ERROR', 'DEBUG')),
  event_type varchar(128) NOT NULL,
  message text NOT NULL,
  ip text,
  user_agent text,
  actor_person_id integer REFERENCES person (person_id) ON DELETE
  SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO competence (competence_id, name)
VALUES (1, 'ticket sales'),
  (2, 'lotteries'),
  (3, 'roller coaster operation') ON CONFLICT (competence_id) DO
UPDATE
SET name = EXCLUDED.name;

INSERT INTO competence_translation (competence_id, locale, translation)
VALUES (1, 'sv', 'biljettförsäljning'),
  (2, 'sv', 'lotterier'),
  (3, 'sv', 'berg- och dalbanedrift') ON CONFLICT (competence_id, locale) DO
UPDATE
SET translation = EXCLUDED.translation;

-- Username: admin
-- Password: Admin123!
INSERT INTO person (
    name,
    surname,
    pnr,
    email,
    password_hash,
    role_id,
    username
  )
SELECT 'Admin',
  'User',
  '20000101-0000',
  'admin@example.com',
  '$2b$10$Oeq303IUDi32fVdpm9a34OZDVk.AKwB9C4PG9MDn/AMmZx9kE.rvi',
  role_id,
  'admin'
FROM role
WHERE name = 'recruiter' ON CONFLICT (username) DO NOTHING;
COMMIT;