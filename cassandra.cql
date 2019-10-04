CREATE  KEYSPACE IF NOT EXISTS tsorage
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_ts
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TYPE tsorage_ts.tdouble ( value double );
CREATE TYPE tsorage.tdouble ( value double );

CREATE TYPE tsorage_ts.tlong ( value bigint );
CREATE TYPE tsorage.tlong ( value bigint );

CREATE TYPE tsorage_ts.date_double ( datetime timestamp, value double );
CREATE TYPE tsorage.date_double ( datetime timestamp, value double );


CREATE TABLE tsorage.observations (
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

CREATE TABLE tsorage_ts.observations (
                                         metric_ text,
                                         shard_ text,
                                         datetime_ timestamp,
                                         value_double_ tdouble,
                                         value_long_ tlong,
                                         value_date_double_ date_double,
                                         PRIMARY KEY ((metric_, shard_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);
