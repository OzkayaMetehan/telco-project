/*
  Telco Project - Oracle XE table creation script

  Run this script before importing the CSV files with DBeaver or SQL*Plus.
  The tables are designed directly from CUSTOMERS.csv, TARIFFS.csv, and
  MONTHLY_STATS.csv. Date values in CUSTOMERS.csv use DD/MM/YYYY format.
*/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE monthly_stats CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE tariffs CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE tariffs (
  tariff_id    NUMBER(10)      NOT NULL,
  name         NVARCHAR2(100)  NOT NULL,
  monthly_fee  NUMBER(10, 2)   NOT NULL,
  data_limit   NUMBER(12, 2)   NOT NULL,
  minute_limit NUMBER(10)      NOT NULL,
  sms_limit    NUMBER(10)      NOT NULL,

  CONSTRAINT pk_tariffs PRIMARY KEY (tariff_id),
  CONSTRAINT uk_tariffs_name UNIQUE (name),
  CONSTRAINT ck_tariffs_monthly_fee CHECK (monthly_fee >= 0),
  CONSTRAINT ck_tariffs_data_limit CHECK (data_limit >= 0),
  CONSTRAINT ck_tariffs_minute_limit CHECK (minute_limit >= 0),
  CONSTRAINT ck_tariffs_sms_limit CHECK (sms_limit >= 0)
);

CREATE TABLE customers (
  customer_id NUMBER(10)      NOT NULL,
  name        NVARCHAR2(100)  NOT NULL,
  city        NVARCHAR2(100)  NOT NULL,
  signup_date DATE            NOT NULL,
  tariff_id   NUMBER(10)      NOT NULL,

  CONSTRAINT pk_customers PRIMARY KEY (customer_id),
  CONSTRAINT fk_customers_tariff
    FOREIGN KEY (tariff_id) REFERENCES tariffs (tariff_id)
);

CREATE TABLE monthly_stats (
  id             NUMBER(10)     NOT NULL,
  customer_id    NUMBER(10)     NOT NULL,
  data_usage     NUMBER(12, 2)  NOT NULL,
  minute_usage   NUMBER(10)     NOT NULL,
  sms_usage      NUMBER(10)     NOT NULL,
  payment_status VARCHAR2(20)   NOT NULL,

  CONSTRAINT pk_monthly_stats PRIMARY KEY (id),
  CONSTRAINT uk_monthly_stats_customer UNIQUE (customer_id),
  CONSTRAINT fk_monthly_stats_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  CONSTRAINT ck_monthly_stats_data_usage CHECK (data_usage >= 0),
  CONSTRAINT ck_monthly_stats_minute_usage CHECK (minute_usage >= 0),
  CONSTRAINT ck_monthly_stats_sms_usage CHECK (sms_usage >= 0),
  CONSTRAINT ck_monthly_stats_payment
    CHECK (payment_status IN ('PAID', 'LATE', 'UNPAID'))
);

CREATE INDEX idx_customers_tariff_id ON customers (tariff_id);
CREATE INDEX idx_customers_signup_date ON customers (signup_date);
CREATE INDEX idx_customers_city ON customers (city);
CREATE INDEX idx_monthly_stats_customer_id ON monthly_stats (customer_id);
CREATE INDEX idx_monthly_stats_payment_status ON monthly_stats (payment_status);

/*
  Import order:
  1. TARIFFS.csv into TARIFFS
  2. CUSTOMERS.csv into CUSTOMERS
  3. MONTHLY_STATS.csv into MONTHLY_STATS

  In DBeaver, set the customer SIGNUP_DATE format to DD/MM/YYYY if prompted.
*/
