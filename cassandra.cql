CREATE  KEYSPACE IF NOT EXISTS tsorage_agg
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_raw
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TABLE tsorage_agg.numeric (
    metric_ text,
    shard_ text,
    interval_ text,    -- raw, 1m, 1h, 1d
    aggregator_ text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
    datetime_ timestamp,
    value_ float,
    observation_datetime_ timestamp,
    PRIMARY KEY ((metric_, shard_, interval_, aggregator_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

CREATE TABLE tsorage_raw.numeric (
    metric_ text,
    shard_ text,
    datetime_ timestamp,
    value_ float,
    PRIMARY KEY ((metric_, shard_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

ALTER TABLE tsorage_raw.numeric ADD owner2 text;

INSERT INTO tsorage_raw.numeric (metric_,shard_,datetime_,value_)
VALUES ('my sensor','2019-08','2019-08-18T18:48:00',2.8556213);

INSERT INTO tsorage_agg.numeric (metric_,shard_,interval_,aggregator_,owner2,datetime_,value_)
VALUES ('my sensor','2019-08','1m','sum','Clara O''Tool','2019-08-18T17:48:00',2.8556213);

SELECT COUNT(*)
FROM tsorage_raw.numeric;

/* The registered tag column names */
SELECT column_name
FROM system_schema.columns
WHERE
    keyspace_name = 'tsorage_raw'
    AND table_name = 'numeric'
    AND kind='regular'
    AND type='text'
ALLOW FILTERING;


SELECT * FROM tsorage_raw.numeric;

ALTER TABLE tsorage_raw.numeric ADD owner3 text;

