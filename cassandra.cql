/**
 * CQL file used to initialize the database in test environment.
 */

CREATE  KEYSPACE IF NOT EXISTS tsorage
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_ts
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TYPE tsorage_ts.tdouble ( value double );
CREATE TYPE tsorage.tdouble ( value double );

CREATE TYPE tsorage_ts.pos2d ( longitude double, latitude double );
CREATE TYPE tsorage.pos2d ( longitude double, latitude double );

CREATE TYPE tsorage_ts.ttext ( value text );
CREATE TYPE tsorage.ttext ( value text );

CREATE TYPE tsorage_ts.tlong ( value bigint );
CREATE TYPE tsorage.tlong ( value bigint );

CREATE TYPE tsorage_ts.date_double ( datetime timestamp, value double );
CREATE TYPE tsorage.date_double ( datetime timestamp, value double );

CREATE TABLE tsorage.observations (
                                      metric text,
                                      tagset frozen<map<text, text>>,
                                      shard text,
                                      interval text,    -- raw, 1m, 1h, 1d
                                      aggregator text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
                                      datetime timestamp,
                                      value_double tsorage.tdouble,
                                      value_pos2d tsorage.pos2d,
                                      value_text tsorage.ttext,
                                      value_long tsorage.tlong,
                                      value_date_double tsorage.date_double,
                                      PRIMARY KEY ((metric, tagset, shard, interval, aggregator), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);

CREATE TABLE tsorage_ts.observations (
                                         metric text,
                                         tagset frozen<map<text, text>>,
                                         shard text,
                                         datetime timestamp,
                                         value_double tsorage_ts.tdouble,
                                         value_pos2d tsorage_ts.pos2d,
                                         value_text tsorage_ts.ttext,
                                         value_long tsorage_ts.tlong,
                                         value_date_double tsorage_ts.date_double,
                                         PRIMARY KEY ((metric, tagset, shard), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);


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
    tagset frozen<map<text, text>>,
    PRIMARY KEY (metric, tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE tsorage.reverse_dynamic_tagset(
    tagname text,
    tagvalue text,
    metric text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY (tagname, tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC, tagset ASC);

CREATE TABLE tsorage.sharded_dynamic_tagset
(
    metric   text,
    shard    text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY ((metric, shard), tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE tsorage.reverse_sharded_dynamic_tagset(
    shard text,
    tagname text,
    tagvalue text,
    metric text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY ( (shard, tagname), tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC);