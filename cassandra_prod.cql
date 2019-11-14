/**
 * CQL file used to initialize the database in production environment.
 */

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
                                      value_double_ tsorage.tdouble,
                                      value_long_ tsorage.tlong,
                                      value_date_double_ tsorage.date_double,
                                      PRIMARY KEY ((metric_, shard_, interval_, aggregator_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

CREATE TABLE tsorage_ts.observations (
                                         metric_ text,
                                         shard_ text,
                                         datetime_ timestamp,
                                         value_double_ tsorage_ts.tdouble,
                                         value_long_ tsorage_ts.tlong,
                                         value_date_double_ tsorage_ts.date_double,
                                         PRIMARY KEY ((metric_, shard_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);


/**
 * The static tagsets associated with a metric.
 */
CREATE TABLE tsorage.static_tagset (
    metric text,
    tagname text,
    tagvalue text,
    PRIMARY KEY (metric, tagname, tagvalue)
) WITH CLUSTERING ORDER BY (tagname ASC, tagvalue ASC);

/**
  * The reverse tagset table, for storing the metrics associated with a static tagset.
 */
CREATE MATERIALIZED VIEW tsorage.reverse_static_tagset AS
    SELECT metric, tagname, tagvalue
    FROM tsorage.static_tagset
    WHERE tagname IS NOT NULL AND tagvalue IS NOT NULL
    PRIMARY KEY (tagname, tagvalue, metric)
WITH CLUSTERING ORDER BY (tagvalue ASC);

/**
 * The dynamic tagsets associated with a metric.
 */
CREATE TABLE tsorage.dynamic_tagset(
    metric text,
    tagname text,
    tagvalue text,
    PRIMARY KEY (metric, tagname)
) WITH CLUSTERING ORDER BY (tagname ASC);

CREATE MATERIALIZED VIEW tsorage.reverse_dynamic_tagset AS
    SELECT tagname, tagvalue, metric
    FROM tsorage.dynamic_tagset
    WHERE tagname IS NOT NULL and tagvalue IS NOT NULL and metric IS NOT NULL
    PRIMARY KEY ( tagname, tagvalue, metric )
WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC);

CREATE TABLE tsorage.sharded_dynamic_tagset
(
    metric   text,
    shard    text,
    tagname  text,
    tagvalue text,
    PRIMARY KEY ((metric, shard), tagname)
) WITH CLUSTERING ORDER BY (tagname ASC);

CREATE MATERIALIZED VIEW tsorage.reverse_sharded_dynamic_tagset AS
SELECT shard, tagname, tagvalue, metric
FROM tsorage.sharded_dynamic_tagset
WHERE shard IS NOT NULL and tagname IS NOT NULL and tagvalue IS NOT NULL and metric IS NOT NULL
    PRIMARY KEY ( (shard, tagname), tagvalue, metric )
    WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC);

CREATE MATERIALIZED VIEW tsorage.reverse_sharded_dynamic_tagname AS
    SELECT shard, tagname, metric
    FROM tsorage.sharded_dynamic_tagset
    WHERE shard IS NOT NULL and tagname IS NOT NULL and metric IS NOT NULL
PRIMARY KEY ( shard, tagname, metric )
WITH CLUSTERING ORDER BY (tagname ASC);
