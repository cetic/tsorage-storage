CREATE  KEYSPACE IF NOT EXISTS tsorage_agg
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_raw
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TABLE tsorage_agg.numeric (
    metric text,
    shard text,
    interval text,    -- raw, 1m, 1h, 1d
    aggregator text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
    datetime timestamp,
    value float,
    PRIMARY KEY ((metric, shard, interval, aggregator), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);

CREATE TABLE tsorage_raw.numeric (
    metric text,
    shard text,
    datetime timestamp,
    value float,
    PRIMARY KEY ((metric, shard), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);

CREATE TABLE tsorage.category (
    metric text,
    year_month text,
    interval text,    -- raw, 1m, 1h, 1d
    aggregator text,  -- raw, first, last, sum, min, max, count, delta
    datetime timestamp,
    value text,
    PRIMARY KEY ((metric, year_month, interval, aggregator), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);


INSERT INTO tsorage_raw.numeric (metric, shard, datetime, value) VALUES ('my_sensor', '2019-07', '2019-07-26 12:34:56', 42);