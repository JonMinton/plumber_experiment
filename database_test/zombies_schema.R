# Zombies database schema example

# The aim of this script is to look at how to specify a database schema
# via R which models the following scenario:

# There are three entities:
# Zombies
# Survivors
# Rescuers

# There are two relationships

# bites: A zombie can bite a survivor
# rescues: a rescuer can rescue a survivor

# Additionally:

# A zombie can bite more than one survivor
# A survivor can be bitten by only one zombie

# A rescuer can rescue more than one survivor
# A survivor can be rescued by only one rescuer

# So the schema involves five tables,
# Three for the entities (nouns)
#  - zombies
#  - survivors
#  - rescuers
# Two for the relationships (verbs)
#  - bites
#  - rescues


# Let's now try to specify these

library(DBI) #Low level database interface library
library(dbplyr) # high level interface for converting tidyverse verbs into sql queries
library(tidyverse)

# Duckdb allows a database to run locally. This means a third entity won't have to be deployed
# The dbdir argument specifies where the database should be kept relative to the project root
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = 'duckdb')

# https://duckdb.org/docs/sql/introduction
# https://duckdb.org/docs/sql/statements/create_schema
# https://duckdb.org/docs/sql/statements/create_table

# First define the schema

# TO DROP THE SCHEMA AND ITS TABLES USE:
# DBI::dbExecute(con, "DROP schema IF EXISTS zom CASCADE;")


DBI::dbExecute(
  con,
  statement = "
    CREATE SCHEMA zom
  "
)

# Next define the noun tables

DBI::dbExecute(
  con,
  statement = "
    CREATE TABLE zom.zombies(id INTEGER PRIMARY KEY, name VARCHAR);
    CREATE TABLE zom.survivors(id INTEGER PRIMARY KEY, name VARCHAR);
    CREATE TABLE zom.rescuers(id INTEGER PRIMARY KEY, name VARCHAR);
  "
)

# For the primary keys it looks like the SEQUENCE operator will be useful
# https://duckdb.org/docs/sql/statements/create_sequence

# Next define the verb tables

DBI::dbExecute(
  con,
  statement = "
    CREATE TABLE zom.bites(
      id INTEGER PRIMARY KEY,
      z_id INTEGER,
      FOREIGN KEY (z_id) REFERENCES zom.zombies(id),
      s_id INTEGER,
      FOREIGN KEY (s_id) REFERENCES zom.survivors(id),
      timedate TIMESTAMP
    );
    CREATE TABLE zom.rescues(
      id INTEGER PRIMARY KEY,
      r_id INTEGER,
      FOREIGN KEY (r_id) REFERENCES zom.rescuers(id),
      s_id INTEGER,
      FOREIGN KEY (s_id) REFERENCES zom.survivors(id),
      timedate TIMESTAMP
    );
  "
)

# Now to populate the noun tables, then finally the verb tables

DBI::dbExecute(
  con,
  statement = "
    DROP SEQUENCE zom_seq;
    DROP SEQUENCE sur_seq;
    DROP SEQUENCE res_seq;
    DROP SEQUENCE bit_seq;
    DROP SEQUENCE rcu_seq;
  "
)

DBI::dbExecute(
  con,
  statement = "
    CREATE SEQUENCE zom_seq START 101;
    CREATE SEQUENCE sur_seq START 201;
    CREATE SEQUENCE res_seq START 301;
    CREATE SEQUENCE bit_seq START 401;
    CREATE SEQUENCE rcu_seq START 501;
  "
)

# The sequences start at different numbers to make them easier to differentiate

# Let's now create some entries in the tables

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.zombies
      VALUES (nextval('zom_seq'), 'Zombo');
  "
)

DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.zombies;
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.zombies
      VALUES (nextval('zom_seq'), 'Zimbo');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.zombies
      VALUES (nextval('zom_seq'), 'Zambo');
  "
)


DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.zombies;
  "
)

# This confirms the sequencing works as expected. Now to do the same with survivors and rescuers


DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.survivors
      VALUES (nextval('sur_seq'), 'Andy');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.survivors
      VALUES (nextval('sur_seq'), 'Brenda');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.survivors
      VALUES (nextval('sur_seq'), 'Charlie');
  "
)


DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.rescuers
      VALUES (nextval('res_seq'), 'Alpha');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.rescuers
      VALUES (nextval('res_seq'), 'Brickhead');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.rescuers
      VALUES (nextval('res_seq'), 'Chad');
  "
)


DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.zombies;
  "
)


DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.rescuers;
  "
)

DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.survivors;
  "
)


# Now to add some contents to the relationship (verb) tables

# Let's say:

# Chad (rescuers.id == 303) rescues Andy (survivors.id == 201)
# Zimbo (zombies.id == 102) bites Brenda (survivors.id == 202)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.rescues
     values(nextval('rcu_seq'), 303, 201, TIMESTAMP '2020-05-01');
  "
)

DBI::dbExecute(
  con,
  statement = "
    INSERT INTO zom.bites
     values(nextval('bit_seq'), 102, 202, TIMESTAMP '2021-02-14');
  "
)


DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.rescues;
  "
)


DBI::dbGetQuery(
  con,
  statement = "
    SELECT * FROM zom.bites;
  "
)

# Can we now use dbplyr to generate and run the SQL queries to get the names of z_id and s_id
# in the above relationship tables?

rescuers_db <- tbl(con, "zom.rescuers")
zombies_db <- tbl(con, "zom.zombies")
survivors_db <- tbl(con, "zom.survivors")

bites_db <- tbl(con, "zom.bites")
rescues_db <- tbl(con, "zom.rescues")


bites_db |>
  left_join(
    zombies_db, by = c("z_id" = "id")
  ) |>
  rename(zombie_name = name) |>
  left_join(
    survivors_db, by = c("s_id" = "id")
  ) |>
  rename(
    survivor_name = name
  ) |>
  select(-z_id, -s_id) |>
  show_query() #Run without show_query to see this execute (successfully)

rescues_db |>
  left_join(
    rescuers_db, by = c("r_id" = "id")
  ) |>
  rename(rescuer_name = name) |>
  left_join(
    survivors_db, by = c("s_id" = "id")
  ) |>
  rename(
    survivor_name = name
  ) |>
  select(-r_id, -s_id) |>
  show_query() # Run without show_query to see this execute (successfully)
