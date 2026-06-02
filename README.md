# Telco Project

This repository contains the SQL solution for the i2i Systems telecommunications database assignment.

## Project Goal

The goal is to design an Oracle XE database schema for the provided telecom CSV files, import the data, and answer the requested business questions with SQL queries.

## Files

- `CUSTOMERS.csv`: customer records
- `TARIFFS.csv`: tariff definitions and package limits
- `MONTHLY_STATS.csv`: monthly usage and payment status records
- `TABLE_CREATION_SCRIPTS.sql`: Oracle table creation script with constraints and indexes
- `SOLUTIONS.sql`: SQL answers with explanations and expected output summaries
- `docker-compose.yml`: optional Oracle XE container setup

## Database Schema

The database uses three main tables:

- `TARIFFS`
- `CUSTOMERS`
- `MONTHLY_STATS`

Relationships:

- `CUSTOMERS.TARIFF_ID` references `TARIFFS.TARIFF_ID`
- `MONTHLY_STATS.CUSTOMER_ID` references `CUSTOMERS.CUSTOMER_ID`

## How to Run

1. Start Oracle XE locally.
2. Connect to Oracle with DBeaver or SQL*Plus.
3. Run `TABLE_CREATION_SCRIPTS.sql`.
4. Import the CSV files in this order:
   1. `TARIFFS.csv`
   2. `CUSTOMERS.csv`
   3. `MONTHLY_STATS.csv`
5. Run the queries in `SOLUTIONS.sql`.

When importing `CUSTOMERS.csv`, use the date format:

```text
DD/MM/YYYY
```

## Docker Option

If Docker is available, Oracle XE can be started with:

```bash
docker compose up -d
```

The database will be available on port `1521`. The default values in `docker-compose.yml` are intended for local development only.

## Answer Summary

- `Kobiye Destek` customers: 2,483
- Newest `Kobiye Destek` customer: customer `8295`, Ömer, AFYONKARAHİSAR, `05/04/2026`
- Missing monthly records: 50 customers
- Customers using at least 75% of data limit: 1,880
- Customers exhausting all package limits: 0
- Customers with unresolved payments (`LATE` or `UNPAID`): 2,951

## Notes

Each query in `SOLUTIONS.sql` includes an explanation of the approach and an expected output summary. The table creation script includes primary keys, foreign keys, check constraints, and indexes for common lookup columns.
