# R for Data Science, 2nd Edition.
# Chapter 21: Databases (in book)
# (Chapter 22 online! https://r4ds.hadley.nz/databases)

# install.packages('duckdb')
# install.packages('DBI')
# install.packages('dbplyr')
# install.packages('tidyverse')

library(DBI) #Low level database interface library
library(dbplyr) # high level interface for converting tidyverse verbs into sql queries
library(tidyverse)

# Duckdb allows a database to run locally. This means a third entity won't have to be deployed
# The dbdir argument specifies where the database should be kept relative to the project root
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = 'duckdb')
# n.b. this does not create a directory, duckdb, but a file in the root called duckdb
# with an associated duckdb.wal file

# Load some data

dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

# list tables
dbListTables(con)


# read a table

con |>
  dbReadTable("diamonds") |>
  as_tibble()

# Good. Note this table does not include a primary key, so cannot be made relational

# run sql queries

sql <- "
  SELECT carat, cut, clarity, color, price
  FROM diamonds
  WHERE price > 15000
"

as_tibble(dbGetQuery(con, sql))

# dbplyr basics

# a tbl is a local representation of a database table, NOT the entire table as something in memory

diamonds_db <- tbl(con, "diamonds")
diamonds_db

# Note for example the number of rows are not immediately known [?? x 10]

# The rest of the chapter involves using dplyr/dbplyr queries on tbl objects,
# followed by the show_query() function, to show how the tidyverse verbs are
# converted into sql statements.

# This isn't quite what we need, as we're instead more focused on producing a
# sensible relational database



# The following is recommended for a high level overview of sql database terms
#  https://stackoverflow.com/questions/7022755/whats-the-difference-between-a-catalog-and-a-schema-in-a-relational-database

# For testing we will likely want a testing schema with the same structure as the
# deployment schema
# But first we need to define what the schema should be

