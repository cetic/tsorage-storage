CREATE  KEYSPACE IF NOT EXISTS tsorage_agg
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_raw
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TYPE tsorage_raw.tdouble ( value double );
CREATE TYPE tsorage_agg.tdouble ( value double );

CREATE TYPE tsorage_raw.tlong ( value bigint );
CREATE TYPE tsorage_agg.tlong ( value bigint );

CREATE TYPE tsorage_agg.date_double (
    datetime timestamp,
    value double
    );

CREATE TYPE tsorage_raw.date_double (
    datetime timestamp,
    value double
    );


CREATE TABLE tsorage_agg.numeric (
    metric_ text,
    shard_ text,
    interval_ text,    -- raw, 1m, 1h, 1d
    aggregator_ text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
    datetime_ timestamp,
    value_double_ tdouble,
    value_long_ tlong,
    value_date_double_ date_double,
    PRIMARY KEY ((metric_, shard_, interval_, aggregator_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

CREATE TABLE tsorage_raw.numeric (
    metric_ text,
    shard_ text,
    datetime_ timestamp,
    value_double_ tdouble,
    value_long_ tlong,
    value_date_double_ date_double,
    PRIMARY KEY ((metric_, shard_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

ALTER TABLE tsorage_raw.numeric ADD owner2 text;

INSERT INTO tsorage_raw.numeric (metric_, shard_, datetime_, value_date_double_)
VALUES('my metric', '2019-10', '2019-10-01 12:34:56', {datetime: '2919-10-01 22:22:22', value: 42.123});

SELECT COUNT(*)
FROM tsorage_raw.numeric;

INSERT INTO tsorage_raw.numeric (metric_, shard_, datetime_, value_date_double_)
VALUES ('aaa', '2019-09', '2019-09-30T12:34:57', {"datetime": '2019-01-12 12:34:56', "value": 42});